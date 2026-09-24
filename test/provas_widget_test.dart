import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/data/provas_db.dart';
import 'package:edital/logic/provas.dart';
import 'package:edital/screens/colar_prova_screen.dart';
import 'package:edital/screens/provas_screen.dart';
import 'package:edital/screens/questoes_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

final jsonAraucaria = File('test/dados/araucaria_2019.json').readAsStringSync();

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

void main() {
  testWidgets('colar prova: conferir, ver prévia e importar', (t) async {
    final db = bancoMemoria();
    t.view.physicalSize = const Size(2560, 1600);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(app(db, ColarProvaScreen(textoInicial: jsonAraucaria)));
    await assentar(t);
    await t.tap(find.byKey(const ValueKey('ler-prova')));
    await assentar(t);
    expect(find.text('Prévia da prova'), findsOneWidget);
    expect(find.textContaining('36 questões · 4 descartadas'), findsOneWidget);
    expect(find.text('36 questões prontas para importar.'), findsOneWidget);
    expect(
      find.textContaining('Conhecimentos gerais do município'),
      findsWidgets,
    );

    await t.tap(find.byKey(const ValueKey('importar-prova')));
    await assentar(t);
    expect(find.text('Prova importada'), findsOneWidget);
    expect(
      await t.runAsync(() => db.select(db.questoesProva).get()),
      hasLength(36),
    );
    await t.pumpWidget(const SizedBox());
    await t.runAsync(db.close);
  });

  testWidgets('prévia destaca resposta diferente do gabarito', (t) async {
    final db = bancoMemoria();
    t.view.physicalSize = const Size(2560, 1600);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final m = jsonDecode(jsonAraucaria) as Map<String, dynamic>;
    ((m['questoes'] as List).first as Map)['resposta'] = 'A';
    await t.pumpWidget(app(db, ColarProvaScreen(textoInicial: jsonEncode(m))));
    await assentar(t);
    await t.tap(find.byKey(const ValueKey('ler-prova')));
    await assentar(t);
    expect(
      find.textContaining('Resposta A, mas o gabarito lido diz C'),
      findsWidgets,
    );
    final importar = t.widget<FilledButton>(
      find.ancestor(
        of: find.text('Importar'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    );
    expect(importar.onPressed, isNull);
    await t.tap(find.text('Vale C'));
    await t.pump();
    expect(
      t
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Importar'),
              matching: find.byWidgetPredicate((w) => w is FilledButton),
            ),
          )
          .onPressed,
      isNotNull,
    );
    await t.pumpWidget(const SizedBox());
    await t.runAsync(db.close);
  });

  testWidgets('treino: responde, mostra correção, obs e motivo', (t) async {
    final db = bancoMemoria();
    t.view.physicalSize = const Size(2560, 1600);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final qs = (await t.runAsync(() async {
      final l = lerProva(jsonAraucaria);
      await db.ligarTopicos(l.prova!);
      await db.importarProva(l.prova!);
      final todas = await db.questoesCompletas();
      return [
        todas.firstWhere((q) => q.questao.numero == 2), // texto T1, obs
        todas.firstWhere((q) => q.questao.numero == 37), // desatualizada
      ];
    }))!;
    await t.pumpWidget(
      app(db, QuestoesScreen(questoes: qs, modo: ModoQuestoes.treino)),
    );
    await assentar(t);
    expect(find.byKey(const ValueKey('abrir-texto')), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('abrir-texto')));
    await assentar(t);
    expect(find.textContaining('BigData Corp'), findsOneWidget);
    await t.tapAt(const Offset(20, 20)); // fecha o texto
    await assentar(t);

    await t.tap(find.byKey(const ValueKey('alt-B'))); // errada (certa: A)
    await t.pump();
    await t.tap(find.byKey(const ValueKey('responder')));
    await assentar(t);
    expect(find.text('Errou. A certa é A.'), findsOneWidget);
    await t.scrollUntilVisible(
      find.text('Pegadinha'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('sublinhado no original'), findsOneWidget);
    expect(find.text('Por que errou?'), findsOneWidget);
    await t.tap(find.text('Pegadinha'));
    await assentar(t);
    final r = (await t.runAsync(() => db.select(db.respostas).get()))!;
    expect(r.single.acertou, isFalse);
    expect(r.single.motivoErro, 'pegadinha');

    await t.tap(find.byKey(const ValueKey('proxima')));
    await assentar(t);
    expect(find.text('Lei mudou'), findsOneWidget);
    expect(find.text('Prova de 2019: confira a lei atual'), findsOneWidget);
    await t.scrollUntilVisible(
      find.byKey(const ValueKey('alt-C')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.byKey(const ValueKey('alt-C')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('responder')));
    await assentar(t);
    expect(find.text('Certa!'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('concluir')));
    await assentar(t);
    expect(find.text('Treino concluído'), findsOneWidget);
    // Virou sessão de estudo com método Questões.
    final ss = (await t.runAsync(() => db.select(db.sessoes).get()))!;
    expect(ss.map((s) => s.metodo).toSet(), {'questoes'});
    expect(ss.every((s) => s.origem == 'provas'), isTrue);
    await t.pumpWidget(const SizedBox());
    await t.runAsync(db.close);
  });

  testWidgets('simulado: correção só no final', (t) async {
    final db = bancoMemoria();
    t.view.physicalSize = const Size(2560, 1600);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final qs = (await t.runAsync(() async {
      final l = lerProva(jsonAraucaria);
      await db.importarProva(l.prova!);
      return db.sortear(const FiltroQuestoes(), 3);
    }))!;
    await t.pumpWidget(
      app(
        db,
        QuestoesScreen(questoes: qs, modo: ModoQuestoes.simulado, minutos: 12),
      ),
    );
    await assentar(t);
    expect(find.textContaining('12:0'), findsNothing); // relógio corre
    await t.tap(find.byKey(const ValueKey('alt-A')));
    await t.pump();
    expect(find.textContaining('Certa!'), findsNothing);
    expect(find.textContaining('Errou'), findsNothing);
    await t.tap(find.byKey(const ValueKey('entregar')));
    await assentar(t);
    await t.tap(find.text('Entregar').last); // confirma com 2 em branco
    await assentar(t);
    expect(find.text('Resultado do simulado'), findsOneWidget);
    expect(find.textContaining('2 em branco'), findsOneWidget);
    expect(await t.runAsync(() => db.select(db.respostas).get()), hasLength(1));
    await t.pumpWidget(const SizedBox());
    await t.runAsync(db.close);
  });

  testWidgets('gerenciar: detalhes e excluir prova', (t) async {
    final db = bancoMemoria();
    t.view.physicalSize = const Size(2560, 1600);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.runAsync(() => db.importarProva(lerProva(jsonAraucaria).prova!));
    await t.pumpWidget(app(db, const ProvasScreen()));
    await assentar(t);
    expect(find.text('36 questões salvas'), findsOneWidget);
    await t.tap(find.textContaining('Araucária'));
    await assentar(t);
    expect(find.textContaining('4 descartadas'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('excluir-prova')));
    await assentar(t);
    await t.tap(find.text('Excluir'));
    await assentar(t);
    expect(await t.runAsync(() => db.select(db.provas).get()), isEmpty);
    expect(find.text('0 questões salvas'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await t.runAsync(db.close);
  });
}
