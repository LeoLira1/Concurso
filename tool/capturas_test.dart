// Gera capturas de tela do app com dados de exemplo.
// Uso: flutter test tool/capturas_test.dart --update-goldens
// As imagens vão para tool/capturas/.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/logic/cronometro.dart';
import 'package:edital/logic/metodo.dart';
import 'package:edital/screens/ciclo_screen.dart';
import 'package:edital/screens/concursos_screen.dart';
import 'package:edital/screens/cronometro_screen.dart';
import 'package:edital/screens/edital_screen.dart';
import 'package:edital/screens/home_screen.dart';
import 'package:edital/screens/materia_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/state/sessao_ativa.dart';
import 'package:edital/state/notificacoes.dart';
import 'package:edital/screens/revisoes_screen.dart';
import 'package:edital/screens/lembretes_screen.dart';
import 'package:edital/screens/estatisticas_screen.dart';
import 'package:edital/screens/flashcards_screen.dart';
import 'package:edital/screens/topico_screen.dart';
import 'package:edital/screens/importar_screen.dart';
import 'package:edital/state/arquivos.dart';
import 'package:cross_file/cross_file.dart';
import 'package:edital/theme.dart';
import 'package:edital/util/texto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> carregarFontes() async {
  final raiz = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  final dir = '$raiz/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto');
  for (final f in ['Regular', 'Medium', 'Bold', 'Black', 'Light']) {
    roboto.addFont(
      File('$dir/Roboto-$f.ttf').readAsBytes().then(ByteData.sublistView),
    );
  }
  await roboto.load();
  final icones = FontLoader('MaterialIcons')
    ..addFont(
      File('$dir/MaterialIcons-Regular.otf')
          .readAsBytes()
          .then(ByteData.sublistView),
    );
  await icones.load();
}

Future<AppDatabase> popular() async {
  final db = AppDatabase(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
  await db.carregarExemplo();
  final pm = await db.criarConcurso(
    nome: 'PM-SP Soldado',
    banca: 'Vunesp',
    dataProva: DateTime.now().add(const Duration(days: 74)),
    cor: 0xFFE5407A,
  );
  await db.adicionarMateria(pm, 'Língua Portuguesa', 0);
  final mat = await db.adicionarMateria(pm, 'Matemática', 0xFFF5A524);
  await db.adicionarTopicosEmLote(mat, 'Frações\nPorcentagem\nGeometria plana');

  final gm = (await db.watchConcursos().first).firstWhere((c) => c.exemplo);
  final mats = await db.watchMaterias(gm.id).first;
  // Marca alguns tópicos como vistos.
  final topicos = await db.select(db.topicos).get();
  for (final t in topicos.take(18)) {
    if (topicos.any((f) => f.paiId == t.id)) continue;
    await db.marcarVisto(t.id, true);
  }
  // Pesos e dificuldades do ciclo.
  const pd = {
    'Língua Portuguesa': (5, 3),
    'Matemática e Raciocínio Lógico': (3, 5),
    'Noções de Direito Constitucional': (4, 4),
    'Noções de Direito Administrativo': (3, 3),
    'Legislação Específica': (5, 2),
    'Direitos Humanos': (2, 2),
    'Noções de Informática': (2, 1),
  };
  for (final m in mats) {
    final v = pd[m.materia.nome];
    if (v != null) {
      await db.definirPesoDificuldade(
        gm.id,
        m.materia.id,
        peso: v.$1,
        dificuldade: v.$2,
      );
    }
  }
  final fila = (await db.watchCiclo(gm.id).first).fila;
  for (var i = 0; i < 3; i++) {
    await db.avancarCiclo(gm.id, fila.length);
  }

  // Sessões espalhadas no mês atual.
  final hoje = soDia(DateTime.now());
  const plano = {
    1: [0, 2],
    2: [1],
    3: [3, 0, 4],
    5: [2],
    8: [0, 1],
    9: [5],
    10: [3, 6, 0],
    12: [4],
    15: [0, 2],
    16: [1, 3],
    17: [6],
    18: [0],
    21: [2, 5],
    22: [1, 0],
    23: [3],
  };
  for (final e in plano.entries) {
    final dia = DateTime(hoje.year, hoje.month, e.key);
    if (dia.isAfter(hoje)) continue;
    for (final (i, idx) in e.value.indexed) {
      await db.registrarSessao(
        dia: dia,
        minutos: i == 0 && e.key.isEven ? 50 : 25,
        materiaId: mats[idx % mats.length].materia.id,
        metodo: Metodo.values[(e.key + i) % Metodo.values.length].chave,
        questoesFeitas: e.key.isEven ? 20 : 0,
        questoesAcertos: e.key.isEven ? 15 : 0,
        paginas: e.key.isOdd ? 14 : 0,
      );
    }
  }

  // Pontos de parada (aparecem na próxima sessão da matéria).
  Future<void> parada(
    String materia,
    String topico,
    Metodo m,
    String texto,
  ) async {
    final mid = (await db.materiaPorNome(materia))!.id;
    final tid = (await db.watchTopicos(mid).first)
        .firstWhere((t) => t.nome == topico)
        .id;
    await db.registrarSessao(
      dia: hoje.subtract(const Duration(days: 1)),
      minutos: 50,
      materiaId: mid,
      topicoId: tid,
      metodo: m.chave,
      pontoParada: texto,
    );
  }

  await parada(
    'Língua Portuguesa',
    'Crase',
    Metodo.pdf,
    'Parei nos casos facultativos (pág. 42)',
  );
  await parada(
    'Legislação Específica',
    'Estatuto Geral das Guardas Municipais (Lei 13.022/2014)',
    Metodo.leiSeca,
    'Li até o art. 5º — falta competências específicas',
  );
  // Histórico dos meses anteriores (para as estatísticas).
  for (var i = hoje.day; i <= hoje.day + 75; i++) {
    if (i % 7 == 3 || i % 11 == 0) continue; // alguns dias sem estudo
    final dia = hoje.subtract(Duration(days: i));
    for (var k = 0; k < 1 + i % 3; k++) {
      await db.registrarSessao(
        dia: dia,
        minutos: 25 + ((i * 7 + k * 13) % 5) * 15,
        materiaId: mats[(i + k * 3) % mats.length].materia.id,
        questoesFeitas: k == 0 ? 10 + i % 4 * 5 : 0,
        questoesAcertos: k == 0 ? 5 + (i * 3 + (i ~/ 3)) % 6 + i % 4 * 3 : 0,
      );
    }
  }
  await db.atualizarConcurso(
    gm.id,
    nome: gm.nome,
    banca: gm.banca,
    dataProva: hoje.add(const Duration(days: 48)),
    cor: gm.cor,
  );

  // Anexos e flashcards no tópico "Crase".
  final port = (await db.materiaPorNome('Língua Portuguesa'))!.id;
  final crase = (await db.watchTopicos(port).first)
      .firstWhere((t) => t.nome == 'Crase')
      .id;
  final raizRepo = Directory.current.path;
  for (final (arq, nome) in [
    ('referencias/biblioteca.jpg', 'Mapa mental — crase'),
    ('referencias/pocket_cal.jpg', 'Resumo do caderno'),
  ]) {
    await ArquivosAnexos.importar(
      db: db,
      topicoId: crase,
      origem: XFile('$raizRepo/$arq'),
      tipo: 'imagem',
      nome: nome,
    );
  }
  final pdf = File('${Directory.systemTemp.path}/crase_estrategia.pdf')
    ..writeAsBytesSync(List.filled(812000, 37));
  await ArquivosAnexos.importar(
    db: db,
    topicoId: crase,
    origem: XFile(pdf.path),
    tipo: 'pdf',
    nome: 'Aula 07 — Crase (PDF)',
  );
  for (final (f, v) in const [
    (
      'Quando o uso da crase é facultativo?',
      'Antes de nomes próprios femininos, de pronomes possessivos femininos e depois da preposição "até".',
    ),
    ('Há crase antes de horas?', 'Sim, em horas determinadas: "Chegou às 8h".'),
    (
      'Crase antes de palavra masculina?',
      'Não, salvo quando subentendida "à moda de": "bife à milanesa".',
    ),
    ('Crase antes de verbo?', 'Nunca.'),
  ]) {
    await db.salvarFlashcard(topicoId: crase, frente: f, verso: v);
  }
  final cards = await db.watchFlashcards(crase).first;
  await db.responderFlashcard(cards[3], acertou: true);

  // Algumas revisões vencendo hoje e uma atrasada.
  final revs =
      await (db.select(db.revisoes)
            ..where((r) => r.intervaloDias.equals(1))
            ..limit(5))
          .get();
  for (final (i, r) in revs.indexed) {
    await (db.update(db.revisoes)..where((x) => x.id.equals(r.id))).write(
      RevisoesCompanion(
        dataPrevista: Value(hoje.subtract(Duration(days: i == 0 ? 2 : 0))),
      ),
    );
  }
  return db;
}

Widget app(
  AppDatabase db,
  Widget home, {
  AppState? estado,
  SessaoAtiva? sessao,
}) => MultiProvider(
  providers: [
    Provider<AppDatabase>.value(value: db),
    ChangeNotifierProvider(create: (_) => estado ?? AppState()),
    ChangeNotifierProvider(
      create: (_) => Notificacoes(db: db)
        ..disponivel = true
        ..permitido = true,
    ),
    ChangeNotifierProvider(create: (_) => sessao ?? SessaoAtiva()),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: temaEdital(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  ),
);

Future<void> assentar(WidgetTester tester, {bool settle = true}) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
    }
  }
}

/// Relógio parado: o cronômetro "roda", mas os números ficam fixos na captura.
final _instante = DateTime(2026, 9, 23, 15);

Cronometro cronometroExemplo(String materiaId, {bool pomodoro = false}) {
  return Cronometro(
    materiaId: materiaId,
    metaMin: 55,
    modo: pomodoro ? ModoCronometro.pomodoro : ModoCronometro.livre,
    liquido: const Duration(minutes: 38, seconds: 27),
    faseDecorrido: pomodoro
        ? const Duration(minutes: 1, seconds: 48)
        : Duration.zero,
    fase: pomodoro ? Fase.pausa : Fase.foco,
    pomodoros: pomodoro ? 1 : 0,
    relogio: () => _instante,
  );
}

void main() {
  setUpAll(() async {
    await carregarFontes();
    ArquivosAnexos.pastaFixa = await Directory.systemTemp.createTemp(
      'anexos_capturas',
    );
  });
  // ignore: invalid_use_of_visible_for_testing_member
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> captura(
    WidgetTester tester,
    String nome,
    Size tamanho,
    Widget Function(AppDatabase db) tela, {
    Future<void> Function(WidgetTester t)? antes,
    bool settle = true,
    VoidCallback? depois,
  }) async {
    final db = (await tester.runAsync(popular))!;
    tester.view.physicalSize = tamanho * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(tela(db));
    await assentar(tester, settle: settle);
    if (antes != null) {
      await antes(tester);
      await assentar(tester, settle: settle);
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('capturas/$nome.png'),
    );
    depois?.call();
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  }

  const paisagem = Size(1280, 800);
  const retrato = Size(800, 1280);
  const celular = Size(412, 915);

  Widget home(AppDatabase db) => app(db, const HomeScreen());

  Widget comFoco(AppDatabase db, Widget Function(String id) f) => app(
    db,
    FutureBuilder(
      future: db.watchFoco().first,
      builder: (_, s) => s.data == null ? const SizedBox() : f(s.data!.id),
    ),
  );

  // --- Etapa 1 ---
  testWidgets(
    'tablet paisagem',
    (t) => captura(t, '1_tablet_paisagem', paisagem, home),
  );
  testWidgets(
    'tablet paisagem filtrado',
    (t) => captura(
      t,
      '2_tablet_filtro_materia',
      paisagem,
      home,
      antes: (t) async {
        await t.tap(find.text('Língua Portuguesa').first);
        await t.pumpAndSettle();
        await t.tap(find.byIcon(Icons.chevron_right_rounded).at(1));
      },
    ),
  );
  testWidgets(
    'meus concursos',
    (t) => captura(
      t,
      '3_meus_concursos',
      paisagem,
      (db) => app(db, const ConcursosScreen()),
    ),
  );
  testWidgets(
    'edital',
    (t) => captura(
      t,
      '4_edital',
      paisagem,
      (db) => comFoco(db, (id) => EditalScreen(concursoId: id)),
    ),
  );
  testWidgets(
    'materia',
    (t) => captura(
      t,
      '5_materia',
      paisagem,
      (db) => app(
        db,
        FutureBuilder(
          future: db.materiaPorNome('Língua Portuguesa'),
          builder: (_, s) => s.data == null
              ? const SizedBox()
              : MateriaScreen(materiaId: s.data!.id, concursoId: ''),
        ),
      ),
    ),
  );
  testWidgets(
    'tablet retrato',
    (t) => captura(t, '6_tablet_retrato', retrato, home),
  );
  testWidgets('celular', (t) => captura(t, '7_celular', celular, home));

  // --- Etapa 2: ciclo de estudos e cronômetro ---
  Widget ciclo(AppDatabase db) =>
      comFoco(db, (id) => CicloScreen(concursoId: id));

  testWidgets(
    'ciclo paisagem',
    (t) => captura(t, '8_ciclo_paisagem', paisagem, ciclo),
  );
  testWidgets(
    'ciclo retrato',
    (t) => captura(t, '8b_ciclo_retrato', retrato, ciclo),
  );

  Future<void> abrirFolha(WidgetTester t) async {
    await t.tap(find.text('PRÓXIMA DO CICLO'));
    await t.pumpAndSettle();
  }

  testWidgets(
    'proxima paisagem',
    (t) => captura(t, '9_proxima_paisagem', paisagem, home, antes: abrirFolha),
  );
  testWidgets(
    'proxima retrato',
    (t) => captura(t, '9b_proxima_retrato', retrato, home, antes: abrirFolha),
  );

  Future<void> cronometro(
    WidgetTester t,
    String nome,
    Size tamanho, {
    bool pomodoro = false,
    Future<void> Function(WidgetTester t)? antes,
  }) {
    final sessao = SessaoAtiva();
    return captura(
      t,
      nome,
      tamanho,
      (db) => app(
        db,
        FutureBuilder(
          future: db.materiaPorNome('Língua Portuguesa'),
          builder: (context, s) {
            if (s.data == null) return const SizedBox();
            if (sessao.atual == null) {
              sessao.definir(
                cronometroExemplo(s.data!.id, pomodoro: pomodoro)..iniciar(),
              );
            }
            return const CronometroScreen(telaCheia: false);
          },
        ),
        sessao: sessao,
      ),
      settle: false,
      antes: antes,
      depois: () => sessao.atual?.pausar(),
    );
  }

  testWidgets(
    'cronometro paisagem',
    (t) => cronometro(t, '10_cronometro_paisagem', paisagem),
  );
  testWidgets(
    'cronometro retrato',
    (t) => cronometro(t, '10b_cronometro_retrato', retrato),
  );
  testWidgets(
    'pomodoro paisagem',
    (t) =>
        cronometro(t, '11_pomodoro_pausa_paisagem', paisagem, pomodoro: true),
  );
  testWidgets(
    'pomodoro retrato',
    (t) => cronometro(t, '11b_pomodoro_pausa_retrato', retrato, pomodoro: true),
  );

  // --- Etapa 3: registro ao finalizar e ponto de parada ---
  Future<void> preencherRegistro(WidgetTester t) async {
    await t.tap(find.text('Finalizar'));
    for (var i = 0; i < 4; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await t.pump(const Duration(milliseconds: 300));
    }
    await t.tap(find.text('PDF'));
    await t.pump();
    for (var i = 0; i < 12; i++) {
      await t.tap(find.byTooltip('Mais').at(0));
      await t.pump();
    }
    for (var i = 0; i < 10; i++) {
      await t.tap(find.byTooltip('Mais').at(1));
      await t.pump();
    }
    for (var i = 0; i < 6; i++) {
      await t.tap(find.byTooltip('Mais').at(2));
      await t.pump();
    }
    await t.enterText(
      find.byType(TextField).last,
      'Crase facultativa ok — próxima: crase com horas',
    );
    await t.pump(const Duration(milliseconds: 400));
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pump(const Duration(milliseconds: 400));
  }

  testWidgets(
    'registro paisagem',
    (t) => cronometro(
      t,
      '12_registro_paisagem',
      paisagem,
      antes: preencherRegistro,
    ),
  );
  testWidgets(
    'registro retrato',
    (t) => cronometro(
      t,
      '12b_registro_retrato',
      retrato,
      antes: preencherRegistro,
    ),
  );

  Future<void> abrirDia(WidgetTester t) async {
    await t.tap(find.text('22').first);
    await t.pumpAndSettle();
  }

  testWidgets(
    'dia paisagem',
    (t) => captura(t, '13_dia_paisagem', paisagem, home, antes: abrirDia),
  );
  testWidgets(
    'dia retrato',
    (t) => captura(t, '13b_dia_retrato', retrato, home, antes: abrirDia),
  );

  // --- Etapa 4: revisões e lembretes ---
  testWidgets(
    'revisoes paisagem',
    (t) => captura(
      t,
      '14_revisoes_paisagem',
      paisagem,
      (db) => app(db, const RevisoesScreen()),
    ),
  );
  testWidgets(
    'revisoes retrato',
    (t) => captura(
      t,
      '14b_revisoes_retrato',
      retrato,
      (db) => app(db, const RevisoesScreen()),
    ),
  );
  testWidgets(
    'lembretes paisagem',
    (t) => captura(
      t,
      '15_lembretes_paisagem',
      paisagem,
      (db) => app(db, const LembretesScreen()),
    ),
  );
  testWidgets(
    'lembretes retrato',
    (t) => captura(
      t,
      '15b_lembretes_retrato',
      retrato,
      (db) => app(db, const LembretesScreen()),
    ),
  );

  // --- Etapa 5: estatísticas ---
  Future<void> rolar(WidgetTester t) async {
    await t.drag(find.byType(ListView).first, const Offset(0, -560));
    await t.pumpAndSettle();
  }

  Widget estatisticas(AppDatabase db) => app(db, const EstatisticasScreen());

  testWidgets(
    'estatisticas paisagem',
    (t) => captura(t, '16_estatisticas_paisagem', paisagem, estatisticas),
  );
  testWidgets(
    'estatisticas paisagem rolada',
    (t) => captura(
      t,
      '16c_estatisticas_paisagem_rolada',
      paisagem,
      estatisticas,
      antes: rolar,
    ),
  );
  testWidgets(
    'estatisticas retrato',
    (t) => captura(t, '16b_estatisticas_retrato', retrato, estatisticas),
  );
  testWidgets(
    'estatisticas retrato rolada',
    (t) => captura(
      t,
      '16d_estatisticas_retrato_rolada',
      retrato,
      estatisticas,
      antes: rolar,
    ),
  );

  // --- Etapa 6: anexos e flashcards ---
  Future<void> precarregarImagens(WidgetTester t) async {
    for (var i = 0; i < 4; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Widget topico(AppDatabase db) => app(
    db,
    FutureBuilder(
      future: () async {
        final port = (await db.materiaPorNome('Língua Portuguesa'))!.id;
        return (await db.watchTopicos(port).first)
            .firstWhere((t) => t.nome == 'Crase')
            .id;
      }(),
      builder: (_, s) =>
          s.data == null ? const SizedBox() : TopicoScreen(topicoId: s.data!),
    ),
  );

  testWidgets(
    'topico paisagem',
    (t) => captura(
      t,
      '17_topico_paisagem',
      paisagem,
      topico,
      antes: precarregarImagens,
    ),
  );
  testWidgets(
    'topico retrato',
    (t) => captura(
      t,
      '17b_topico_retrato',
      retrato,
      topico,
      antes: precarregarImagens,
    ),
  );

  Widget estudo(AppDatabase db, {bool verso = false}) => app(
    db,
    FutureBuilder(
      future: db.watchCartoesParaRevisar().first,
      builder: (_, s) => s.data == null
          ? const SizedBox()
          : EstudoFlashcardsScreen(
              titulo: 'Crase',
              fila: s.data!,
              mostrarVersoInicial: verso,
            ),
    ),
  );

  testWidgets(
    'flashcard frente paisagem',
    (t) => captura(t, '18_flashcard_paisagem', paisagem, estudo),
  );
  testWidgets(
    'flashcard verso retrato',
    (t) => captura(
      t,
      '18b_flashcard_verso_retrato',
      retrato,
      (db) => estudo(db, verso: true),
    ),
  );

  // --- Importar conteúdo programático ---
  const textoEdital = '''CONHECIMENTOS BÁSICOS
LÍNGUA PORTUGUESA: 1 Compreensão e interpretação de textos de gêneros variados. 2 Reconhecimento de tipos e gêneros textuais. 3 Domínio da ortografia oficial. 4 Domínio dos mecanismos de coesão textual. 4.1 Emprego de elementos de referenciação, substituição e repetição, de conectores e de outros elementos de sequenciação textual. 4.2 Emprego de tempos e modos verbais. 5 Domínio da estrutura morfossintática do período. 5.1 Emprego das classes de palavras. 5.2 Relações de coordenação entre orações. 5.3 Emprego do sinal indicativo de crase. 6 Reescrita de frases e parágrafos do texto.
RACIOCÍNIO LÓGICO: 1 Estruturas lógicas. 2 Lógica de argumentação: analogias, inferências, deduções e conclusões. 3 Lógica sentencial (ou proposicional). 3.1 Proposições simples e compostas. 3.2 Tabelas-verdade. 3.3 Equivalências.
NOÇÕES DE INFORMÁTICA: 1 Noções de sistema operacional (ambiente Windows). 2 Edição de textos, planilhas e apresentações. 3 Redes de computadores. 4 Segurança da informação.
CONHECIMENTOS ESPECÍFICOS
LEGISLAÇÃO APLICADA AO MPU: 1 Lei Complementar nº 75/1993. 2 Lei nº 8.112/1990 e alterações: regime disciplinar.
NOÇÕES DE DIREITO ADMINISTRATIVO: 1 Noções de organização administrativa. 1.1 Centralização, descentralização, concentração e desconcentração. 2 Ato administrativo. 2.1 Conceito, requisitos, atributos, classificação e espécies. 3 Agentes públicos.''';

  Widget importar(AppDatabase db) => comFoco(
    db,
    (id) => ImportarScreen(concursoId: id, textoInicial: textoEdital),
  );

  Future<void> abrirPrimeira(WidgetTester t) async {
    await t.tap(find.text('Língua Portuguesa').last);
    await t.pumpAndSettle();
  }

  testWidgets(
    'importar paisagem',
    (t) => captura(
      t,
      '19_importar_paisagem',
      paisagem,
      importar,
      antes: abrirPrimeira,
    ),
  );
  testWidgets(
    'importar retrato texto',
    (t) => captura(t, '19b_importar_retrato_texto', retrato, importar),
  );
  testWidgets(
    'importar retrato previa',
    (t) => captura(
      t,
      '19c_importar_retrato_previa',
      retrato,
      importar,
      antes: (t) async {
        await t.tap(find.textContaining('Prévia'));
        await t.pumpAndSettle();
        await abrirPrimeira(t);
      },
    ),
  );
}
