/// Cálculos das estatísticas (puros, sem banco, para poder testar).
library;

class SessaoResumo {
  const SessaoResumo({
    required this.dia,
    required this.minutos,
    this.materiaId,
    this.feitas = 0,
    this.acertos = 0,
  });

  final DateTime dia;
  final int minutos;
  final String? materiaId;
  final int feitas;
  final int acertos;
}

class Barra {
  const Barra(
    this.inicio,
    this.rotulo,
    this.detalhe,
    this.minutos, [
    this.porMateria = const {},
  ]);

  /// Início do período (dia, domingo da semana ou dia 1 do mês).
  final DateTime inicio;

  /// Rótulo curto do eixo (ex.: "16", "S38", "set").
  final String rotulo;

  /// Rótulo completo para o toque/tabela (ex.: "Qua, 16/09").
  final String detalhe;
  final int minutos;

  /// Minutos por matéria no período (chave nula = estudo livre).
  final Map<String?, int> porMateria;
}

class PorMateria {
  PorMateria(this.materiaId);
  final String materiaId;
  int minutos = 0;
  int feitas = 0;
  int acertos = 0;
  double? get acerto => feitas == 0 ? null : acertos / feitas;
}

enum Periodo { dias, semanas, meses }

const _mesesCurto = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];
const _semanaCurto = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Semanas começam no domingo, como a grade do mês.
DateTime inicioDaSemana(DateTime d) =>
    _dia(d).subtract(Duration(days: d.weekday % 7));

String _dd(int v) => v.toString().padLeft(2, '0');

class Estatisticas {
  Estatisticas(this.sessoes, {required DateTime hoje}) : hoje = _dia(hoje) {
    for (final s in sessoes) {
      final d = _dia(s.dia);
      _porDia[d] = (_porDia[d] ?? 0) + s.minutos;
      final pm = _porDiaMateria[d] ??= {};
      pm[s.materiaId] = (pm[s.materiaId] ?? 0) + s.minutos;
    }
  }

  final _porDiaMateria = <DateTime, Map<String?, int>>{};

  Map<String?, int> _materiasEntre(DateTime de, DateTime ateExclusivo) {
    final r = <String?, int>{};
    _porDiaMateria.forEach((d, m) {
      if (d.isBefore(de) || !d.isBefore(ateExclusivo)) return;
      m.forEach((k, v) => r[k] = (r[k] ?? 0) + v);
    });
    return r;
  }

  final List<SessaoResumo> sessoes;
  final DateTime hoje;
  final _porDia = <DateTime, int>{};

  int minutosNoDia(DateTime d) => _porDia[_dia(d)] ?? 0;

  int _somaEntre(DateTime de, DateTime ateExclusivo) {
    var t = 0;
    _porDia.forEach((d, m) {
      if (!d.isBefore(de) && d.isBefore(ateExclusivo)) t += m;
    });
    return t;
  }

  int get minutosHoje => minutosNoDia(hoje);

  /// Média diária dos últimos 30 dias (contando hoje e dias sem estudo).
  int get mediaDiaria30 =>
      (_somaEntre(
                hoje.subtract(const Duration(days: 29)),
                hoje.add(const Duration(days: 1)),
              ) /
              30)
          .round();

  int get minutosSemana {
    final ini = inicioDaSemana(hoje);
    return _somaEntre(ini, ini.add(const Duration(days: 7)));
  }

  int get minutosSemanaPassada {
    final ini = inicioDaSemana(hoje).subtract(const Duration(days: 7));
    return _somaEntre(ini, ini.add(const Duration(days: 7)));
  }

  int get minutosMes => _somaEntre(
    DateTime(hoje.year, hoje.month),
    DateTime(hoje.year, hoje.month + 1),
  );

  int get minutosMesPassado => _somaEntre(
    DateTime(hoje.year, hoje.month - 1),
    DateTime(hoje.year, hoje.month),
  );

  /// Dias seguidos com estudo até hoje. Se hoje ainda não teve estudo, a
  /// sequência de ontem continua valendo (o dia não acabou).
  int get sequenciaAtual {
    var d = minutosHoje > 0 ? hoje : hoje.subtract(const Duration(days: 1));
    var n = 0;
    while ((_porDia[d] ?? 0) > 0) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }

  int get melhorSequencia {
    final dias =
        _porDia.entries.where((e) => e.value > 0).map((e) => e.key).toList()
          ..sort();
    var melhor = 0, atual = 0;
    DateTime? anterior;
    for (final d in dias) {
      atual =
          anterior != null &&
              DateTime(anterior.year, anterior.month, anterior.day + 1) == d
          ? atual + 1
          : 1;
      if (atual > melhor) melhor = atual;
      anterior = d;
    }
    return melhor;
  }

  /// Colunas do período escolhido, da mais antiga à atual (última).
  List<Barra> barras(Periodo p) {
    switch (p) {
      case Periodo.dias:
        return [
          for (var i = 29; i >= 0; i--)
            () {
              final d = DateTime(hoje.year, hoje.month, hoje.day - i);
              return Barra(
                d,
                '${d.day}',
                '${_semanaCurto[d.weekday % 7]}, ${_dd(d.day)}/${_dd(d.month)}',
                minutosNoDia(d),
                _materiasEntre(d, DateTime(d.year, d.month, d.day + 1)),
              );
            }(),
        ];
      case Periodo.semanas:
        final atual = inicioDaSemana(hoje);
        return [
          for (var i = 11; i >= 0; i--)
            () {
              final ini = DateTime(atual.year, atual.month, atual.day - 7 * i);
              final fim = DateTime(ini.year, ini.month, ini.day + 6);
              return Barra(
                ini,
                '${_dd(ini.day)}/${_dd(ini.month)}',
                '${_dd(ini.day)}/${_dd(ini.month)} a ${_dd(fim.day)}/${_dd(fim.month)}',
                _somaEntre(ini, DateTime(ini.year, ini.month, ini.day + 7)),
                _materiasEntre(ini, DateTime(ini.year, ini.month, ini.day + 7)),
              );
            }(),
        ];
      case Periodo.meses:
        return [
          for (var i = 11; i >= 0; i--)
            () {
              final ini = DateTime(hoje.year, hoje.month - i);
              return Barra(
                ini,
                _mesesCurto[ini.month - 1],
                '${_mesesCurto[ini.month - 1]} ${ini.year}',
                _somaEntre(ini, DateTime(ini.year, ini.month + 1)),
                _materiasEntre(ini, DateTime(ini.year, ini.month + 1)),
              );
            }(),
        ];
    }
  }

  /// Totais por matéria (sessões sem matéria ficam de fora).
  List<PorMateria> porMateria() {
    final m = <String, PorMateria>{};
    for (final s in sessoes) {
      final id = s.materiaId;
      if (id == null) continue;
      final x = m[id] ??= PorMateria(id);
      x.minutos += s.minutos;
      x.feitas += s.feitas;
      x.acertos += s.acertos;
    }
    return m.values.toList()..sort((a, b) => b.minutos.compareTo(a.minutos));
  }

  int get totalFeitas => sessoes.fold(0, (a, s) => a + s.feitas);
  int get totalAcertos => sessoes.fold(0, (a, s) => a + s.acertos);
}

/// Dias corridos até a prova (0 = hoje, negativo = já passou).
int? diasAteProva(DateTime? prova, DateTime hoje) =>
    prova == null ? null : _dia(prova).difference(_dia(hoje)).inDays;
