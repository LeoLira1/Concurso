/// Ciclo de estudos: uma fila circular de sessões. Cada matéria recebe
/// tempo proporcional a (peso + dificuldade). Não depende de dia da semana:
/// se você pular um dia, nada atrasa — a fila só continua de onde parou.
library;

class EntradaCiclo {
  const EntradaCiclo({
    required this.materiaId,
    required this.peso,
    required this.dificuldade,
  });

  final String materiaId;
  final int peso;
  final int dificuldade;

  int get pontos => peso + dificuldade;
}

class ItemCiclo {
  const ItemCiclo({
    required this.materiaId,
    required this.minutos,
    required this.parte,
    required this.partes,
  });

  final String materiaId;

  /// Meta de tempo desta sessão.
  final int minutos;

  /// Esta é a sessão [parte] de [partes] da matéria na volta.
  final int parte;
  final int partes;
}

class ResumoMateriaCiclo {
  const ResumoMateriaCiclo(this.materiaId, this.sessoes, this.minutosPorSessao);
  final String materiaId;
  final int sessoes;
  final int minutosPorSessao;
  int get minutos => sessoes * minutosPorSessao;
}

int _arredonda5(double v) => ((v / 5).round() * 5).clamp(10, 600);

/// Quantas sessões e de quantos minutos cada matéria recebe numa volta.
Map<String, ResumoMateriaCiclo> distribuirCiclo(
  List<EntradaCiclo> materias, {
  required int minutosTotais,
  required int blocoMin,
}) {
  final soma = materias.fold<int>(0, (s, m) => s + m.pontos);
  if (soma == 0) return {};
  return {
    for (final m in materias)
      m.materiaId: () {
        final minutosMateria = minutosTotais * m.pontos / soma;
        final n = (minutosMateria / blocoMin).round().clamp(1, 50);
        return ResumoMateriaCiclo(
          m.materiaId,
          n,
          _arredonda5(minutosMateria / n),
        );
      }(),
  };
}

/// Gera a fila de uma volta do ciclo. As sessões de cada matéria ficam
/// espalhadas ao longo da volta, evitando a mesma matéria duas vezes seguidas.
List<ItemCiclo> gerarCiclo(
  List<EntradaCiclo> materias, {
  required int minutosTotais,
  required int blocoMin,
}) {
  final dist = distribuirCiclo(
    materias,
    minutosTotais: minutosTotais,
    blocoMin: blocoMin,
  );
  if (dist.isEmpty) return const [];

  // Mais pontos primeiro: em empate de posição, a matéria mais importante vem antes.
  final ordem = [...materias]..sort((a, b) => b.pontos.compareTo(a.pontos));
  final posicionados = <(double, ItemCiclo)>[];
  for (final (i, m) in ordem.indexed) {
    final r = dist[m.materiaId]!;
    for (var k = 0; k < r.sessoes; k++) {
      final pos = (k + 0.5) / r.sessoes + i * 1e-4;
      posicionados.add((
        pos,
        ItemCiclo(
          materiaId: m.materiaId,
          minutos: r.minutosPorSessao,
          parte: k + 1,
          partes: r.sessoes,
        ),
      ));
    }
  }
  posicionados.sort((a, b) => a.$1.compareTo(b.$1));
  final fila = [for (final p in posicionados) p.$2];

  // Desfaz repetições seguidas trocando com o próximo item diferente.
  for (var i = 1; i < fila.length; i++) {
    if (fila[i].materiaId != fila[i - 1].materiaId) continue;
    for (var j = i + 1; j < fila.length; j++) {
      if (fila[j].materiaId != fila[i - 1].materiaId) {
        final t = fila[i];
        fila[i] = fila[j];
        fila[j] = t;
        break;
      }
    }
  }
  // Renumera "parte x de n" na ordem final.
  final contagem = <String, int>{};
  return [
    for (final it in fila)
      ItemCiclo(
        materiaId: it.materiaId,
        minutos: it.minutos,
        parte: contagem[it.materiaId] = (contagem[it.materiaId] ?? 0) + 1,
        partes: it.partes,
      ),
  ];
}
