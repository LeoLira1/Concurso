import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/data/questoes_topico_db.dart';
import 'package:edital/logic/questoes_topico.dart';
import 'package:edital/screens/colar_questoes_screen.dart';
import 'package:edital/screens/resolver_topico_screen.dart';
import 'package:edital/screens/topico_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

Widget app(AppDatabase db, Widget home) => MultiProvider(
  providers: [
    Provider.value(value: db),
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

void tela(WidgetTester t, Size s) {
  t.view.physicalSize = s * 2;
  t.view.devicePixelRatio = 2;
  addTearDown(t.view.reset);
}

const deitado = Size(1280, 800);
const emPe = Size(800, 1280);

String questoesJson() => jsonEncode([
  {
    'materia': 'Língua Portuguesa',
    'topico': 'Conjunções',
    'subtopico': 'Adversativas',
    'dificuldade': 2,
    'enunciado': 'Em "Estudei, mas não passei", a conjunção "mas" é:',
    'alternativas': {
      'A': 'aditiva',
      'B': 'conclusiva',
      'C': 'adversativa',
      'D': 'explicativa',
      'E': 'alternativa',
    },
    'gabarito': 'C',
    'explicacao': '"Mas" liga ideias opostas.',
  },
  {
    'materia': 'Língua Portuguesa',
    'topico': 'Conjunções',
    'subtopico': 'Conclusivas',
    'dificuldade': 3,
    'enunciado': 'Em "Estudou, logo passou", a conjunção "logo" é:',
    'alternativas': {'A': 'conclusiva', 'B': 'adversativa'},
    'gabarito': 'A',
    'explicacao': '',
  },
  {'materia': 'Língua Portuguesa', 'enunciado': 'Sem tópico'},
]);

void main() {
  for (final (nome, tamanho) in [('deitado', deitado), ('em pé', emPe)]) {
    testWidgets('colar questões: prévia e importar ($nome)', (t) async {
      final db = bancoMemoria();
      addTearDown(db.close);
      tela(t, tamanho);
      final pm = await db.criarConcurso(nome: 'PM', cor: 1);
      final m = await db.adicionarMateria(pm, 'Língua Portuguesa', 2);
      await t.pumpWidget(
        app(
          db,
          ColarQuestoesScreen(concursoId: pm, textoInicial: questoesJson()),
        ),
      );
      await assentar(t);
      await t.tap(find.byKey(const ValueKey('conferir-questoes')));
      await assentar(t);

      expect(find.text('2 novas'), findsOneWidget);
      expect(find.text('1 com erro (fica de fora)'), findsOneWidget);
      expect(find.text('Conjunções › Adversativas'), findsOneWidget);
      expect(find.text('Tópico novo no edital'), findsWidgets);
      expect(find.textContaining('Questão 3: falta o tópico'), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.tap(find.byKey(const ValueKey('importar-questoes')));
      await assentar(t);
      expect(find.text('2 questões importadas'), findsOneWidget);
      await t.tap(find.text('OK'));
      await assentar(t);

      final qs = (await t.runAsync(
        () => db.watchQuestoesTopico(materiaId: m).first,
      ))!;
      expect(qs, hasLength(2));
      expect(qs.map((q) => q.caminho), [
        'Conjunções › Adversativas',
        'Conjunções › Conclusivas',
      ]);
      await t.pumpWidget(const SizedBox());
      await assentar(t);
    });

    testWidgets('resolver: tocar, corrigir, suspeito e sessão ($nome)', (
      t,
    ) async {
      final db = bancoMemoria();
      addTearDown(db.close);
      tela(t, tamanho);
      final pm = await db.criarConcurso(nome: 'PM', cor: 1);
      final m = await db.adicionarMateria(pm, 'Língua Portuguesa', 2);
      await db.importarQuestoesTopico(
        lerQuestoes(questoesJson()),
        concursoId: pm,
      );
      final fila = await db.filaQuestoesTopico(materiaId: m);
      expect(fila.first.questao.dificuldade, 2);
      await t.pumpWidget(
        app(db, ResolverTopicoScreen(titulo: 'Português', fila: fila)),
      );
      await assentar(t);

      // 1ª: erra (marca B). Mostra a certa e a explicação.
      await t.tap(find.byKey(const ValueKey('alt-B')));
      await assentar(t);
      expect(find.text('Errou. A certa é C.'), findsOneWidget);
      expect(find.text('"Mas" liga ideias opostas.'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('suspeito')));
      await assentar(t);
      expect(
        await t.runAsync(
          () => db.watchQuestoesTopico(materiaId: m, soSuspeitas: true).first,
        ),
        hasLength(1),
      );
      expect(find.text('Gabarito suspeito'), findsWidgets);
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(const ValueKey('proxima')));
      await assentar(t);

      // 2ª: acerta.
      await t.tap(find.byKey(const ValueKey('alt-A')));
      await assentar(t);
      expect(find.text('Certa!'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('proxima')));
      await assentar(t);

      // A errada voltou no fim da fila; agora acerta.
      expect(find.text('Voltou: você errou'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('alt-C')));
      await assentar(t);
      expect(find.text('Concluir'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('proxima')));
      await assentar(t);

      // Conta a primeira resposta de cada questão: 1 de 2.
      expect(find.text('1 de 2 certas (50%)'), findsOneWidget);
      final sessoes = (await t.runAsync(() => db.watchTodasSessoes().first))!;
      expect(sessoes.fold<int>(0, (a, s) => a + s.questoesFeitas), 2);
      expect(sessoes.fold<int>(0, (a, s) => a + s.questoesAcertos), 1);
      expect(sessoes.every((s) => s.metodo == 'questoes'), isTrue);
      await t.pumpWidget(const SizedBox());
      await assentar(t);
    });
  }

  testWidgets('tela do tópico mostra o cartão de questões', (t) async {
    final db = bancoMemoria();
    addTearDown(db.close);
    tela(t, deitado);
    final pm = await db.criarConcurso(nome: 'PM', cor: 1);
    final m = await db.adicionarMateria(pm, 'Língua Portuguesa', 2);
    await db.importarQuestoesTopico(
      lerQuestoes(questoesJson()),
      concursoId: pm,
    );
    final conj = (await db.watchTopicos(m).first).firstWhere(
      (x) => x.nome == 'Conjunções',
    );
    final q = (await db.watchQuestoesTopico(topicoId: conj.id).first).first;
    await db.marcarSuspeito(q.id, true);
    await t.pumpWidget(app(db, TopicoScreen(topicoId: conj.id)));
    await assentar(t);
    await t.scrollUntilVisible(
      find.byKey(const ValueKey('colar-questoes')),
      200,
    );
    expect(find.text('Questões'), findsOneWidget);
    expect(find.text('2 questões · 2 para hoje'), findsOneWidget);
    expect(find.text('Resolver 2'), findsOneWidget);
    expect(find.text('1 gabarito suspeito'), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await assentar(t);
  });
}
