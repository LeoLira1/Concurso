import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/data/questoes_topico_db.dart';
import 'package:edital/logic/mapa_mental.dart';
import 'package:edital/logic/questoes_topico.dart';
import 'package:edital/screens/mapa_mental_screen.dart';
import 'package:edital/screens/pedir_questoes_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/theme.dart';
import 'package:edital/widgets/mapa_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hoje = DateTime(2026, 9, 24, 15);

TopicoMapa top(
  String id, {
  String materia = 'm',
  String? pai,
  bool visto = true,
  int ordem = 0,
}) => TopicoMapa(
  id: id,
  materiaId: materia,
  paiId: pai,
  nome: 'Tópico $id',
  visto: visto,
  ordem: ordem,
);

NoMapa arvore(List<TopicoMapa> tops, Map<String, InfoTopico> info) =>
    montarArvore(
      rotuloRaiz: 'X',
      materias: const [MateriaMapa('m', 'M', 1), MateriaMapa('n', 'N', 2)],
      topicos: tops,
      info: info,
      hoje: hoje,
    );

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

void main() {
  group('escolha do "Foco agora"', () {
    test('prioridade: revisão atrasada, acerto baixo, nunca visto', () {
      final a = arvore(
        [
          top('nunca1', visto: false, ordem: 0),
          top('baixo', ordem: 1),
          top('atrasada', ordem: 2),
          top('ok', ordem: 3),
        ],
        {
          'baixo': InfoTopico(feitas: 20, acertos: 9),
          'atrasada': InfoTopico(proximaRevisao: DateTime(2026, 9, 21)),
          'ok': InfoTopico(feitas: 20, acertos: 18),
        },
      );
      final f = escolherFoco(a, hoje: hoje);
      expect(f.map((x) => x.id), ['atrasada', 'baixo', 'nunca1']);
      expect(f.map((x) => x.texto), [
        'revisão atrasada há 3 dias',
        'acerto 45%',
        'nunca visto',
      ]);
    });

    test('no máximo 3, e dentro de cada motivo o mais urgente primeiro', () {
      final a = arvore(
        [
          top('r1', ordem: 0),
          top('r2', ordem: 1),
          top('b1', ordem: 2),
          top('b2', ordem: 3),
          top('nv', visto: false, ordem: 4),
        ],
        {
          'r1': InfoTopico(proximaRevisao: DateTime(2026, 9, 23)),
          'r2': InfoTopico(proximaRevisao: DateTime(2026, 9, 10)),
          'b1': InfoTopico(feitas: 10, acertos: 5),
          'b2': InfoTopico(feitas: 10, acertos: 2),
        },
      );
      final f = escolherFoco(a, hoje: hoje);
      expect(f, hasLength(3));
      expect(f.map((x) => x.id), ['r2', 'r1', 'b2']);
      expect(f[0].texto, 'revisão atrasada há 14 dias');
      expect(f[1].texto, 'revisão atrasada há 1 dia');
      expect(f[2].texto, 'acerto 20%');
    });

    test('acerto baixo precisa de 10+ questões; revisão de hoje não conta', () {
      final a = arvore(
        [top('poucas'), top('hoje', ordem: 1)],
        {
          'poucas': InfoTopico(feitas: 9, acertos: 1),
          'hoje': InfoTopico(proximaRevisao: DateTime(2026, 9, 24)),
        },
      );
      expect(escolherFoco(a, hoje: hoje), isEmpty);
    });

    test('nunca visto olha as pontas: o subtópico, não o pai', () {
      final a = arvore([
        top('pai', visto: false),
        top('f1', pai: 'pai', visto: true),
        top('f2', pai: 'pai', visto: false, ordem: 1),
      ], {});
      expect(escolherFoco(a, hoje: hoje).map((x) => x.id), ['f2']);
    });

    test('só os tópicos permitidos (concurso em foco)', () {
      final a = arvore([
        top('fora', visto: false),
        top('dentro', materia: 'n', visto: false),
      ], {});
      final f = escolherFoco(a, hoje: hoje, permitidos: {'dentro'});
      expect(f.map((x) => x.id), ['dentro']);
    });
  });

  group('indicador de questões', () {
    test('o tópico soma as questões dos subtópicos', () {
      final a = arvore(
        [
          top('pai'),
          top('f1', pai: 'pai'),
          top('f2', pai: 'pai', ordem: 1),
          top('vazio', ordem: 1),
        ],
        {'pai': InfoTopico(questoes: 2), 'f1': InfoTopico(questoes: 5)},
      );
      final m = a.filhos.first;
      final pai = m.filhos[0];
      expect(pai.info.questoes, 7);
      expect(pai.filhos[0].info.questoes, 5);
      expect(pai.filhos[1].info.questoes, 0); // pontilhado
      expect(m.filhos[1].info.questoes, 0); // pontilhado
      expect(m.info.questoes, 7);
    });

    test('número curto no nó', () {
      expect(textoContagem(7), '7');
      expect(textoContagem(99), '99');
      expect(textoContagem(250), '99+');
    });

    test('o layout não muda com o indicador (sem sobreposição)', () {
      final tops = [
        for (var i = 0; i < 20; i++) top('t$i', ordem: i, visto: i.isEven),
      ];
      final sem = calcularLayout(arvore(tops, {}));
      final com = calcularLayout(
        arvore(tops, {
          for (var i = 0; i < 20; i += 3) 't$i': InfoTopico(questoes: 150),
        }),
      );
      expect(temSobreposicao(com.nos), isFalse);
      expect(cruzamentos(com), isEmpty);
      for (final n in sem.nos) {
        expect(com.porId(n.no.id)!.retangulo, n.retangulo);
      }
    });

    test('contorno pontilhado é tracejado de verdade', () {
      final p = tracejar(
        Path()..addRect(const Rect.fromLTWH(0, 0, 70, 0)),
        comprimento: 4,
        vao: 3,
      );
      // 70 px de ida e 70 de volta: 20 traços de 4 px.
      expect(p.computeMetrics().length, 20);
    });
  });

  group('na tela', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Widget app(AppDatabase db) => MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(theme: temaEdital(), home: const MapaMentalScreen()),
    );

    Future<void> assentar(WidgetTester t) async {
      for (var i = 0; i < 3; i++) {
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        await t.pumpAndSettle();
      }
    }

    Future<(AppDatabase, Topico, Topico)> abrir(WidgetTester t) async {
      t.view.physicalSize = const Size(1280, 800) * 2;
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      final db = bancoMemoria();
      final (crase, outro) = (await t.runAsync(() async {
        await db.carregarExemplo();
        final port = (await db.materiaPorNome('Língua Portuguesa'))!;
        final tops = await db.watchTopicos(port.id).first;
        final crase = tops.firstWhere((x) => x.nome == 'Crase');
        final outro = tops.firstWhere((x) => x.id != crase.id);
        // Revisão da crase atrasada há 5 dias.
        final d = DateTime.now();
        await db
            .into(db.revisoes)
            .insert(
              RevisoesCompanion.insert(
                topicoId: crase.id,
                dataPrevista: DateTime(d.year, d.month, d.day - 5),
                intervaloDias: 7,
              ),
            );
        await db.importarQuestoesTopico(
          lerQuestoes(
            jsonEncode([
              for (var i = 0; i < 2; i++)
                {
                  'enunciado': 'Crase $i?',
                  'alternativas': {'A': 'sim', 'B': 'não'},
                  'gabarito': 'A',
                },
            ]),
            materiaPadrao: 'Língua Portuguesa',
            topicoPadrao: 'Crase',
          ),
        );
        return (crase, outro);
      }))!;
      await t.pumpWidget(app(db));
      await assentar(t);
      return (db, crase, outro);
    }

    MapaMentalScreenState estado(WidgetTester t) =>
        t.state<MapaMentalScreenState>(find.byType(MapaMentalScreen));

    testWidgets('"Foco agora" destaca, dá zoom no primeiro e volta', (t) async {
      final (db, crase, _) = await abrir(t);
      final antes = estado(t).escala;
      expect(estado(t).foco, isNull);

      await t.tap(find.byKey(const ValueKey('foco-agora')));
      await assentar(t);
      final foco = estado(t).foco!;
      expect(foco, hasLength(3));
      expect(foco.first.id, crase.id);
      expect(find.text('Foco agora'), findsWidgets);
      expect(find.textContaining('revisão atrasada há 5 dias'), findsOneWidget);
      expect(find.textContaining('nunca visto'), findsWidgets);
      expect(find.text('Legenda'), findsNothing);
      // Centralizou o primeiro, com zoom.
      expect(estado(t).escala, greaterThan(antes));
      final p = estado(t).posicaoGlobal(crase.id)!;
      expect((p - const Offset(640, 400)).distance, lessThan(160));

      await t.tap(find.byKey(const ValueKey('foco-agora')));
      await assentar(t);
      expect(estado(t).foco, isNull);
      expect(find.text('Legenda'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.runAsync(db.close);
    });

    testWidgets('tocar no tópico abre o menu com os números', (t) async {
      final (db, crase, _) = await abrir(t);
      await t.tapAt(estado(t).posicaoGlobal(crase.id)!);
      await assentar(t);
      expect(find.byKey(const ValueKey('menu-rapido')), findsOneWidget);
      expect(find.text('Estudar este tópico'), findsOneWidget);
      expect(find.text('2 para hoje · 2 no total'), findsOneWidget);
      expect(find.text('Nenhum cartão ainda'), findsOneWidget);
      expect(find.text('Abrir tópico'), findsOneWidget);

      await t.tap(find.byKey(const ValueKey('menu-pedir')));
      for (var i = 0; i < 4; i++) {
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        await t.pump(const Duration(milliseconds: 400));
      }
      expect(find.byType(PedirQuestoesScreen), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.runAsync(db.close);
    });

    testWidgets('legenda mostra o indicador e o pontilhado', (t) async {
      final (db, _, _) = await abrir(t);
      await t.tap(find.text('Legenda'));
      await assentar(t);
      expect(find.text('Nº de questões no banco do tópico'), findsOneWidget);
      expect(find.text('Pontilhado: nenhuma questão ainda'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.runAsync(db.close);
    });
  });
}
