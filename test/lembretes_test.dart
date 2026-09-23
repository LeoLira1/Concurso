import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/logic/cronometro.dart';
import 'package:edital/logic/lembretes.dart';
import 'package:edital/logic/metodo.dart';
import 'package:edital/widgets/registro_sessao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('planejador de lembretes', () {
    final agora = DateTime(2026, 9, 23, 12); // quarta, meio-dia

    test('lembrete de estudo diário, pulando hoje se já estudou', () {
      final p = planejarLembretes(
        agora: agora,
        config: const ConfigLembretes(revisoesAtivo: false),
        revisoes: const [],
        estudouHoje: true,
        proximaDoCiclo: 'Português · 55min',
      );
      expect(p, hasLength(diasAgendados - 1));
      expect(p.first.quando, DateTime(2026, 9, 24, 19));
      expect(p.first.corpo, 'Próxima do ciclo: Português · 55min');
      expect(p.first.id, idBaseEstudo + 1);

      final semFiltro = planejarLembretes(
        agora: agora,
        config: const ConfigLembretes(
          revisoesAtivo: false,
          soSeNaoEstudei: false,
        ),
        revisoes: const [],
        estudouHoje: true,
      );
      expect(semFiltro.first.quando, DateTime(2026, 9, 23, 19));
    });

    test('horário que já passou hoje não é agendado', () {
      final p = planejarLembretes(
        agora: DateTime(2026, 9, 23, 20),
        config: const ConfigLembretes(revisoesAtivo: false),
        revisoes: const [],
        estudouHoje: false,
      );
      expect(p.first.quando, DateTime(2026, 9, 24, 19));
    });

    test('revisões: conta as do dia e as atrasadas, só em dias com revisão', () {
      final p = planejarLembretes(
        agora: DateTime(2026, 9, 23, 7),
        config: const ConfigLembretes(estudoAtivo: false),
        revisoes: [
          RevisaoPendente(DateTime(2026, 9, 22), 'Crase'), // atrasada
          RevisaoPendente(DateTime(2026, 9, 23), 'Pontuação'),
          RevisaoPendente(DateTime(2026, 9, 23), 'Regência'),
          RevisaoPendente(DateTime(2026, 9, 30), 'Atos administrativos'),
        ],
        estudouHoje: false,
      );
      final hoje = p.first;
      expect(hoje.quando, DateTime(2026, 9, 23, 8));
      expect(hoje.titulo, '3 revisões para hoje');
      expect(hoje.corpo, 'Crase, Pontuação e mais 1 (1 atrasada)');
      expect(hoje.payload, payloadRevisoes);
      // Em 30/09 acumula as pendentes (supondo que não foram feitas) + a nova.
      final dia30 = p.firstWhere((l) => l.quando.day == 30);
      expect(dia30.titulo, '4 revisões para hoje');
      expect(
        p.every(
          (l) =>
              l.id >= idBaseRevisoes && l.id < idBaseRevisoes + diasAgendados,
        ),
        isTrue,
      );
    });

    test('nada agendado com os dois lembretes desligados', () {
      expect(
        planejarLembretes(
          agora: agora,
          config: const ConfigLembretes(
            estudoAtivo: false,
            revisoesAtivo: false,
          ),
          revisoes: [RevisaoPendente(agora, 'x')],
          estudouHoje: false,
        ),
        isEmpty,
      );
    });

    test('config salva e restaura', () {
      const c = ConfigLembretes(
        estudoHora: 21,
        estudoMinuto: 30,
        revisoesAtivo: false,
      );
      final r = ConfigLembretes.deJson(c.paraJson());
      expect(r.estudoHora, 21);
      expect(r.estudoMinuto, 30);
      expect(r.revisoesAtivo, isFalse);
    });
  });

  group('revisões no banco', () {
    late AppDatabase db;
    late String materia;
    late String topico;
    setUp(() async {
      db = AppDatabase(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );
      final c = await db.criarConcurso(nome: 'A', cor: 1);
      materia = await db.adicionarMateria(c, 'Português', 1);
      topico = await db.adicionarTopico(materia, 'Crase');
      await db.marcarVisto(topico, true);
    });
    tearDown(() => db.close());

    test('pendentes até uma data, com tópico e matéria', () async {
      final hoje = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      expect(await db.revisoesPendentes(hoje), isEmpty);
      final amanha = await db.revisoesPendentes(
        hoje.add(const Duration(days: 1)),
      );
      expect(amanha.single.topico.nome, 'Crase');
      expect(amanha.single.materia.nome, 'Português');
      await db.concluirRevisao(amanha.single.revisao.id);
      expect(
        await db.revisoesPendentes(hoje.add(const Duration(days: 1))),
        isEmpty,
      );
    });

    test('sessão de revisão no tópico conclui a revisão vencida', () async {
      final amanha = DateTime.now().add(const Duration(days: 1));
      await RegistroSessao(
        materiaId: materia,
        topicoId: topico,
        minutos: 25,
        metodo: Metodo.revisao,
      ).salvar(db, amanha);
      final pend = await db.revisoesPendentes(
        amanha.add(const Duration(days: 40)),
      );
      expect(pend.map((r) => r.revisao.intervaloDias), [7, 30]);
      expect(await db.estudouNoDia(amanha), isTrue);
    });
  });

  test('próximo alarme do cronômetro', () {
    var agora = DateTime(2026, 9, 23, 10);
    final c = Cronometro(
      relogio: () => agora,
      modo: ModoCronometro.pomodoro,
      metaMin: 50,
    )..iniciar();
    agora = agora.add(const Duration(minutes: 10));
    final p = c.proximoAlarme()!;
    expect(p.$1, const Duration(minutes: 15)); // fim do foco antes da meta
    expect(p.$2, 'Hora da pausa');
    c.pausar();
    expect(c.proximoAlarme(), isNull);
    c.dispose();
  });
}
