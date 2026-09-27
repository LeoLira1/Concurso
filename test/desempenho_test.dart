import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/logic/desempenho.dart';
import 'package:edital/logic/estatisticas.dart' show inicioDaSemana;
import 'package:edital/screens/desempenho_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

final hoje = DateTime(2026, 9, 27, 15);
DateTime diasAtras(int n) => DateTime(2026, 9, 27 - n);

TopicoDesempenho top(String id, {String? pai, String materia = 'm'}) =>
    TopicoDesempenho(
      id: id,
      nome: 'Tópico $id',
      materiaId: materia,
      paiId: pai,
    );

RegistroTopico reg(
  String id,
  int diasAntes,
  int feitas,
  int acertos, {
  int minutos = 0,
}) => RegistroTopico(
  topicoId: id,
  dia: diasAtras(diasAntes),
  feitas: feitas,
  acertos: acertos,
  minutos: minutos,
);

Desempenho um(List<RegistroTopico> r, {List<TopicoDesempenho>? topicos}) =>
    calcularDesempenho(topicos ?? [top('a')], r, hoje: hoje).first;

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

void main() {
  group('números do tópico', () {
    test('acerto total e janelas de 30 dias (hoje conta na recente)', () {
      final d = um([
        reg('a', 0, 10, 9), // recente
        reg('a', 29, 10, 7), // recente (limite)
        reg('a', 30, 10, 5), // anterior (limite)
        reg('a', 59, 10, 3), // anterior
        reg('a', 60, 10, 0), // fora das janelas, mas no total
      ]);
      expect(d.total.feitas, 50);
      expect(d.acerto, closeTo(24 / 50, 1e-9));
      expect(d.recente.feitas, 20);
      expect(d.recente.acertos, 16);
      expect(d.anterior.feitas, 20);
      expect(d.anterior.acertos, 8);
      expect(d.variacao, 40);
      expect(d.tendencia, Tendencia.subiu);
      expect(d.textoTendencia, 'subiu 40 pontos');
    });

    test('caiu, estável e sem dados (menos de 5 questões numa janela)', () {
      final caiu = um([reg('a', 1, 10, 4), reg('a', 40, 10, 8)]);
      expect(caiu.variacao, -40);
      expect(caiu.tendencia, Tendencia.caiu);
      expect(caiu.textoTendencia, 'caiu 40 pontos');

      final estavel = um([reg('a', 1, 10, 7), reg('a', 40, 10, 8)]);
      expect(estavel.variacao, -10 + 0);
      expect(estavel.tendencia, Tendencia.caiu); // -10 já conta

      final quase = um([reg('a', 1, 10, 8), reg('a', 40, 10, 8)]);
      expect(quase.tendencia, Tendencia.estavel);

      final pouco = um([reg('a', 1, 4, 0), reg('a', 40, 10, 10)]);
      expect(pouco.variacao, isNull);
      expect(pouco.tendencia, Tendencia.semDados);
    });

    test('subtópicos somam no tópico de cima', () {
      final l = calcularDesempenho(
        [top('p'), top('f1', pai: 'p'), top('f2', pai: 'f1'), top('q')],
        [reg('p', 1, 2, 1), reg('f1', 1, 3, 3), reg('f2', 2, 5, 0)],
        hoje: hoje,
      );
      expect(l.map((d) => d.topico.id), ['p', 'q']);
      expect(l.first.total.feitas, 10);
      expect(l.first.total.acertos, 4);
      expect(l.last.total.feitas, 0);
      expect(l.last.acerto, isNull);
    });

    test('último estudo conta sessão só com tempo; futuro é ignorado', () {
      final d = um([
        reg('a', 25, 10, 5),
        reg('a', 3, 0, 0, minutos: 40),
        RegistroTopico(topicoId: 'a', dia: DateTime(2026, 10, 5), feitas: 9),
      ]);
      expect(d.diasSemEstudar, 3);
      expect(d.textoUltimoEstudo, 'estudado há 3 dias');
      expect(d.total.feitas, 10);
      expect(um([]).textoUltimoEstudo, 'nunca estudado');
      expect(um([reg('a', 0, 1, 1)]).textoUltimoEstudo, 'estudado hoje');
      expect(um([reg('a', 1, 1, 1)]).textoUltimoEstudo, 'estudado ontem');
    });

    test('12 semanas terminando na atual; minilinha com as 8 últimas', () {
      final d = um([
        reg('a', 0, 4, 2),
        reg('a', 7, 10, 10),
        reg('a', 200, 5, 5),
      ]);
      expect(d.semanas, hasLength(semanasDetalhe));
      expect(d.semanas.last.inicio, inicioDaSemana(hoje));
      expect(d.semanas.last.placar.feitas, 4);
      expect(d.semanas[semanasDetalhe - 2].placar.acerto, 1.0);
      // A de 200 dias atrás não cabe no gráfico, mas entra no total.
      expect(d.semanas.fold(0, (s, x) => s + x.placar.feitas), 14);
      expect(d.total.feitas, 19);
      expect(d.minilinha, hasLength(semanasMinilinha));
      expect(d.minilinha.last.inicio, d.semanas.last.inicio);
    });

    test('linha da lista: sem questões, só o último estudo', () {
      expect(resumoLinha(um([])), 'nunca estudado');
      expect(
        resumoLinha(um([reg('a', 4, 0, 0, minutos: 30)])),
        'estudado há 4 dias',
      );
      expect(
        resumoLinha(um([reg('a', 1, 10, 8)])),
        'sem dados para comparar · 10 questões · estudado ontem',
      );
    });

    test('acertos nunca passam das feitas', () {
      expect(um([reg('a', 0, 3, 9)]).acerto, 1.0);
    });
  });

  group('Revise primeiro', () {
    test('ordem: caiu > acerto baixo > parado; com os motivos', () {
      final l = calcularDesempenho(
        [top('parado'), top('fraco'), top('caiu'), top('bem'), top('nunca')],
        [
          reg('parado', 30, 10, 9), // 30 dias sem estudar, acerto bom
          reg('fraco', 1, 20, 9), // 45%
          reg('caiu', 1, 10, 5), reg('caiu', 40, 10, 9), // -40, total 70%
          reg('bem', 1, 10, 9),
        ],
        hoje: hoje,
      );
      final s = sugerirRevisao(l);
      expect(s.map((x) => x.desempenho.topico.id), ['caiu', 'fraco', 'parado']);
      expect(s[0].texto, 'caiu 40 pontos em 30 dias');
      expect(s[1].texto, 'acerto 45% em 20 questões');
      expect(s[2].texto, 'parado há 30 dias');
      expect(s[0].motivos, [MotivoRevisao.caiu]);
    });

    test('vários motivos somam; no máximo 5; nunca estudado fica de fora', () {
      final l = calcularDesempenho(
        [for (var i = 0; i < 8; i++) top('t$i'), top('nunca')],
        [
          for (var i = 0; i < 8; i++) reg('t$i', 25 + i, 10, 2),
          reg('t7', 40, 10, 9),
        ],
        hoje: hoje,
      );
      final s = sugerirRevisao(l);
      expect(s, hasLength(maximoSugestoes));
      expect(s.any((x) => x.desempenho.topico.id == 'nunca'), isFalse);
      // Todos com acerto baixo + parado; pesa mais o parado há mais tempo
      // (t6, 31 dias). t7 tem 55%: menos grave.
      expect(s.first.desempenho.topico.id, 't6');
      expect(s.first.motivos, [MotivoRevisao.fraco, MotivoRevisao.parado]);
      expect(s.first.texto, 'acerto 20% em 10 questões · parado há 31 dias');
      expect(s.map((x) => x.desempenho.topico.id), isNot(contains('t7')));
      expect(s.first.texto, contains(' · '));
    });

    test('acerto baixo precisa de 10 questões', () {
      final l = calcularDesempenho([top('a')], [reg('a', 1, 9, 0)], hoje: hoje);
      expect(sugerirRevisao(l), isEmpty);
    });
  });

  test(
    'ordenar: pior acerto, maior queda, mais questões (sem dados no fim)',
    () {
      final l = calcularDesempenho(
        [top('a'), top('b'), top('c'), top('d')],
        [
          reg('a', 1, 10, 8),
          reg('a', 40, 10, 9),
          reg('b', 1, 30, 6),
          reg('b', 40, 10, 9),
          reg('c', 1, 10, 9),
        ],
        hoje: hoje,
      );
      List<String> ids(OrdemDesempenho o) =>
          ordenar(l, o).map((d) => d.topico.id).toList();
      expect(ids(OrdemDesempenho.edital), ['a', 'b', 'c', 'd']);
      expect(ids(OrdemDesempenho.piorAcerto), ['b', 'a', 'c', 'd']);
      expect(ids(OrdemDesempenho.maiorQueda), ['b', 'a', 'c', 'd']);
      expect(ids(OrdemDesempenho.maisQuestoes), ['b', 'a', 'c', 'd']);
    },
  );

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
        await t.pump(const Duration(milliseconds: 300));
      }
    }

    for (final (nome, tamanho) in [
      ('deitado', const Size(1280, 800)),
      ('celular', const Size(412, 915)),
    ]) {
      testWidgets('painel: revise primeiro, filtro, ordem e detalhe ($nome)', (
        t,
      ) async {
        t.view.physicalSize = tamanho * 2;
        t.view.devicePixelRatio = 2;
        addTearDown(t.view.reset);
        final db = bancoMemoria();
        addTearDown(db.close);
        final (port, mat) = (await t.runAsync(() async {
          final c = await db.criarConcurso(nome: 'GM', cor: 1);
          final port = await db.adicionarMateria(c, 'Português', 0xFF2F7CF6);
          final mat = await db.adicionarMateria(c, 'Matemática', 0xFFE08A00);
          final crase = await db.adicionarTopico(port, 'Crase');
          await db.adicionarTopico(port, 'Pontuação');
          final porc = await db.adicionarTopico(mat, 'Porcentagem');
          final agora = DateTime.now();
          DateTime atras(int n) =>
              DateTime(agora.year, agora.month, agora.day - n);
          // Crase caiu: 90% → 40%.
          await db.registrarSessao(
            dia: atras(40),
            minutos: 30,
            materiaId: port,
            topicoId: crase,
            questoesFeitas: 10,
            questoesAcertos: 9,
          );
          await db.registrarSessao(
            dia: atras(2),
            minutos: 30,
            materiaId: port,
            topicoId: crase,
            questoesFeitas: 10,
            questoesAcertos: 4,
          );
          // Porcentagem: acerto baixo.
          await db.registrarSessao(
            dia: atras(1),
            minutos: 20,
            materiaId: mat,
            topicoId: porc,
            questoesFeitas: 20,
            questoesAcertos: 8,
          );
          return (port, mat);
        }))!;
        await t.pumpWidget(app(db, const DesempenhoScreen()));
        await assentar(t);

        expect(find.text('Desempenho por tópico'), findsOneWidget);
        expect(find.text('2 de 3 tópicos com questões'), findsOneWidget);
        expect(
          find.textContaining('caiu 50 pontos em 30 dias'),
          findsOneWidget,
        );
        expect(
          find.textContaining('acerto 40% em 20 questões'),
          findsOneWidget,
        );
        expect(find.text('nunca estudado'), findsNothing);
        expect(find.textContaining('nunca estudado'), findsOneWidget);

        // Filtro por matéria.
        await t.ensureVisible(find.byKey(ValueKey('filtro-$mat')));
        await t.pump();
        await t.tap(find.byKey(ValueKey('filtro-$mat')));
        await assentar(t);
        expect(find.text('1 de 1 tópicos com questões'), findsOneWidget);
        expect(find.textContaining('caiu 50 pontos'), findsNothing);
        await t.ensureVisible(find.byKey(ValueKey('filtro-$port')));
        await t.pump();
        await t.tap(find.byKey(ValueKey('filtro-$port')));
        await assentar(t);

        // Detalhe pela sugestão.
        await t.tap(find.textContaining('caiu 50 pontos em 30 dias'));
        await assentar(t);
        expect(find.byType(DesempenhoTopicoScreen), findsOneWidget);
        expect(find.text('Crase'), findsOneWidget);
        expect(find.text('65%'), findsOneWidget); // 13 de 20
        expect(find.text('13 de 20'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('semana-selecionada')),
          findsOneWidget,
        );
        await t.scrollUntilVisible(
          find.byKey(const ValueKey('tabela-semanas')),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await t.tap(find.byKey(const ValueKey('tabela-semanas')));
        await assentar(t);
        expect(find.textContaining('40% (4 de 10)'), findsWidgets);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      });
    }

    testWidgets('tocar numa coluna mostra a semana', (t) async {
      t.view.physicalSize = const Size(1280, 800) * 2;
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      final s = [
        for (var i = 0; i < 12; i++)
          SemanaPlacar(
            DateTime(2026, 7, 5 + 7 * i),
            i == 3 ? const Placar(10, 7) : const Placar(),
          ),
      ];
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              child: GraficoAcertoSemanal(semanas: s, cor: Colors.blue),
            ),
          ),
        ),
      );
      // Começa na última semana com questões, não na atual (vazia).
      expect(find.text('Semana de 26/07: 70% (7 de 10)'), findsOneWidget);
      final caixa = t.getRect(find.byKey(const ValueKey('grafico-semanas')));
      final passo = (caixa.width - 28) / 12;
      await t.tapAt(Offset(caixa.left + 28 + passo * 11.5, caixa.center.dy));
      await t.pump();
      expect(find.text('Semana de 20/09: sem questões'), findsOneWidget);
      await t.tapAt(Offset(caixa.left + 28 + passo * 3.5, caixa.center.dy));
      await t.pump();
      expect(find.text('Semana de 26/07: 70% (7 de 10)'), findsOneWidget);
    });
  });
}
