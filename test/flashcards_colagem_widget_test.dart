import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/screens/colar_flashcards_screen.dart';
import 'package:edital/screens/materia_screen.dart';
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

String flashcardsJson() => jsonEncode([
  {
    'materia': 'Língua Portuguesa',
    'topico': 'Concordância nominal e verbal',
    'subtopico': 'Verbo haver',
    'frente': 'Quando o verbo haver fica no singular?',
    'verso': 'Quando significa existir ou indica tempo decorrido.',
  },
  {
    'materia': 'Língua Portuguesa',
    'topico': 'Concordância nominal e verbal',
    'frente': 'Regra geral da concordância verbal?',
    'verso': 'O verbo concorda com o sujeito.',
  },
  {'materia': 'Língua Portuguesa', 'topico': 'Crase', 'frente': 'Sem verso'},
]);

void main() {
  for (final (nome, tamanho) in [('deitado', deitado), ('em pé', emPe)]) {
    testWidgets('colar flashcards: prévia e importar ($nome)', (t) async {
      final db = bancoMemoria();
      addTearDown(db.close);
      tela(t, tamanho);
      final pm = await db.criarConcurso(nome: 'PM', cor: 1);
      final m = await db.adicionarMateria(pm, 'Língua Portuguesa', 2);
      await t.pumpWidget(
        app(
          db,
          ColarFlashcardsScreen(concursoId: pm, textoInicial: flashcardsJson()),
        ),
      );
      await assentar(t);
      expect(find.text('Colar flashcards'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('conferir-flashcards')));
      await assentar(t);

      expect(find.text('2 novos'), findsOneWidget);
      expect(find.text('1 com erro (fica de fora)'), findsOneWidget);
      expect(
        find.text('Concordância nominal e verbal › Verbo haver'),
        findsOneWidget,
      );
      expect(find.text('Tópico novo no edital'), findsWidgets);
      expect(find.text('Subtópico novo'), findsOneWidget);
      expect(find.text('Cartão 3: falta o verso.'), findsOneWidget);
      expect(find.text('Importar 2 cartões'), findsOneWidget);
      expect(t.takeException(), isNull);

      await t.tap(find.byKey(const ValueKey('importar-flashcards')));
      await assentar(t);
      expect(find.text('2 cartões importados'), findsOneWidget);
      await t.tap(find.text('OK'));
      await assentar(t);

      final cartoes = (await t.runAsync(
        () => db.watchCartoesParaRevisar(materiaId: m, concursoId: pm).first,
      ))!;
      expect(
        cartoes.map((c) => c.cartao.frente),
        [
          'Quando o verbo haver fica no singular?',
          'Regra geral da concordância verbal?',
        ]..sort(),
      );
      expect(cartoes.every((c) => c.cartao.caixa == 0), isTrue);
      await t.pumpWidget(const SizedBox());
      await assentar(t);
    });
  }

  testWidgets('colar de novo mostra "já existe" e não importa', (t) async {
    final db = bancoMemoria();
    addTearDown(db.close);
    tela(t, deitado);
    final pm = await db.criarConcurso(nome: 'PM', cor: 1);
    await db.adicionarMateria(pm, 'Língua Portuguesa', 2);
    final um = jsonEncode([jsonDecode(flashcardsJson())[0]]);
    await t.pumpWidget(
      app(db, ColarFlashcardsScreen(concursoId: pm, textoInicial: um)),
    );
    await assentar(t);
    await t.tap(find.byKey(const ValueKey('conferir-flashcards')));
    await assentar(t);
    await t.tap(find.byKey(const ValueKey('importar-flashcards')));
    await assentar(t);
    await t.tap(find.text('OK'));
    await assentar(t);

    // Abre a tela de novo, do zero.
    await t.pumpWidget(const SizedBox());
    await assentar(t);
    await t.pumpWidget(
      app(db, ColarFlashcardsScreen(concursoId: pm, textoInicial: um)),
    );
    await assentar(t);
    await t.tap(find.byKey(const ValueKey('conferir-flashcards')));
    await assentar(t);
    expect(find.text('0 novos'), findsOneWidget);
    expect(find.text('1 já existe (fica de fora)'), findsOneWidget);
    expect(find.byKey(const ValueKey('importar-flashcards')), findsNothing);
    await t.pumpWidget(const SizedBox());
    await assentar(t);
  });

  testWidgets('botão no cartão Flashcards do tópico', (t) async {
    final db = bancoMemoria();
    addTearDown(db.close);
    tela(t, deitado);
    final pm = await db.criarConcurso(nome: 'PM', cor: 1);
    final m = await db.adicionarMateria(pm, 'Língua Portuguesa', 2);
    final crase = await db.adicionarTopico(m, 'Crase');
    await t.pumpWidget(app(db, TopicoScreen(topicoId: crase)));
    await assentar(t);
    expect(find.text('Novo cartão'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('colar-flashcards')));
    await assentar(t);
    // Abre já apontando para o tópico aberto.
    expect(find.byType(ColarFlashcardsScreen), findsOneWidget);
    expect(find.textContaining('vai para Crase'), findsOneWidget);
    await t.enterText(
      find.byKey(const ValueKey('texto-flashcards')),
      '[{"frente":"Crase antes de verbo?","verso":"Nunca."}]',
    );
    await t.tap(find.byKey(const ValueKey('conferir-flashcards')));
    await assentar(t);
    expect(find.text('1 novo'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('importar-flashcards')));
    await assentar(t);
    expect(find.text('1 cartão importado'), findsOneWidget);
    await t.tap(find.text('OK'));
    await assentar(t);
    expect(
      await t.runAsync(() => db.watchFlashcards(crase).first),
      hasLength(1),
    );
    await t.pumpWidget(const SizedBox());
    await assentar(t);
  });

  testWidgets('botão no alto da tela da matéria', (t) async {
    final db = bancoMemoria();
    addTearDown(db.close);
    tela(t, emPe);
    final pm = await db.criarConcurso(nome: 'PM', cor: 1);
    final m = await db.adicionarMateria(pm, 'Língua Portuguesa', 2);
    await t.pumpWidget(app(db, MateriaScreen(materiaId: m, concursoId: pm)));
    await assentar(t);
    await t.tap(find.byKey(const ValueKey('colar-flashcards')));
    await assentar(t);
    expect(find.byType(ColarFlashcardsScreen), findsOneWidget);
    expect(find.textContaining('vai para'), findsNothing);
    await t.pumpWidget(const SizedBox());
    await assentar(t);
  });
}
