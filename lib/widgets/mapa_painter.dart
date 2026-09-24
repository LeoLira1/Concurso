import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../logic/mapa_mental.dart';
import '../theme.dart';

/// Laranja do alerta de % de acerto baixa.
const corAcertoBaixo = Color(0xFFF08C00);

/// Cinza claro dos tópicos ainda não vistos.
const corNaoVisto = Color(0xFFF0F0F0);

/// Fundo de "visto em parte": a cor da matéria bem clara.
Color corEmParte(Color c) =>
    Color.alphaBlend(c.withValues(alpha: 0.28), Cores.fundo);

/// Texto legível sobre a cor da matéria.
Color tintaSobre(Color c) =>
    c.computeLuminance() > 0.33 ? Cores.tinta : Colors.white;

/// Tamanho da fonte de cada tipo de nó (também usado no nível de detalhe).
double fonteDoNo(NoPosicionado n) {
  if (n.profundidade == 0) return 17;
  return switch (n.no.tipo) {
    TipoNo.raiz => 17,
    TipoNo.materia => 14,
    TipoNo.topico => 12.5,
    TipoNo.subtopico => 11.5,
  };
}

/// Abaixo de 5 px na tela o texto vira ruído: não desenha.
const _menorFonteNaTela = 5.0;

/// Nível de detalhe para a escala [s]: a menor fonte que ainda é desenhada.
/// Muda em degraus, para o mapa só redesenhar quando cruza um limite.
double limiteFonte(double s) {
  for (final f in const [11.5, 12.5, 14.0, 17.0]) {
    if (f * s >= _menorFonteNaTela) return f;
  }
  return double.infinity;
}

/// Textos e ligações pré-calculados de um layout (reaproveitados em todos os
/// quadros; só são refeitos quando o layout muda).
class CacheMapa {
  CacheMapa(this.layout, this.origem) {
    // Ligações agrupadas por cor e espessura: poucos drawPath por quadro.
    for (final n in layout.nos) {
      final p = n.pai;
      if (p == null) continue;
      final a = p.centro + origem, b = n.centro + origem;
      final meio = (p.raio + n.raio) / 2;
      final c1 = p.profundidade == 0
          ? a
          : Offset(meio * math.cos(p.angulo), meio * math.sin(p.angulo)) +
                origem;
      final c2 =
          Offset(meio * math.cos(n.angulo), meio * math.sin(n.angulo)) + origem;
      final path = ligacoes.putIfAbsent((
        n.no.cor,
        n.profundidade,
      ), () => Path());
      path
        ..moveTo(a.dx, a.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);
    }
  }

  final LayoutMapa layout;
  final Offset origem;
  final ligacoes = <(int, int), Path>{};
  final _textos = <NoPosicionado, TextPainter>{};
  final _porcentagens = <NoPosicionado, TextPainter>{};

  TextPainter texto(NoPosicionado n, double largura, Color cor, int linhas) {
    return _textos.putIfAbsent(n, () {
      final f = fonteDoNo(n);
      return TextPainter(
        text: TextSpan(
          text: n.no.rotulo,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: f,
            height: 1.15,
            color: cor,
            fontWeight: n.profundidade <= 1 || n.no.tipo == TipoNo.materia
                ? FontWeight.w800
                : FontWeight.w600,
            letterSpacing: f >= 14 ? -0.2 : 0,
          ),
        ),
        maxLines: linhas,
        ellipsis: '…',
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: largura);
    });
  }

  TextPainter porcentagem(NoPosicionado n) {
    return _porcentagens.putIfAbsent(
      n,
      () => TextPainter(
        text: TextSpan(
          text: '${(n.no.progresso * 100).round()}%',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Cores.tintaSuave,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
  }

  void descartar() {
    for (final t in _textos.values) {
      t.dispose();
    }
    for (final t in _porcentagens.values) {
      t.dispose();
    }
    _textos.clear();
    _porcentagens.clear();
  }
}

class MapaPainter extends CustomPainter {
  MapaPainter({required this.cache, required this.limite})
    : super(repaint: limite);

  final CacheMapa cache;

  /// Menor fonte desenhada (ver [limiteFonte]).
  final ValueListenable<double> limite;

  @override
  void paint(Canvas canvas, Size size) {
    final origem = cache.origem;
    final linha = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    cache.ligacoes.forEach((chave, path) {
      final (cor, prof) = chave;
      linha
        ..color = Color(cor).withValues(alpha: prof <= 1 ? 0.75 : 0.5)
        ..strokeWidth = switch (prof) {
          1 => 3.5,
          2 => 2.2,
          _ => 1.6,
        };
      canvas.drawPath(path, linha);
    });

    final minFonte = limite.value;
    for (final n in cache.layout.nos) {
      _no(canvas, n, n.retangulo.shift(origem), fonteDoNo(n) >= minFonte);
    }
  }

  void _no(Canvas canvas, NoPosicionado n, Rect r, bool comTexto) {
    final no = n.no;
    final cor = Color(no.cor);
    final centro = n.profundidade == 0;

    if (no.tipo == TipoNo.raiz) {
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(26));
      canvas.drawRRect(rr, Paint()..color = Cores.tinta);
      if (comTexto) _texto(canvas, n, r.deflate(16), Colors.white, 2);
      return;
    }

    if (no.tipo == TipoNo.materia) {
      final rr = RRect.fromRectAndRadius(r, Radius.circular(centro ? 26 : 20));
      canvas.drawRRect(rr, Paint()..color = Cores.fundo);
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = centro ? 3.5 : 2.5
          ..color = cor,
      );
      // Barra com a % de tópicos vistos.
      const alturaBarra = 6.0;
      final pct = cache.porcentagem(n);
      final barra = Rect.fromLTWH(
        r.left + 16,
        r.bottom - 14 - alturaBarra,
        r.width - 32 - (comTexto ? pct.width + 8 : 0),
        alturaBarra,
      );
      final raio = const Radius.circular(alturaBarra / 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(barra, raio),
        Paint()..color = cor.withValues(alpha: 0.18),
      );
      if (no.progresso > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              barra.left,
              barra.top,
              barra.width * no.progresso.clamp(0, 1),
              alturaBarra,
            ),
            raio,
          ),
          Paint()..color = cor,
        );
      }
      if (comTexto) {
        pct.paint(
          canvas,
          Offset(barra.right + 8, barra.center.dy - pct.height / 2),
        );
        _texto(
          canvas,
          n,
          Rect.fromLTRB(r.left + 12, r.top + 6, r.right - 12, barra.top - 4),
          Cores.tinta,
          2,
        );
      }
      if (no.ocultos > 0) _selo(canvas, r, cor, '+${no.ocultos}', comTexto);
      return;
    }

    // Tópico ou subtópico: preenchimento pela situação.
    final raio = Radius.circular(n.no.tipo == TipoNo.topico ? 16 : 14);
    final rr = RRect.fromRectAndRadius(r, raio);
    final (fundo, tinta) = switch (no.visto) {
      Visto.sim => (cor, tintaSobre(cor)),
      Visto.parte => (corEmParte(cor), Cores.tinta),
      Visto.nao => (corNaoVisto, Cores.tintaSuave),
    };
    canvas.drawRRect(rr, Paint()..color = fundo);
    final borda = Paint()..style = PaintingStyle.stroke;
    if (no.atrasada) {
      canvas.drawRRect(
        rr.inflate(1.5),
        borda
          ..color = Cores.acento
          ..strokeWidth = 3.5,
      );
      if (no.acertoBaixo) {
        canvas.drawRRect(
          rr.deflate(2.5),
          borda
            ..color = corAcertoBaixo
            ..strokeWidth = 3,
        );
      }
    } else if (no.acertoBaixo) {
      canvas.drawRRect(
        rr.inflate(1.5),
        borda
          ..color = corAcertoBaixo
          ..strokeWidth = 3.5,
      );
    } else if (no.visto == Visto.nao) {
      canvas.drawRRect(
        rr,
        borda
          ..color = Cores.linha
          ..strokeWidth = 1,
      );
    }
    if (comTexto) _texto(canvas, n, r.deflate(8), tinta, 2);
  }

  void _texto(
    Canvas canvas,
    NoPosicionado n,
    Rect area,
    Color cor,
    int linhas,
  ) {
    final tp = cache.texto(n, area.width, cor, linhas);
    tp.paint(
      canvas,
      Offset(area.center.dx - tp.width / 2, area.center.dy - tp.height / 2),
    );
  }

  void _selo(Canvas canvas, Rect r, Color cor, String texto, bool comTexto) {
    final c = Offset(r.right - 4, r.top + 4);
    canvas.drawCircle(c, 15, Paint()..color = cor);
    canvas.drawCircle(
      c,
      15,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Cores.fundo,
    );
    if (!comTexto) return;
    final tp = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: texto.length > 3 ? 10 : 11,
          fontWeight: FontWeight.w800,
          color: tintaSobre(cor),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    tp.dispose();
  }

  @override
  bool shouldRepaint(MapaPainter old) =>
      old.cache != cache || old.limite != limite;
}

/// Com o mapa afastado, o texto das matérias fica pequeno demais e some.
/// Este painter desenha os nomes delas por cima, em tamanho fixo na tela,
/// para o mapa continuar legível na visão geral. Redesenha a cada quadro de
/// zoom/arraste, mas são no máximo algumas dezenas de rótulos.
class RotulosMateriasPainter extends CustomPainter {
  RotulosMateriasPainter({required this.cache, required this.transformacao})
    : super(repaint: transformacao);

  final CacheMapa cache;
  final ValueListenable<Matrix4> transformacao;
  final _textos = <NoPosicionado, TextPainter>{};

  @override
  void paint(Canvas canvas, Size size) {
    final m = transformacao.value;
    final s = m.getMaxScaleOnAxis();
    final ocupados = <Rect>[];
    for (final n in cache.layout.nos) {
      if (n.profundidade > 1) continue;
      final centro = MatrixUtils.transformPoint(m, n.centro + cache.origem);
      if (n.profundidade == 0) {
        // O centro nunca fica coberto por rótulos.
        ocupados.add(
          MatrixUtils.transformRect(m, n.retangulo.shift(cache.origem)),
        );
        continue;
      }
      if (n.no.tipo != TipoNo.materia) continue;
      if (fonteDoNo(n) * s >= _menorFonteNaTela) continue;
      final tp = _textos.putIfAbsent(
        n,
        () => TextPainter(
          text: TextSpan(
            text: n.no.rotulo,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: Cores.tinta,
            ),
          ),
          maxLines: 2,
          ellipsis: '…',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 150),
      );
      // Tenta no lugar da matéria; se bater em outro rótulo, afasta para
      // fora do centro. Se não couber, omite (o nome volta com o zoom).
      final dir = Offset(math.cos(n.angulo), math.sin(n.angulo));
      Rect? caixa;
      for (var passo = 0; passo < 6; passo++) {
        final c = Rect.fromCenter(
          center: centro + dir * (passo * 22.0),
          width: tp.width + 20,
          height: tp.height + 10,
        );
        if (!ocupados.any((o) => o.inflate(3).overlaps(c))) {
          caixa = c;
          break;
        }
      }
      if (caixa == null) continue;
      if (!(Offset.zero & size).overlaps(caixa)) continue;
      ocupados.add(caixa);
      final rr = RRect.fromRectAndRadius(caixa, const Radius.circular(10));
      canvas.drawRRect(
        rr,
        Paint()..color = Cores.fundo.withValues(alpha: 0.94),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Color(n.no.cor),
      );
      tp.paint(canvas, caixa.center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(RotulosMateriasPainter old) =>
      old.cache != cache || old.transformacao != transformacao;
}
