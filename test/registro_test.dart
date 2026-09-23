import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/logic/metodo.dart';
import 'package:edital/widgets/registro_sessao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late String materia;
  setUp(() async {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    final c = await db.criarConcurso(nome: 'A', cor: 1);
    materia = await db.adicionarMateria(c, 'Português', 1);
  });
  tearDown(() => db.close());

  test('registro completo é salvo', () async {
    final t = await db.adicionarTopico(materia, 'Crase');
    final r = RegistroSessao(
      materiaId: materia,
      topicoId: t,
      minutos: 50,
      metodo: Metodo.questoes,
      feitas: 20,
      acertos: 16,
      paginas: 12,
      pontoParada: '  parei na questão 21  ',
      marcarVisto: true,
    );
    await r.salvar(db, DateTime(2026, 9, 23, 14));
    final s = (await db.select(db.sessoes).get()).single;
    expect(s.metodo, 'questoes');
    expect(Metodo.deChave(s.metodo), Metodo.questoes);
    expect(s.questoesFeitas, 20);
    expect(s.questoesAcertos, 16);
    expect(s.paginas, 12);
    expect(s.pontoParada, 'parei na questão 21');
    expect(s.dia, DateTime(2026, 9, 23));
    expect((await db.topico(t))!.visto, isTrue);
    expect(await db.select(db.revisoes).get(), hasLength(3));
  });

  test(
    'acertos nunca passam das feitas; ponto de parada vazio vira nulo',
    () async {
      await db.registrarSessao(
        dia: DateTime.now(),
        minutos: 10,
        materiaId: materia,
        questoesFeitas: 5,
        questoesAcertos: 9,
        pontoParada: '   ',
      );
      final s = (await db.select(db.sessoes).get()).single;
      expect(s.questoesAcertos, 5);
      expect(s.pontoParada, isNull);
    },
  );

  test('mostra o ponto de parada mais recente da matéria', () async {
    expect(await db.watchUltimaParada(materia).first, isNull);
    await db.registrarSessao(
      dia: DateTime.now(),
      minutos: 30,
      materiaId: materia,
      pontoParada: 'antigo',
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await db.registrarSessao(
      dia: DateTime.now(),
      minutos: 30,
      materiaId: materia,
      pontoParada: 'novo',
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    // Sessão sem ponto de parada não apaga o último ponto.
    await db.registrarSessao(
      dia: DateTime.now(),
      minutos: 30,
      materiaId: materia,
    );
    expect((await db.watchUltimaParada(materia).first)?.pontoParada, 'novo');
  });
}
