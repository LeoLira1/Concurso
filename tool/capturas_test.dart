// Gera capturas de tela do app com dados de exemplo.
// Uso: flutter test tool/capturas_test.dart --update-goldens
// As imagens vão para tool/capturas/.
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/screens/concursos_screen.dart';
import 'package:edital/screens/edital_screen.dart';
import 'package:edital/screens/home_screen.dart';
import 'package:edital/screens/materia_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/theme.dart';
import 'package:edital/util/texto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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

Widget app(AppDatabase db, Widget home, {AppState? estado}) => MultiProvider(
  providers: [
    Provider<AppDatabase>.value(value: db),
    ChangeNotifierProvider(create: (_) => estado ?? AppState()),
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

Future<void> assentar(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(carregarFontes);

  Future<void> captura(
    WidgetTester tester,
    String nome,
    Size tamanho,
    Widget Function(AppDatabase db) tela, {
    Future<void> Function(WidgetTester t)? antes,
  }) async {
    final db = (await tester.runAsync(popular))!;
    tester.view.physicalSize = tamanho * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(tela(db));
    await assentar(tester);
    if (antes != null) {
      await antes(tester);
      await assentar(tester);
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('capturas/$nome.png'),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  }

  const paisagem = Size(1280, 800);
  const retrato = Size(800, 1280);
  const celular = Size(412, 915);

  testWidgets(
    'tablet paisagem',
    (t) => captura(
      t,
      '1_tablet_paisagem',
      paisagem,
      (db) => app(db, const HomeScreen()),
    ),
  );

  testWidgets(
    'tablet paisagem filtrado',
    (t) => captura(
      t,
      '2_tablet_filtro_materia',
      paisagem,
      (db) => app(db, const HomeScreen()),
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

  testWidgets('edital', (t) async {
    late String id;
    await captura(t, '4_edital', paisagem, (db) {
      return app(
        db,
        Builder(
          builder: (context) {
            return FutureBuilder(
              future: db.watchFoco().first,
              builder: (_, s) => s.data == null
                  ? const SizedBox()
                  : EditalScreen(concursoId: id = s.data!.id),
            );
          },
        ),
      );
    });
    expect(id, isNotEmpty);
  });

  testWidgets(
    'materia',
    (t) => captura(t, '5_materia', paisagem, (db) {
      return app(
        db,
        FutureBuilder(
          future: db.materiaPorNome('Língua Portuguesa'),
          builder: (_, s) => s.data == null
              ? const SizedBox()
              : MateriaScreen(materiaId: s.data!.id, concursoId: ''),
        ),
      );
    }),
  );

  testWidgets(
    'tablet retrato',
    (t) => captura(
      t,
      '6_tablet_retrato',
      retrato,
      (db) => app(db, const HomeScreen()),
    ),
  );

  testWidgets(
    'celular',
    (t) =>
        captura(t, '7_celular', celular, (db) => app(db, const HomeScreen())),
  );
}
