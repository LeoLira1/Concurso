/// Desempenho por tópico (etapa 13): % de acerto, tendência (últimos 30
/// dias contra os 30 anteriores), semanas e o que revisar primeiro. Tudo
/// puro, a partir das sessões (que já trazem as respostas das provas).
library;

import 'dart:math' as math;

import 'estatisticas.dart' show inicioDaSemana;

/// Janela da tendência, em dias.
const janelaTendencia = 30;

/// Questões mínimas em cada janela para a tendência valer.
const minimoTendencia = 5;

/// Variação (em pontos percentuais) que conta como subiu ou caiu.
const limiarTendencia = 10;

/// Acerto baixo: abaixo de 60% com pelo menos 10 questões (o mesmo do mapa).
const minimoFraco = 10;
const acertoFraco = 0.6;

/// Sem estudar há tantos dias = parado.
const diasParado = 21;

/// Semanas no gráfico do detalhe e na minilinha da lista.
const semanasDetalhe = 12;
const semanasMinilinha = 8;

/// Sugestões em "Revise primeiro".
const maximoSugestoes = 5;

/// Um dia de estudo de um tópico (sessão ou respostas de prova).
class RegistroTopico {
  const RegistroTopico({
    required this.topicoId,
    required this.dia,
    this.feitas = 0,
    this.acertos = 0,
    this.minutos = 0,
  });
  final String topicoId;
  final DateTime dia;
  final int feitas;
  final int acertos;
  final int minutos;
}

/// Tópico do edital (só o que o painel usa).
class TopicoDesempenho {
  const TopicoDesempenho({
    required this.id,
    required this.nome,
    required this.materiaId,
    this.paiId,
    this.ordem = 0,
  });
  final String id;
  final String nome;
  final String materiaId;
  final String? paiId;
  final int ordem;
}

/// Questões feitas e certas num período.
class Placar {
  const Placar([this.feitas = 0, this.acertos = 0]);
  final int feitas;
  final int acertos;

  double? get acerto => feitas == 0 ? null : acertos / feitas;
  Placar operator +(Placar o) => Placar(feitas + o.feitas, acertos + o.acertos);
}

enum Tendencia { subiu, caiu, estavel, semDados }

/// Por que um tópico entrou em "Revise primeiro".
enum MotivoRevisao { caiu, fraco, parado }

/// Uma semana (começa no domingo) com o placar dela.
class SemanaPlacar {
  const SemanaPlacar(this.inicio, this.placar);
  final DateTime inicio;
  final Placar placar;
}

/// Números de um tópico (somando os subtópicos dele).
class Desempenho {
  Desempenho({
    required this.topico,
    required this.total,
    required this.recente,
    required this.anterior,
    required this.ultimoEstudo,
    required this.semanas,
    required this.hoje,
  });

  final TopicoDesempenho topico;
  final Placar total;

  /// Últimos [janelaTendencia] dias (com hoje) e os [janelaTendencia]
  /// antes deles.
  final Placar recente;
  final Placar anterior;
  final DateTime? ultimoEstudo;

  /// As últimas [semanasDetalhe] semanas, a mais antiga primeiro.
  final List<SemanaPlacar> semanas;
  final DateTime hoje;

  double? get acerto => total.acerto;

  /// Pontos percentuais de diferença (recente − anterior), quando as duas
  /// janelas têm questões suficientes.
  int? get variacao {
    if (recente.feitas < minimoTendencia || anterior.feitas < minimoTendencia) {
      return null;
    }
    return ((recente.acerto! - anterior.acerto!) * 100).round();
  }

  Tendencia get tendencia {
    final v = variacao;
    if (v == null) return Tendencia.semDados;
    if (v >= limiarTendencia) return Tendencia.subiu;
    if (v <= -limiarTendencia) return Tendencia.caiu;
    return Tendencia.estavel;
  }

  bool get fraco =>
      total.feitas >= minimoFraco && total.acertos / total.feitas < acertoFraco;

  /// Dias desde o último estudo (nulo = nunca estudado).
  int? get diasSemEstudar =>
      ultimoEstudo == null ? null : hoje.difference(ultimoEstudo!).inDays;

  bool get parado => (diasSemEstudar ?? 0) >= diasParado;

  /// "subiu 12 pontos", "caiu 15 pontos", "estável" ou "sem dados...".
  String get textoTendencia => switch (tendencia) {
    Tendencia.subiu => 'subiu ${variacao!} pontos',
    Tendencia.caiu => 'caiu ${-variacao!} pontos',
    Tendencia.estavel => 'estável',
    Tendencia.semDados => 'sem dados para comparar',
  };

  /// "estudado hoje", "estudado ontem", "estudado há 5 dias", "nunca...".
  String get textoUltimoEstudo => switch (diasSemEstudar) {
    null => 'nunca estudado',
    0 => 'estudado hoje',
    1 => 'estudado ontem',
    final d => 'estudado há $d dias',
  };

  List<SemanaPlacar> get minilinha =>
      semanas.sublist(math.max(0, semanas.length - semanasMinilinha));
}

/// Um tópico em "Revise primeiro", com os motivos.
class Sugestao {
  const Sugestao(this.desempenho, this.motivos, this.peso);
  final Desempenho desempenho;
  final List<MotivoRevisao> motivos;
  final double peso;

  /// "caiu 15 pontos em 30 dias · acerto 45% em 20 questões".
  String get texto => [
    for (final m in motivos)
      switch (m) {
        MotivoRevisao.caiu =>
          'caiu ${-desempenho.variacao!} pontos em $janelaTendencia dias',
        MotivoRevisao.fraco =>
          'acerto ${(desempenho.acerto! * 100).round()}% em '
              '${desempenho.total.feitas} questões',
        MotivoRevisao.parado => 'parado há ${desempenho.diasSemEstudar} dias',
      },
  ].join(' · ');
}

/// Desempenho de cada tópico de primeiro nível em [topicos] (os
/// subtópicos somam no tópico de cima), na ordem do edital.
List<Desempenho> calcularDesempenho(
  List<TopicoDesempenho> topicos,
  List<RegistroTopico> registros, {
  required DateTime hoje,
}) {
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  final porId = {for (final t in topicos) t.id: t};
  String? raizDe(String id) {
    var t = porId[id];
    final vistos = <String>{};
    while (t != null && t.paiId != null && vistos.add(t.id)) {
      final p = porId[t.paiId];
      if (p == null) break;
      t = p;
    }
    return t?.id;
  }

  final iniRecente = dia.subtract(const Duration(days: janelaTendencia - 1));
  final iniAnterior = iniRecente.subtract(
    const Duration(days: janelaTendencia),
  );
  final semanaAtual = inicioDaSemana(dia);
  final inicios = [
    for (var i = semanasDetalhe - 1; i >= 0; i--)
      DateTime(semanaAtual.year, semanaAtual.month, semanaAtual.day - 7 * i),
  ];

  final total = <String, Placar>{};
  final recente = <String, Placar>{};
  final anterior = <String, Placar>{};
  final ultimo = <String, DateTime>{};
  final semanas = <String, Map<DateTime, Placar>>{};
  for (final r in registros) {
    final raiz = raizDe(r.topicoId);
    if (raiz == null) continue;
    final d = DateTime(r.dia.year, r.dia.month, r.dia.day);
    if (d.isAfter(dia)) continue;
    if (r.feitas > 0 || r.minutos > 0) {
      final u = ultimo[raiz];
      if (u == null || d.isAfter(u)) ultimo[raiz] = d;
    }
    if (r.feitas <= 0) continue;
    final p = Placar(r.feitas, math.min(r.acertos, r.feitas));
    total[raiz] = (total[raiz] ?? const Placar()) + p;
    if (!d.isBefore(iniRecente)) {
      recente[raiz] = (recente[raiz] ?? const Placar()) + p;
    } else if (!d.isBefore(iniAnterior)) {
      anterior[raiz] = (anterior[raiz] ?? const Placar()) + p;
    }
    final s = inicioDaSemana(d);
    if (!s.isBefore(inicios.first)) {
      final m = semanas[raiz] ??= {};
      m[s] = (m[s] ?? const Placar()) + p;
    }
  }

  final raizes = [
    for (final t in topicos)
      if (t.paiId == null || !porId.containsKey(t.paiId)) t,
  ];
  return [
    for (final t in raizes)
      Desempenho(
        topico: t,
        total: total[t.id] ?? const Placar(),
        recente: recente[t.id] ?? const Placar(),
        anterior: anterior[t.id] ?? const Placar(),
        ultimoEstudo: ultimo[t.id],
        semanas: [
          for (final i in inicios)
            SemanaPlacar(i, semanas[t.id]?[i] ?? const Placar()),
        ],
        hoje: dia,
      ),
  ];
}

/// "Revise primeiro": até [maximo] tópicos, do mais urgente ao menos.
/// Caiu vale mais que acerto baixo, que vale mais que parado; dentro de
/// cada motivo, pesa o tamanho da queda, quão baixo está o acerto e há
/// quanto tempo está parado. Tópico nunca estudado fica de fora (é o
/// "nunca visto" do Foco agora, no mapa mental).
List<Sugestao> sugerirRevisao(
  List<Desempenho> lista, {
  int maximo = maximoSugestoes,
}) {
  final r = <Sugestao>[];
  for (final d in lista) {
    final motivos = <MotivoRevisao>[];
    var peso = 0.0;
    if (d.tendencia == Tendencia.caiu) {
      motivos.add(MotivoRevisao.caiu);
      peso += 3 + (-d.variacao!) / 10;
    }
    if (d.fraco) {
      motivos.add(MotivoRevisao.fraco);
      peso += 2 + (acertoFraco - d.acerto!) * 10;
    }
    if (d.parado) {
      motivos.add(MotivoRevisao.parado);
      peso += 1 + d.diasSemEstudar! / diasParado;
    }
    if (motivos.isNotEmpty) r.add(Sugestao(d, motivos, peso));
  }
  r.sort((a, b) => b.peso.compareTo(a.peso));
  return r.take(maximo).toList();
}

/// Ordem da lista.
enum OrdemDesempenho { edital, piorAcerto, maiorQueda, maisQuestoes }

List<Desempenho> ordenar(List<Desempenho> l, OrdemDesempenho o) {
  final idx = {for (final (i, d) in l.indexed) d: i};
  int estavel(Desempenho a, Desempenho b, int c) =>
      c != 0 ? c : idx[a]!.compareTo(idx[b]!);
  final r = [...l];
  switch (o) {
    case OrdemDesempenho.edital:
      break;
    case OrdemDesempenho.piorAcerto:
      // Sem questões vai para o fim.
      r.sort((a, b) => estavel(a, b, (a.acerto ?? 2).compareTo(b.acerto ?? 2)));
    case OrdemDesempenho.maiorQueda:
      r.sort(
        (a, b) =>
            estavel(a, b, (a.variacao ?? 1000).compareTo(b.variacao ?? 1000)),
      );
    case OrdemDesempenho.maisQuestoes:
      r.sort((a, b) => estavel(a, b, b.total.feitas.compareTo(a.total.feitas)));
  }
  return r;
}
