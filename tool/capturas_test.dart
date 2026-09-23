// Gera capturas de tela do app com dados de exemplo.
// Uso: flutter test tool/capturas_test.dart --update-goldens
// As imagens vão para tool/capturas/.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/logic/cronometro.dart';
import 'package:edital/screens/ciclo_screen.dart';
import 'package:edital/screens/concursos_screen.dart';
import 'package:edital/screens/cronometro_screen.dart';
import 'package:edital/screens/edital_screen.dart';
import 'package:edital/screens/home_screen.dart';
import 'package:edital/screens/materia_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/state/sessao_ativa.dart';
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
      );
    }
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
  setUpAll(carregarFontes);
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
}
