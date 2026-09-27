import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/data/mapa_conteudo_db.dart';
import 'package:edital/data/pedido_db.dart';
import 'package:edital/logic/mapa_conteudo.dart';
import 'package:edital/logic/mapa_mental.dart';
import 'package:edital/logic/pedido_questoes.dart';
import 'package:edital/screens/colar_mapa_screen.dart';
import 'package:edital/screens/mapa_conteudo_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'sincronizacao_test.dart' show Aparelho, ServidorFalso;

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

const materia = 'Crimes contra a Administração Pública';
const topico = 'Peculato (arts. 312 e 313)';

Map<String, Object?> no(
  String texto, {
  String? tipo,
  String? detalhe,
  List<Map<String, Object?>>? filhos,
}) => {'texto': texto, 'detalhe': ?detalhe, 'tipo': ?tipo, 'filhos': ?filhos};

String mapaJson({
  String? materiaNome = materia,
  String? topicoNome = topico,
  String subtopico = '',
  String titulo = 'Peculato',
  List<Map<String, Object?>>? nos,
  String formato = formatoMapa,
}) => jsonEncode({
  'formato': formato,
  'materia': ?materiaNome,
  'topico': ?topicoNome,
  'subtopico': subtopico,
  'titulo': titulo,
  'nos':
      nos ??
      [
        no(
          'Peculato-apropriação',
          detalhe:
              'Funcionário se apropria de bem que tem a posse em razão do '
              'cargo.',
          tipo: 'conceito',
          filhos: [
            no(
              'Ex.: guarda fica com celular apreendido',
              tipo: 'exemplo',
              filhos: [],
            ),
          ],
        ),
        no('Art. 312, caput', tipo: 'artigo'),
        no('Peculato culposo: reparação extingue a punibilidade', tipo: 'dica'),
        no('Não confunda com concussão', tipo: 'pegadinha'),
      ],
});

/// Árvore com [total] nós: [raizes] no 1º nível e o resto espalhado em
/// até 4 níveis.
List<Map<String, Object?>> nosGrandes(int total, {int raizes = 8}) {
  final r = <Map<String, Object?>>[];
  var n = 0;
  Map<String, Object?> novo(int nivel) {
    n++;
    return {
      'texto': 'Nó $n do nível $nivel com um texto de tamanho médio',
      'tipo': TipoNoConteudo.values[n % 5].chave,
      'filhos': <Map<String, Object?>>[],
    };
  }

  for (var i = 0; i < raizes && n < total; i++) {
    r.add(novo(1));
  }
  var nivel = 1;
  var atuais = [...r];
  while (n < total && nivel < limiteNiveis) {
    final proximos = <Map<String, Object?>>[];
    for (final p in atuais) {
      for (var k = 0; k < 3 && n < total; k++) {
        final f = novo(nivel + 1);
        (p['filhos'] as List).add(f);
        proximos.add(f);
      }
    }
    atuais = proximos;
    nivel++;
  }
  return r;
}

void main() {
  group('leitura e validação do JSON', () {
    test('lê o formato do exemplo, com texto de chat e cercas', () {
      final l = lerMapas(
        'Claro! Segue o mapa:\n```json\n${mapaJson()}\n```\nBons estudos!',
      );
      expect(l.erro, isNull);
      final m = l.mapas.single;
      expect(m.valida, isTrue, reason: '${m.erros}');
      expect(m.materia, materia);
      expect(m.topico, topico);
      expect(m.subtopico, '');
      expect(m.titulo, 'Peculato');
      expect(m.totalNos, 5);
      expect(m.nos.first.detalhe, startsWith('Funcionário'));
      expect(m.nos.first.filhos.single.tipo, TipoNoConteudo.exemplo);
      expect(contarPorTipo(m.nos), {
        TipoNoConteudo.conceito: 1,
        TipoNoConteudo.exemplo: 1,
        TipoNoConteudo.artigo: 1,
        TipoNoConteudo.dica: 1,
        TipoNoConteudo.pegadinha: 1,
      });
    });

    test('sem tipo = conceito; detalhe, subtópico e filhos são opcionais', () {
      final l = lerMapas(
        jsonEncode({
          'formato': formatoMapa,
          'materia': materia,
          'topico': topico,
          'titulo': 'P',
          'nos': [
            {'texto': 'Só o texto'},
          ],
        }),
      );
      final m = l.mapas.single;
      expect(m.valida, isTrue, reason: '${m.erros}');
      expect(m.nos.single.tipo, TipoNoConteudo.conceito);
      expect(m.nos.single.detalhe, '');
      expect(m.nos.single.filhos, isEmpty);
    });

    test('na tela do tópico, o que falta vem do tópico aberto', () {
      final l = lerMapas(
        mapaJson(materiaNome: null, topicoNome: null),
        materiaPadrao: materia,
        topicoPadrao: topico,
        subtopicoPadrao: 'Peculato culposo',
      );
      final m = l.mapas.single;
      expect(m.materia, materia);
      expect(m.topico, topico);
      expect(m.subtopico, 'Peculato culposo');
    });

    test('erros com o motivo: formato, tipo, texto vazio, sem nós', () {
      expect(
        lerMapas(mapaJson(formato: 'outro')).mapas.single.erros,
        contains('formato "outro" (esperado "edital-mapa-v1")'),
      );
      final m = lerMapas(
        mapaJson(
          nos: [
            no('A', tipo: 'resumo'),
            no(''),
          ],
        ),
      ).mapas.single;
      expect(m.valida, isFalse);
      expect(
        m.erros,
        contains(
          "Nó 'A': tipo \"resumo\" não existe (use conceito, artigo, "
          'exemplo, pegadinha ou dica)',
        ),
      );
      expect(m.erros, contains('nó 2 de nos sem texto'));
      expect(
        lerMapas(mapaJson(nos: [])).mapas.single.erros,
        contains('o mapa não tem nenhum nó'),
      );
      expect(lerMapas('sem json nenhum').erro, isNotNull);
    });
  });

  group('limites', () {
    test('texto até 70 caracteres', () {
      final longo = 'Concussão ${'x' * 85}'; // 95 caracteres
      final ok = 'y' * limiteTextoNo;
      final m = lerMapas(mapaJson(nos: [no(longo), no(ok)])).mapas.single;
      expect(m.valida, isFalse);
      expect(m.erros, ["Nó '$longo': texto com 95 caracteres (máximo 70)"]);
    });

    test('até 4 níveis', () {
      Map<String, Object?> cadeia(int n) =>
          n == 1 ? no('N$n') : no('N$n', filhos: [cadeia(n - 1)]);
      final quatro = lerMapas(mapaJson(nos: [cadeia(4)])).mapas.single;
      expect(quatro.valida, isTrue, reason: '${quatro.erros}');
      final cinco = lerMapas(mapaJson(nos: [cadeia(5)])).mapas.single;
      expect(cinco.erros, ["Nó 'N1': está no nível 5 (máximo 4 níveis)"]);
    });

    test('até 80 nós', () {
      final oitenta = lerMapas(mapaJson(nos: nosGrandes(80))).mapas.single;
      expect(oitenta.totalNos, 80);
      expect(oitenta.valida, isTrue, reason: '${oitenta.erros}');
      final mais = lerMapas(mapaJson(nos: nosGrandes(81))).mapas.single;
      expect(mais.erros, ['o mapa tem 81 nós (máximo 80)']);
    });
  });

  group('banco: vínculo ao tópico e substituição', () {
    late AppDatabase db;
    late String pm;
    setUp(() async {
      db = bancoMemoria();
      pm = await db.criarConcurso(nome: 'GM', cor: 1);
    });
    tearDown(() => db.close());

    Future<Materia> mat() async => (await db.materiaPorNome(materia))!;

    test('tópico que não existe é criado no edital, com o mapa', () async {
      final l = lerMapas(mapaJson());
      final destinos = await db.destinosColagem(l, concursoId: pm);
      expect(destinos[1]!.materiaNova, isTrue);
      expect(destinos[1]!.topicoNovo, isTrue);
      final r = await db.importarMapas(l, concursoId: pm);
      expect(r.novas, 1);
      expect(r.topicosCriados, ['$materia · $topico']);
      final m = await mat();
      final t = (await db.watchTopicos(m.id, concursoId: pm).first).single;
      expect(t.nome, topico);
      final salvo = (await db.mapaDoTopico(t.id))!;
      expect(salvo.titulo, 'Peculato');
      expect(percorrer(salvo.nos).length, 5);
      expect(await db.watchTopicosComMapa().first, {t.id});
    });

    test('subtópico existente recebe o mapa; nome ignora acento', () async {
      final mid = await db.adicionarMateria(pm, materia, 2);
      final t = await db.adicionarTopico(mid, topico);
      final s = await db.adicionarTopico(mid, 'Peculato culposo', paiId: t);
      final l = lerMapas(
        mapaJson(
          topicoNome: 'PECULATO (arts. 312 e 313)',
          subtopico: 'peculato culposo',
        ),
      );
      final d = (await db.destinosColagem(l, concursoId: pm))[1]!;
      expect(d.topicoNovo, isFalse);
      expect(d.subtopicoNovo, isFalse);
      await db.importarMapas(l, concursoId: pm);
      expect(await db.mapaDoTopico(s), isNotNull);
      expect(await db.mapaDoTopico(t), isNull);
    });

    test('um mapa por tópico: colar de novo substitui', () async {
      final l1 = lerMapas(mapaJson());
      expect(await db.mapasQueSubstituem(l1), isEmpty);
      await db.importarMapas(l1, concursoId: pm);

      final l2 = lerMapas(
        mapaJson(
          titulo: 'Peculato v2',
          nos: [no('Só um nó', tipo: 'dica')],
        ),
      );
      expect(await db.mapasQueSubstituem(l2), {1});
      await db.importarMapas(l2, concursoId: pm);

      expect(await db.select(db.mapasConteudo).get(), hasLength(1));
      final t = (await db.watchTopicos((await mat()).id).first).single;
      final salvo = (await db.mapaDoTopico(t.id))!;
      expect(salvo.titulo, 'Peculato v2');
      expect(salvo.nos.single.texto, 'Só um nó');
      expect(salvo.linha.id, t.id);
    });

    test('dois mapas para o mesmo tópico na lista: vale o primeiro', () {
      final l = lerMapas('[${mapaJson()}, ${mapaJson(titulo: 'B')}]');
      expect(l.novas, 1);
      expect(l.mapas[1].repetida, isTrue);
    });

    test('excluir o mapa, e excluir o tópico leva o mapa junto', () async {
      await db.importarMapas(lerMapas(mapaJson()), concursoId: pm);
      final t = (await db.watchTopicos((await mat()).id).first).single;
      await db.excluirMapa(t.id);
      expect(await db.mapaDoTopico(t.id), isNull);
      await db.importarMapas(lerMapas(mapaJson()), concursoId: pm);
      await (db.delete(db.topicos)..where((x) => x.id.equals(t.id))).go();
      expect(await db.select(db.mapasConteudo).get(), isEmpty);
    });
  });

  test('o mapa sincroniza pelo Turso, inclusive a exclusão', () async {
    final servidor = ServidorFalso();
    final tablet = Aparelho('tablet', servidor);
    final celular = Aparelho('celular', servidor);
    addTearDown(() async {
      await tablet.db.close();
      await celular.db.close();
      servidor.banco.close();
    });
    final c = await tablet.db.criarConcurso(nome: 'GM', cor: 1);
    await tablet.db.importarMapas(lerMapas(mapaJson()), concursoId: c);
    await tablet.sincronizar();
    await celular.sincronizar();
    final m = (await celular.db.materiaPorNome(materia))!;
    final t = (await celular.db.watchTopicos(m.id).first).single;
    final noCelular = (await celular.db.mapaDoTopico(t.id))!;
    expect(noCelular.titulo, 'Peculato');
    expect(percorrer(noCelular.nos).length, 5);

    await celular.db.excluirMapa(t.id);
    await celular.sincronizar();
    await tablet.sincronizar();
    expect(await tablet.db.mapaDoTopico(t.id), isNull);
  });

  test('migra banco v7 -> v8: cria a tabela dos mapas', () async {
    final dir = await Directory.systemTemp.createTemp('edital');
    final arquivo = File('${dir.path}/edital.sqlite');
    var db = AppDatabase(NativeDatabase(arquivo));
    final c = await db.criarConcurso(nome: 'PM', cor: 1);
    final m = await db.adicionarMateria(c, 'Português', 1);
    final t = await db.adicionarTopico(m, 'Crase');
    await db.customStatement('DROP TABLE mapas_conteudo');
    await db.customStatement('PRAGMA user_version = 7');
    await db.close();

    db = AppDatabase(NativeDatabase(arquivo));
    await db.salvarMapa(
      t,
      titulo: 'Crase',
      nos: [NoConteudo(texto: 'A')],
    );
    expect((await db.mapaDoTopico(t))!.nos.single.texto, 'A');
    final pend = await db
        .customSelect(
          "SELECT COUNT(*) AS n FROM sync_pendentes WHERE tabela = 'mapas_conteudo'",
        )
        .getSingle();
    expect(pend.read<int>('n'), 1);
    await db.close();
    await dir.delete(recursive: true);
  });

  group('texto do pedido (Pedir mais → Mapa do conteúdo)', () {
    test('mapa novo: formato, nomes exatos e limites', () async {
      final db = bancoMemoria();
      addTearDown(db.close);
      final c = await db.criarConcurso(nome: 'GM', banca: 'IBFC', cor: 1);
      final mid = await db.adicionarMateria(c, materia, 2);
      final t = await db.adicionarTopico(mid, topico);
      final ctx = await db.contextoPedido(
        materia: (await db.watchMateria(mid).first)!,
        topico: (await db.topico(t))!,
        concursoId: c,
      );
      final texto = montarPedido(ctx, quantidade: 10, tipo: TipoPedido.mapa);
      expect(texto, startsWith('Monte o mapa do conteúdo de "$topico"'));
      expect(texto, contains('edital-mapa-v1'));
      expect(texto, contains('no máximo 70 caracteres'));
      expect(texto, contains('No máximo 4 níveis abaixo do título e 80 nós'));
      expect(texto, contains('conceito, artigo, exemplo, pegadinha ou dica'));
      expect(texto, contains('Matéria: $materia'));
      expect(texto, contains('Tópico: $topico'));
      expect(texto, contains('Banca: IBFC'));
      expect(texto, isNot(contains('MAPA ATUAL')));
      // O exemplo do formato é lido de volta pelo "Colar mapa".
      final linha = texto
          .split('\n')
          .firstWhere((l) => l.trimLeft().startsWith('{"formato"'));
      final l = lerMapas(linha);
      expect(l.mapas.single.materia, materia);
      expect(l.mapas.single.topico, topico);
      expect(l.mapas.single.valida, isTrue, reason: '${l.mapas.single.erros}');
    });

    test('com mapa: lista os nós atuais e pede para ampliar', () {
      final nos = lerMapas(mapaJson()).mapas.single.nos;
      final ctx = ContextoPedido(
        materia: materia,
        topicos: const [TopicoPedido(nome: topico)],
        subtopicoAberto: 'Peculato culposo',
        mapaAtual: (titulo: 'Peculato', nos: nos),
      );
      final texto = montarPedido(ctx, quantidade: 10, tipo: TipoPedido.mapa);
      expect(texto, startsWith('Amplie o mapa do conteúdo'));
      expect(texto, contains('devolva o mapa inteiro'));
      expect(texto, contains('MAPA ATUAL ("Peculato", 5 nós'));
      expect(texto, contains('- [conceito] Peculato-apropriação'));
      expect(
        texto,
        contains('  - [exemplo] Ex.: guarda fica com celular apreendido'),
      );
      expect(texto, contains('"subtopico":"Peculato culposo"'));
    });
  });

  group('layout em balões', () {
    test('80 nós em 4 níveis: sem sobreposição e sem cruzar', () {
      for (final raizes in [3, 8, 20]) {
        final nos = lerMapas(mapaJson(nos: nosGrandes(80, raizes: raizes)))
            .mapas
            .single
            .nos;
        final porId = <String, NoConteudo>{};
        final l = calcularLayout(
          arvoreDoConteudo('Título comprido do mapa', nos, nosPorId: porId),
        );
        expect(l.nos, hasLength(81));
        expect(porId, hasLength(80));
        expect(temSobreposicao(l.nos), isFalse, reason: 'raízes: $raizes');
        expect(cruzamentos(l), isEmpty, reason: 'raízes: $raizes');
        expect(l.raiz.no.rotulo, 'Título comprido do mapa');
      }
    });

    test('ids pelo caminho e nível', () {
      final a = arvoreDoConteudo('T', lerMapas(mapaJson()).mapas.single.nos);
      expect(a.filhos.map((f) => f.id), ['0', '1', '2', '3']);
      expect(a.filhos.first.filhos.single.id, '0.0');
      expect(nivelDoId('titulo'), 0);
      expect(nivelDoId('0'), 1);
      expect(nivelDoId('0.0.1'), 3);
      expect(a.filhos[3].cor, TipoNoConteudo.pegadinha.cor);
    });
  });

  group('telas', () {
    Widget app(AppDatabase db, Widget home) => MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
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

    Future<void> assentar(WidgetTester t) async {
      for (var i = 0; i < 3; i++) {
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)),
        );
        await t.pump(const Duration(milliseconds: 400));
      }
    }

    for (final (nome, tamanho) in [
      ('deitado', const Size(1280, 800)),
      ('em pé', const Size(800, 1280)),
    ]) {
      testWidgets('colar mapa: prévia, erros e substituir ($nome)', (t) async {
        t.view.physicalSize = tamanho * 2;
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        final db = bancoMemoria();
        addTearDown(db.close);
        final pm = (await t.runAsync(() async {
          final pm = await db.criarConcurso(nome: 'GM', cor: 1);
          await db.importarMapas(lerMapas(mapaJson()), concursoId: pm);
          return pm;
        }))!;
        final longo = 'Concussão ${'x' * 85}';
        await t.pumpWidget(
          app(
            db,
            ColarMapaScreen(
              concursoId: pm,
              textoInicial: mapaJson(nos: [no(longo)]),
            ),
          ),
        );
        await assentar(t);
        await t.tap(find.byKey(const ValueKey('conferir-mapa')));
        await assentar(t);
        expect(
          find.textContaining("Nó '$longo': texto com 95 caracteres"),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('importar-mapa')), findsNothing);

        // Agora um mapa válido para o tópico que já tem mapa.
        await t.enterText(
          find.byKey(const ValueKey('texto-mapa')),
          mapaJson(
            titulo: 'Novo',
            nos: [
              no('A', filhos: [no('B', tipo: 'pegadinha')]),
            ],
          ),
        );
        await t.tap(find.byKey(const ValueKey('conferir-mapa')));
        await assentar(t);
        expect(find.text('Vai substituir o mapa atual'), findsOneWidget);
        expect(find.text('2 nós'), findsOneWidget);
        expect(find.text('1 pegadinha'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        await t.tap(find.byKey(const ValueKey('importar-mapa')));
        await assentar(t);
        expect(find.text('Substituir o mapa atual?'), findsOneWidget);
        await t.tap(find.text('Substituir'));
        await assentar(t);
        expect(find.text('Mapa importado'), findsOneWidget);
        await t.tap(find.text('OK'));
        await assentar(t);
        final mapas = (await t.runAsync(
          () => db.select(db.mapasConteudo).get(),
        ))!;
        expect(mapas.single.titulo, 'Novo');
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('tela do mapa: detalhe e modo treino', (t) async {
      t.view.physicalSize = const Size(1280, 800) * 2;
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      final db = bancoMemoria();
      addTearDown(db.close);
      final topicoId = (await t.runAsync(() async {
        final pm = await db.criarConcurso(nome: 'GM', cor: 1);
        await db.importarMapas(lerMapas(mapaJson()), concursoId: pm);
        return (await db.watchTopicosComMapa().first).single;
      }))!;
      await t.pumpWidget(app(db, MapaConteudoScreen(topicoId: topicoId)));
      await assentar(t);
      MapaConteudoScreenState estado() =>
          t.state<MapaConteudoScreenState>(find.byType(MapaConteudoScreen));

      // Tocar num nó mostra o detalhe embaixo.
      await t.tapAt(estado().posicaoGlobal('0')!);
      await assentar(t);
      expect(estado().selecionado, '0');
      expect(find.byKey(const ValueKey('detalhe-no')), findsOneWidget);
      expect(find.textContaining('Funcionário se apropria'), findsOneWidget);

      // Modo treino: o 2º nível fica coberto; tocar revela.
      await t.tap(find.byKey(const ValueKey('modo-treino')));
      await assentar(t);
      expect(estado().cobertos, {'0.0'});
      expect(
        find.text('Lembre e toque para revelar · faltam 1'),
        findsOneWidget,
      );
      await t.tapAt(estado().posicaoGlobal('0.0')!);
      await assentar(t);
      expect(estado().cobertos, isEmpty);
      expect(find.text('Tudo revelado'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('cobrir-de-novo')));
      await assentar(t);
      expect(estado().cobertos, {'0.0'});
      await t.tap(find.byKey(const ValueKey('revelar-tudo')));
      await assentar(t);
      expect(estado().cobertos, isEmpty);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });
  });
}
