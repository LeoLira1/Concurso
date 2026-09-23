import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/estatisticas.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'comuns.dart';

/// Série do gráfico (uma matéria).
class SerieGrafico {
  const SerieGrafico(this.chave, this.nome, this.cor);
  final String? chave;
  final String nome;
  final Color cor;
}

/// Colunas de horas por período, empilhadas por matéria (cada uma na sua
/// cor, na ordem do edital, com 2 px de espaço entre os segmentos).
/// Tocar numa coluna mostra o total e as matérias no topo do cartão; há
/// legenda e visão em tabela, então a cor nunca é o único jeito de ler.
class GraficoColunas extends StatefulWidget {
  const GraficoColunas({
    super.key,
    required this.barras,
    required this.series,
    this.altura = 240,
  });

  final List<Barra> barras;

  /// Matérias na ordem de empilhamento (de baixo para cima).
  final List<SerieGrafico> series;
  final double altura;

  @override
  State<GraficoColunas> createState() => _GraficoColunasState();
}

class _GraficoColunasState extends State<GraficoColunas> {
  int? _sel;
  bool _tabela = false;

  @override
  void didUpdateWidget(GraficoColunas old) {
    super.didUpdateWidget(old);
    if (old.barras.length != widget.barras.length) _sel = null;
  }

  SerieGrafico _serie(String? chave) {
    for (final s in widget.series) {
      if (s.chave == chave) return s;
    }
    return SerieGrafico(
      chave,
      chave == null ? 'Estudo livre' : 'Outra',
      Cores.tintaFraca,
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.barras;
    if (b.isEmpty) return const SizedBox.shrink();
    final sel = (_sel ?? b.length - 1).clamp(0, b.length - 1);
    final atual = b[sel];
    final doSelecionado =
        atual.porMateria.entries.where((e) => e.value > 0).toList()
          ..sort((a, c) => c.value.compareTo(a.value));
    final presentes = <String?>{for (final x in b) ...x.porMateria.keys};
    final legenda = [
      for (final s in widget.series)
        if (presentes.contains(s.chave)) s,
      if (presentes.contains(null)) _serie(null),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    atual.minutos == 0 ? '0h' : minutosFmt(atual.minutos),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    atual.detalhe,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Cores.tintaSuave,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Detalhe do período tocado: matéria e tempo.
                  SizedBox(
                    height: 20,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final e in doSelecionado.take(4))
                          Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Bolinha(_serie(e.key).cor, tamanho: 9),
                                const SizedBox(width: 5),
                                Text(
                                  '${siglaOuNome(_serie(e.key).nome)} ${minutosFmt(e.value)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (doSelecionado.length > 4)
                          Text(
                            '+${doSelecionado.length - 4}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Cores.tintaSuave,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: _tabela ? 'Ver gráfico' : 'Ver tabela',
              onPressed: () => setState(() => _tabela = !_tabela),
              icon: Icon(
                _tabela ? Icons.bar_chart_rounded : Icons.table_rows_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_tabela)
          SizedBox(
            height: widget.altura,
            child: ListView(
              children: [
                for (final x in b.reversed)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Cores.linha)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            x.detalhe,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            [
                              for (final e
                                  in (x.porMateria.entries.toList()..sort(
                                    (a, c) => c.value.compareTo(a.value),
                                  )))
                                '${siglaOuNome(_serie(e.key).nome)} ${minutosFmt(e.value)}',
                            ].join(' · '),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Cores.tintaSuave,
                            ),
                          ),
                        ),
                        Text(
                          x.minutos == 0 ? '—' : minutosFmt(x.minutos),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        else ...[
          SizedBox(
            height: widget.altura,
            child: LayoutBuilder(
              builder: (context, box) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _tocar(d.localPosition.dx, box.maxWidth),
                onHorizontalDragUpdate: (d) =>
                    _tocar(d.localPosition.dx, box.maxWidth),
                child: CustomPaint(
                  size: Size(box.maxWidth, widget.altura),
                  painter: _Pintor(
                    b,
                    sel,
                    [for (final s in widget.series) s.chave],
                    {
                      for (final s in widget.series) s.chave: s.cor,
                      null: Cores.tintaFraca,
                    },
                  ),
                ),
              ),
            ),
          ),
          if (legenda.length >= 2) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final s in legenda)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Bolinha(s.cor, tamanho: 9),
                      const SizedBox(width: 5),
                      Text(
                        s.nome,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Cores.tintaSuave,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  void _tocar(double x, double largura) {
    final area = largura - _Pintor.eixoY;
    final i = ((x - _Pintor.eixoY) / (area / widget.barras.length)).floor();
    if (i >= 0 && i < widget.barras.length && i != _sel) {
      setState(() => _sel = i);
    }
  }
}

/// Nome curto para o detalhe/tabela: nomes longos viram sigla.
String siglaOuNome(String nome) =>
    nome.length <= 14 ? nome : siglaMateria(nome);

class _Pintor extends CustomPainter {
  _Pintor(this.barras, this.sel, this.ordem, this.cores);
  final List<Barra> barras;
  final int sel;
  final List<String?> ordem;
  final Map<String?, Color> cores;

  static const eixoY = 44.0;
  static const eixoX = 26.0;
  static const _grade = Color(0xFFEAEAEA);
  static const _vao = 2.0;

  /// Passo "redondo" das marcas do eixo, em minutos.
  static int _passo(int max) {
    for (final p in const [15, 30, 60, 120, 180, 300, 600, 1200, 3000, 6000]) {
      if (max / p <= 4) return p;
    }
    return 12000;
  }

  static String _hora(int m) => m < 60
      ? '${m}min'
      : '${m ~/ 60}h${m % 60 == 0 ? '' : (m % 60).toString().padLeft(2, '0')}';

  void _texto(
    Canvas c,
    String s,
    Offset o, {
    TextAlign alinhar = TextAlign.center,
    double largura = 40,
    Color cor = Cores.tintaSuave,
    bool forte = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 11.5,
          color: cor,
          fontWeight: forte ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      textAlign: alinhar,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: largura, maxWidth: largura);
    tp.paint(c, o);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final maxMin = barras.fold<int>(0, (a, b) => math.max(a, b.minutos));
    final passo = _passo(math.max(maxMin, 60));
    final topo = ((math.max(maxMin, 60) / passo).ceil()) * passo;
    final alturaPlot = size.height - eixoX;
    double y(num m) => alturaPlot - alturaPlot * m / topo;

    final grade = Paint()
      ..color = _grade
      ..strokeWidth = 1;
    for (var m = 0; m <= topo; m += passo) {
      final yy = y(m).roundToDouble() + 0.5;
      canvas.drawLine(Offset(eixoY, yy), Offset(size.width, yy), grade);
      _texto(
        canvas,
        m == 0 ? '0' : _hora(m),
        Offset(0, yy - 8),
        alinhar: TextAlign.right,
        largura: eixoY - 8,
      );
    }

    final n = barras.length;
    final faixa = (size.width - eixoY) / n;
    final largura = math.min(24.0, faixa * 0.62);
    final aCada = math.max(1, (48 / faixa).ceil());

    for (var i = 0; i < n; i++) {
      final b = barras[i];
      final cx = eixoY + faixa * (i + 0.5);
      final destaque = i == sel;

      // Segmentos na ordem do edital; matérias fora da lista e estudo livre por último.
      final chaves = [
        for (final k in ordem)
          if ((b.porMateria[k] ?? 0) > 0) k,
        for (final k in b.porMateria.keys)
          if (!ordem.contains(k) && (b.porMateria[k] ?? 0) > 0) k,
      ];
      var acumulado = 0;
      for (final (j, k) in chaves.indexed) {
        final base = y(acumulado);
        acumulado += b.porMateria[k]!;
        final ultimo = j == chaves.length - 1;
        // 2 px de vão entre segmentos (a cor do fundo separa, sem contorno).
        final topoSeg = y(acumulado) + (ultimo ? 0 : _vao);
        if (base - topoSeg <= 0.5) continue;
        final r = RRect.fromRectAndCorners(
          Rect.fromLTRB(cx - largura / 2, topoSeg, cx + largura / 2, base),
          topLeft: ultimo ? const Radius.circular(4) : Radius.zero,
          topRight: ultimo ? const Radius.circular(4) : Radius.zero,
        );
        canvas.drawRRect(r, Paint()..color = cores[k] ?? Cores.tintaFraca);
      }
      // Marcador do período selecionado: um ponto de tinta sobre a coluna.
      if (destaque && b.minutos > 0) {
        canvas.drawCircle(
          Offset(cx, y(b.minutos) - 8),
          3.5,
          Paint()..color = Cores.tinta,
        );
      }

      final mostrar = destaque || i == n - 1 || (n - 1 - i) % aCada == 0;
      final colideComSel = !destaque && (i - sel).abs() < aCada && i != n - 1;
      if (mostrar && !colideComSel) {
        _texto(
          canvas,
          b.rotulo,
          Offset(cx - 24, alturaPlot + 8),
          largura: 48,
          cor: destaque ? Cores.tinta : Cores.tintaSuave,
          forte: destaque,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_Pintor old) =>
      old.barras != barras || old.sel != sel || old.cores != cores;
}
