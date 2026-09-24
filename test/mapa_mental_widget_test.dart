import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/screens/mapa_mental_screen.dart';
import 'package:edital/screens/topico_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

Widget app(AppDatabase db, Widget home) => MultiProvider(
  providers: [
    Provider<AppDatabase>.value(value: db),
    ChangeNotifierProvider(create: (_) => AppState()),
  ],
  child: MaterialApp(theme: temaEdital(), home: home),
);

Future<void> assentar(WidgetTester t) async {
  for (var i = 0; i < 3; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await t.pumpAndSettle();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AppDatabase> abrir(WidgetTester t, {String? materia}) async {
    t.view.physicalSize = const Size(1280, 800) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final db = bancoMemoria();
    await t.runAsync(db.carregarExemplo);
    final mid = materia == null
        ? null
        : (await t.runAsync(() => db.materiaPorNome(materia)))!.id;
    await t.pumpWidget(app(db, MapaMentalScreen(materiaInicial: mid)));
    await assentar(t);
    return db;
  }

  Future<void> fechar(WidgetTester t, AppDatabase db) async {
    await t.pumpWidget(const SizedBox());
    await t.runAsync(db.close);
  }

  MapaMentalScreenState estado(WidgetTester t) =>
      t.state<MapaMentalScreenState>(find.byType(MapaMentalScreen));

  testWidgets('abre o edital inteiro ajustado à tela', (t) async {
    final db = await abrir(t);
    expect(find.text('Mapa mental'), findsOneWidget);
    expect(find.text('Edital inteiro'), findsOneWidget);
    expect(find.text('Legenda'), findsOneWidget);
    // "Ajustar à tela" deixa o mapa todo visível: o centro fica na tela.
    final raiz = estado(t).posicaoGlobal('raiz')!;
    expect(raiz.dx, inInclusiveRange(0, 1280));
    expect(raiz.dy, inInclusiveRange(0, 800));
    await fechar(t, db);
  });

  testWidgets('tocar na matéria recolhe e guarda nas preferências', (t) async {
    final db = await abrir(t);
    final port = (await t.runAsync(
      () => db.materiaPorNome('Língua Portuguesa'),
    ))!;
    final topicos = await t.runAsync(() => db.watchTopicos(port.id).first);
    final crase = topicos!.firstWhere((x) => x.nome == 'Crase');
    expect(estado(t).posicaoGlobal(crase.id), isNotNull);

    final antes = estado(t).posicaoGlobal(port.id)!;
    await t.tapAt(antes);
    await assentar(t);
    expect(estado(t).posicaoGlobal(crase.id), isNull);
    // A matéria continua no mesmo lugar da tela.
    final depois = estado(t).posicaoGlobal(port.id)!;
    expect((depois - antes).distance, lessThan(1));
    final prefs = await t.runAsync(SharedPreferences.getInstance);
    expect(prefs!.getStringList('mapa.recolhidas'), [port.id]);

    await t.tapAt(depois);
    await assentar(t);
    expect(estado(t).posicaoGlobal(crase.id), isNotNull);
    await fechar(t, db);
  });

  testWidgets('segurar mostra o resumo; tocar abre o tópico', (t) async {
    final db = await abrir(t, materia: 'Língua Portuguesa');
    final port = (await t.runAsync(
      () => db.materiaPorNome('Língua Portuguesa'),
    ))!;
    final crase = (await t.runAsync(() => db.watchTopicos(port.id).first))!
        .firstWhere((x) => x.nome == 'Crase');
    await t.runAsync(
      () => db.registrarSessao(
        dia: DateTime.now(),
        minutos: 90,
        materiaId: port.id,
        topicoId: crase.id,
        questoesFeitas: 20,
        questoesAcertos: 9,
      ),
    );
    await assentar(t);

    // Matéria no centro.
    expect(estado(t).posicaoGlobal(port.id), isNotNull);
    expect(estado(t).posicaoGlobal('raiz'), isNull);

    final p = estado(t).posicaoGlobal(crase.id)!;
    await t.longPressAt(p);
    await assentar(t);
    expect(find.text('Horas estudadas'), findsOneWidget);
    expect(find.text('1h30'), findsOneWidget);
    expect(find.text('45% (9 de 20)'), findsOneWidget);
    expect(find.text('Abrir tópico'), findsOneWidget);

    // Um toque fora fecha o resumo.
    await t.tapAt(const Offset(40, 140));
    await assentar(t);
    expect(find.text('Horas estudadas'), findsNothing);

    await t.tapAt(estado(t).posicaoGlobal(crase.id)!);
    await assentar(t);
    expect(find.byType(TopicoScreen), findsOneWidget);
    await fechar(t, db);
  });

  testWidgets('edital grande (8 × 30 × 3) abre sem erro', (t) async {
    t.view.physicalSize = const Size(1280, 800) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final db = bancoMemoria();
    await t.runAsync(() async {
      final c = await db.criarConcurso(nome: 'Grande', cor: 0xFF2F7CF6);
      for (var m = 0; m < 8; m++) {
        final mid = await db.adicionarMateria(c, 'Matéria $m', Cores.paleta[m]);
        final linhas = StringBuffer();
        for (var i = 0; i < 30; i++) {
          linhas.writeln('Tópico $i da matéria $m com um nome comprido');
          for (var s = 0; s < 3; s++) {
            linhas.writeln('- Subtópico $s');
          }
        }
        await db.adicionarTopicosEmLote(mid, linhas.toString());
      }
    });
    await t.pumpWidget(app(db, const MapaMentalScreen()));
    await assentar(t);
    expect(t.takeException(), isNull);
    expect(estado(t).escala, lessThan(0.3));
    // Aproximar e afastar pelos botões.
    await t.tap(find.byTooltip('Centralizar'));
    await t.pumpAndSettle();
    expect(estado(t).escala, 1.0);
    await t.tap(find.byTooltip('Ajustar à tela'));
    await t.pumpAndSettle();
    expect(estado(t).escala, lessThan(0.3));
    await fechar(t, db);
  });
}
