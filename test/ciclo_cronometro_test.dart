import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/logic/ciclo.dart';
import 'package:edital/logic/cronometro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ciclo', () {
    const mats = [
      EntradaCiclo(materiaId: 'port', peso: 5, dificuldade: 3), // 8 pts
      EntradaCiclo(materiaId: 'info', peso: 1, dificuldade: 1), // 2 pts
      EntradaCiclo(materiaId: 'dir', peso: 4, dificuldade: 4), // 8 pts
      EntradaCiclo(materiaId: 'mat', peso: 3, dificuldade: 5), // 8 pts
    ];

    test('tempo proporcional a peso + dificuldade', () {
      final d = distribuirCiclo(mats, minutosTotais: 1300, blocoMin: 60);
      // 1300 min * 8/26 = 400 min -> 7 sessões de ~55 min
      expect(d['port']!.sessoes, 7);
      expect(d['info']!.sessoes, 2); // 100 min
      expect(d['port']!.minutos, greaterThan(d['info']!.minutos * 3));
    });

    test(
      'fila não repete a mesma matéria seguida e cobre todas as sessões',
      () {
        final fila = gerarCiclo(mats, minutosTotais: 1300, blocoMin: 60);
        final d = distribuirCiclo(mats, minutosTotais: 1300, blocoMin: 60);
        expect(fila.length, d.values.fold<int>(0, (s, r) => s + r.sessoes));
        for (var i = 1; i < fila.length; i++) {
          expect(
            fila[i].materiaId,
            isNot(fila[i - 1].materiaId),
            reason: 'posição $i',
          );
        }
        final partesPort = fila
            .where((f) => f.materiaId == 'port')
            .map((f) => f.parte);
        expect(partesPort, [1, 2, 3, 4, 5, 6, 7]);
      },
    );

    test('ciclo vazio', () {
      expect(gerarCiclo(const [], minutosTotais: 600, blocoMin: 60), isEmpty);
    });

    test('avançar dá a volta e conta voltas (banco)', () async {
      final db = AppDatabase(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );
      final c = await db.criarConcurso(nome: 'A', cor: 1);
      final p = await db.adicionarMateria(c, 'Português', 1);
      await db.adicionarMateria(c, 'Informática', 2);
      await db.definirPesoDificuldade(c, p, peso: 5, dificuldade: 5);
      await db.configurarCiclo(c, minutosTotais: 240, blocoMin: 60);

      var e = await db.watchCiclo(c).first;
      final n = e.fila.length;
      expect(n, greaterThan(1));
      expect(
        e.fila.where((f) => f.materiaId == p).length,
        greaterThan(e.fila.where((f) => f.materiaId != p).length),
      );

      for (var i = 0; i < n; i++) {
        await db.avancarCiclo(c, n);
      }
      e = await db.watchCiclo(c).first;
      expect(e.posicao, 0);
      expect(e.concurso!.cicloVoltas, 1);

      await db.definirPesoDificuldade(c, p, noCiclo: false);
      e = await db.watchCiclo(c).first;
      expect(e.fila.every((f) => f.materiaId != p), isTrue);
      await db.close();
    });
  });

  group('cronômetro', () {
    late DateTime agora;
    DateTime relogio() => agora;
    setUp(() => agora = DateTime(2026, 9, 23, 10));

    test('conta só o tempo rodando (horas líquidas)', () {
      final c = Cronometro(relogio: relogio)..iniciar();
      agora = agora.add(const Duration(minutes: 10));
      c.pausar();
      agora = agora.add(const Duration(minutes: 30)); // pausado: não conta
      c.iniciar();
      agora = agora.add(const Duration(minutes: 5));
      c.atualizar();
      expect(c.liquido, const Duration(minutes: 15));
      c.dispose();
    });

    test('alarme ao bater a meta', () {
      final alarmes = <String>[];
      final c = Cronometro(relogio: relogio, metaMin: 20)
        ..aoAlarmar = alarmes.add
        ..iniciar();
      agora = agora.add(const Duration(minutes: 19));
      c.atualizar();
      expect(alarmes, isEmpty);
      agora = agora.add(const Duration(minutes: 2));
      c.atualizar();
      expect(alarmes, ['Meta da sessão atingida']);
      agora = agora.add(const Duration(minutes: 5));
      c.atualizar();
      expect(alarmes.length, 1); // só uma vez
      c.dispose();
    });

    test('pomodoro: pausa não conta como líquido', () {
      final alarmes = <String>[];
      final c =
          Cronometro(
              relogio: relogio,
              modo: ModoCronometro.pomodoro,
              focoMin: 25,
              pausaMin: 5,
            )
            ..aoAlarmar = alarmes.add
            ..iniciar();
      // 25 foco + 5 pausa + 10 foco = 40 min de relógio, 35 líquidos
      agora = agora.add(const Duration(minutes: 40));
      c.atualizar();
      expect(c.liquido, const Duration(minutes: 35));
      expect(c.fase, Fase.foco);
      expect(c.pomodoros, 1);
      expect(c.faseDecorrido, const Duration(minutes: 10));
      expect(alarmes, isNotEmpty);
      c.dispose();
    });

    test('salvar e restaurar mantém o tempo (inclusive app fechado)', () {
      final c = Cronometro(relogio: relogio, materiaId: 'x', metaMin: 50)
        ..iniciar();
      agora = agora.add(const Duration(minutes: 12));
      final json = c.paraJson();
      c.dispose();
      agora = agora.add(
        const Duration(minutes: 3),
      ); // app fechado, ainda rodando
      final r = Cronometro.deJson(json, relogio: relogio);
      expect(r.liquido, const Duration(minutes: 15));
      expect(r.rodando, isTrue);
      expect(r.materiaId, 'x');
      r.dispose();
    });
  });
}
