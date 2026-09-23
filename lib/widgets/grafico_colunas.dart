import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/estatisticas.dart';
import '../theme.dart';
import '../util/texto.dart';

/// Colunas de horas estudadas por período. Uma série só: a coluna
/// selecionada (por padrão, o período atual) fica em tinta forte e as demais
/// em cinza (ênfase). Tocar numa coluna mostra o valor no topo do cartão.
class GraficoColunas extends StatefulWidget {
  const GraficoColunas({super.key, required this.barras, this.altura = 240});
  final List<Barra> barras;
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

  @override
  Widget build(BuildContext context) {
    final b = widget.barras;
    if (b.isEmpty) return const SizedBox.shrink();
    final sel = (_sel ?? b.length - 1).clamp(0, b.length - 1);
    final atual = b[sel];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
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
                        Expanded(
                          child: Text(
                            x.detalhe,
                            style: const TextStyle(fontSize: 15),
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
        else
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
                  painter: _Pintor(b, sel),
                ),
              ),
            ),
          ),
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

class _Pintor extends CustomPainter {
  _Pintor(this.barras, this.sel);
  final List<Barra> barras;
  final int sel;

  static const eixoY = 44.0;
  static const eixoX = 26.0;
  static const _cinza = Color(0xFF999999);
  static const _grade = Color(0xFFEAEAEA);

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
    double y(int m) => alturaPlot - alturaPlot * m / topo;

    // Grade e eixo Y (linhas finas, sólidas, recessivas).
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
      if (b.minutos > 0) {
        final topoBarra = y(b.minutos);
        final r = RRect.fromRectAndCorners(
          Rect.fromLTRB(
            cx - largura / 2,
            topoBarra,
            cx + largura / 2,
            alturaPlot,
          ),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        );
        canvas.drawRRect(r, Paint()..color = destaque ? Cores.tinta : _cinza);
      }
      // Rótulos do eixo X: espaçados, sempre o selecionado e o último.
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
  bool shouldRepaint(_Pintor old) => old.barras != barras || old.sel != sel;
}
