import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

void main() {
  group('banco', () {
    late AppDatabase db;
    setUp(() => db = bancoMemoria());
    tearDown(() => db.close());

    test('primeiro concurso vira foco', () async {
      final a = await db.criarConcurso(nome: 'A', cor: 1);
      final b = await db.criarConcurso(nome: 'B', cor: 2);
      final foco = await db.watchFoco().first;
      expect(foco?.id, a);
      await db.definirFoco(b);
      expect((await db.watchFoco().first)?.id, b);
    });

    test('matéria com mesmo nome é compartilhada entre concursos', () async {
      final a = await db.criarConcurso(nome: 'A', cor: 1);
      final b = await db.criarConcurso(nome: 'B', cor: 2);
      final m1 = await db.adicionarMateria(a, 'Língua Portuguesa', 1);
      final m2 = await db.adicionarMateria(b, '  lingua   portuguesa ', 2);
      expect(m1, m2);

      final t = await db.adicionarTopico(m1, 'Crase');
      await db.marcarVisto(t, true);
      final deB = await db.watchMaterias(b).first;
      expect(deB.single.vistos, 1);

      // Removendo de A, continua em B com o progresso.
      await db.excluirConcurso(a);
      expect((await db.watchMaterias(b).first).single.total, 1);
      // Removendo de B, a matéria órfã é apagada.
      await db.removerMateriaDoConcurso(b, m1);
      expect(await db.todasMaterias(), isEmpty);
    });

    test('marcar visto agenda revisões em 1, 7 e 30 dias', () async {
      final c = await db.criarConcurso(nome: 'A', cor: 1);
      final m = await db.adicionarMateria(c, 'Direito', 1);
      final t = await db.adicionarTopico(m, 'Atos');
      await db.marcarVisto(t, true);
      final r = await db.select(db.revisoes).get();
      expect(r.map((e) => e.intervaloDias).toList()..sort(), [1, 7, 30]);
      await db.marcarVisto(t, false);
      expect(await db.select(db.revisoes).get(), isEmpty);
    });

    test('lote cria subtópicos com "-"', () async {
      final c = await db.criarConcurso(nome: 'A', cor: 1);
      final m = await db.adicionarMateria(c, 'Português', 1);
      await db.adicionarTopicosEmLote(
        m,
        'Concordância\n- Nominal\n- Verbal\nCrase',
      );
      final ts = await db.watchTopicos(m).first;
      expect(ts.where((t) => t.paiId == null).map((t) => t.nome), [
        'Concordância',
        'Crase',
      ]);
      expect(ts.where((t) => t.paiId != null).length, 2);
      // Progresso conta só as folhas: Nominal, Verbal, Crase.
      expect((await db.watchMaterias(c).first).single.total, 3);
    });

    test('exemplo carrega e pode ser apagado', () async {
      await db.carregarExemplo();
      expect(await db.temExemplo(), isTrue);
      final c = (await db.watchConcursos().first).single;
      expect((await db.watchMaterias(c.id).first).length, 7);
      await db.excluirConcurso(c.id);
      expect(await db.todasMaterias(), isEmpty);
    });
  });

  testWidgets('app abre na tela de boas-vindas e carrega o exemplo', (
    tester,
  ) async {
    final db = bancoMemoria();
    tester.view.physicalSize = const Size(2560, 1600); // tablet paisagem
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(EditalApp(database: db));
    await tester.pumpAndSettle();
    expect(find.text('Novo concurso'), findsOneWidget);

    await tester.tap(find.textContaining('Carregar exemplo'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Todas as matérias'), findsOneWidget);
    expect(find.text('Língua Portuguesa'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
