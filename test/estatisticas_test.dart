import 'package:edital/logic/estatisticas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final hoje = DateTime(2026, 9, 23); // quarta
  SessaoResumo s(int diasAtras, int min, {String? m, int f = 0, int a = 0}) =>
      SessaoResumo(
        dia: DateTime(2026, 9, 23 - diasAtras, 10),
        minutos: min,
        materiaId: m,
        feitas: f,
        acertos: a,
      );

  test('totais de hoje, semana (domingo a sábado) e mês', () {
    final e = Estatisticas([
      s(0, 30),
      s(0, 20),
      s(3, 60), // domingo 20/09 — mesma semana
      s(4, 45), // sábado 19/09 — semana passada
      s(30, 90), // agosto
    ], hoje: hoje);
    expect(e.minutosHoje, 50);
    expect(e.minutosSemana, 110);
    expect(e.minutosSemanaPassada, 45);
    expect(e.minutosMes, 155);
    expect(e.minutosMesPassado, 90);
  });

  test('sequência de dias seguidos e recorde', () {
    // Estudou 22, 21, 20 (não hoje) e antes 10..14 (5 dias).
    final e = Estatisticas([
      s(1, 30),
      s(2, 30),
      s(3, 30),
      for (var i = 9; i <= 13; i++) s(i, 25),
    ], hoje: hoje);
    expect(e.sequenciaAtual, 3); // hoje ainda não conta nem quebra
    expect(e.melhorSequencia, 5);

    final comHoje = Estatisticas([s(0, 10), s(1, 10)], hoje: hoje);
    expect(comHoje.sequenciaAtual, 2);

    final quebrada = Estatisticas([s(2, 10)], hoje: hoje);
    expect(quebrada.sequenciaAtual, 0);
  });

  test('colunas por dia, semana e mês terminam no período atual', () {
    final e = Estatisticas([s(0, 40), s(7, 20)], hoje: hoje);
    final dias = e.barras(Periodo.dias);
    expect(dias, hasLength(30));
    expect(dias.last.minutos, 40);
    expect(dias.last.detalhe, 'Qua, 23/09');
    final semanas = e.barras(Periodo.semanas);
    expect(semanas, hasLength(12));
    expect(semanas.last.inicio, DateTime(2026, 9, 20));
    expect(semanas.last.minutos, 40);
    expect(semanas[10].minutos, 20);
    final meses = e.barras(Periodo.meses);
    expect(meses.last.rotulo, 'set');
    expect(meses.first.rotulo, 'out');
    expect(meses.last.minutos, 60);
  });

  test('por matéria: horas e % de acerto', () {
    final e = Estatisticas([
      s(0, 50, m: 'port', f: 20, a: 15),
      s(1, 30, m: 'port', f: 10, a: 9),
      s(1, 60, m: 'dir'),
      s(2, 25),
    ], hoje: hoje);
    final pm = e.porMateria();
    expect(pm.map((x) => x.materiaId), ['port', 'dir']);
    expect(pm.first.minutos, 80);
    expect(pm.first.acerto, closeTo(0.8, 1e-9));
    expect(pm.last.acerto, isNull);
    expect(e.totalFeitas, 30);
  });

  test('contagem regressiva', () {
    expect(diasAteProva(DateTime(2026, 12, 6), hoje), 74);
    expect(diasAteProva(null, hoje), isNull);
    expect(diasAteProva(DateTime(2026, 9, 20), hoje), -3);
  });

  test('média diária dos últimos 30 dias', () {
    final e = Estatisticas([s(0, 60), s(10, 240), s(40, 999)], hoje: hoje);
    expect(e.mediaDiaria30, 10); // 300 min / 30 dias
  });

  test('colunas guardam os minutos por matéria', () {
    final e = Estatisticas([
      s(0, 30, m: 'port'),
      s(0, 20, m: 'dir'),
      s(0, 10),
      s(1, 15, m: 'port'),
    ], hoje: hoje);
    final hojeBarra = e.barras(Periodo.dias).last;
    expect(hojeBarra.porMateria, {'port': 30, 'dir': 20, null: 10});
    final semana = e.barras(Periodo.semanas).last;
    expect(semana.porMateria['port'], 45);
  });
}
