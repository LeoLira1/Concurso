import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class Bolinha extends StatelessWidget {
  const Bolinha(this.cor, {super.key, this.tamanho = 12});
  final Color cor;
  final double tamanho;

  @override
  Widget build(BuildContext context) => Container(
    width: tamanho,
    height: tamanho,
    decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
  );
}

/// Marca "edital." com o ponto vermelho (referência pocket cal).
class Marca extends StatelessWidget {
  const Marca({super.key, this.tamanho = 30});
  final double tamanho;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        const TextSpan(text: 'edital'),
        TextSpan(
          text: '.',
          style: TextStyle(color: Cores.acento, fontSize: tamanho * 1.1),
        ),
      ],
    ),
    style: TextStyle(
      fontSize: tamanho,
      fontWeight: FontWeight.w900,
      letterSpacing: -tamanho * 0.05,
      height: 1,
      color: Cores.tinta,
    ),
  );
}

/// Anel de progresso com a porcentagem no centro.
class AnelProgresso extends StatelessWidget {
  const AnelProgresso({
    super.key,
    required this.valor,
    required this.cor,
    this.tamanho = 56,
    this.espessura = 6,
    this.mostrarTexto = true,
  });

  final double valor;
  final Color cor;
  final double tamanho;
  final double espessura;
  final bool mostrarTexto;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: tamanho,
      child: CustomPaint(
        painter: _AnelPainter(valor.clamp(0, 1), cor, espessura),
        child: mostrarTexto
            ? Center(
                child: Text(
                  '${(valor * 100).round()}%',
                  style: TextStyle(
                    fontSize: tamanho * 0.24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _AnelPainter extends CustomPainter {
  _AnelPainter(this.valor, this.cor, this.espessura);
  final double valor;
  final Color cor;
  final double espessura;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(espessura / 2);
    final fundo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura
      ..color = cor.withValues(alpha: 0.15);
    canvas.drawArc(r, 0, math.pi * 2, false, fundo);
    if (valor > 0) {
      final frente = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = espessura
        ..strokeCap = StrokeCap.round
        ..color = cor;
      canvas.drawArc(r, -math.pi / 2, math.pi * 2 * valor, false, frente);
    }
  }

  @override
  bool shouldRepaint(_AnelPainter old) =>
      old.valor != valor || old.cor != cor || old.espessura != espessura;
}

class SeletorCores extends StatelessWidget {
  const SeletorCores({super.key, required this.valor, required this.aoMudar});
  final int valor;
  final ValueChanged<int> aoMudar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final c in Cores.paleta)
          GestureDetector(
            onTap: () => aoMudar(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(c),
                shape: BoxShape.circle,
                border: Border.all(
                  color: c == valor ? Cores.tinta : Colors.transparent,
                  width: 3,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: c == valor
                  ? const Icon(Icons.check_rounded, color: Colors.white)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// Botão-pílula com borda fina (como "Grid" no pocket cal).
class Pilula extends StatelessWidget {
  const Pilula({
    super.key,
    this.icone,
    this.rotulo,
    required this.aoTocar,
    this.tooltip,
  });
  final IconData? icone;
  final String? rotulo;
  final VoidCallback aoTocar;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final w = Material(
      color: Cores.fundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Cores.linha, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: aoTocar,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: rotulo == null ? 12 : 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icone != null) Icon(icone, size: 22),
                if (icone != null && rotulo != null) const SizedBox(width: 8),
                if (rotulo != null)
                  Text(
                    rotulo!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? w : Tooltip(message: tooltip!, child: w);
  }
}

Future<String?> pedirTexto(
  BuildContext context, {
  required String titulo,
  String inicial = '',
  String? dica,
  String confirmar = 'Salvar',
  bool multilinha = false,
  String? ajuda,
}) {
  final ctrl = TextEditingController(text: inicial);
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      void ok() {
        final v = ctrl.text.trim();
        if (v.isNotEmpty) Navigator.pop(ctx, multilinha ? ctrl.text : v);
      }

      return AlertDialog(
        title: Text(titulo, style: Theme.of(ctx).textTheme.headlineSmall),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ajuda != null) ...[
                Text(ajuda, style: const TextStyle(color: Cores.tintaSuave)),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: ctrl,
                autofocus: true,
                minLines: multilinha ? 6 : 1,
                maxLines: multilinha ? 14 : 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(hintText: dica),
                onSubmitted: multilinha ? null : (_) => ok(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(onPressed: ok, child: Text(confirmar)),
        ],
      );
    },
  );
}

Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String acao = 'Excluir',
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo, style: Theme.of(ctx).textTheme.headlineSmall),
      content: SizedBox(
        width: 480,
        child: Text(mensagem, style: const TextStyle(fontSize: 16)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Cores.acento),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(acao),
        ),
      ],
    ),
  );
  return r ?? false;
}

Future<int?> escolherCor(BuildContext context, int atual) {
  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Cor', style: Theme.of(ctx).textTheme.headlineSmall),
      content: SizedBox(
        width: 360,
        child: SeletorCores(
          valor: atual,
          aoMudar: (c) => Navigator.pop(ctx, c),
        ),
      ),
    ),
  );
}

void avisar(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(texto, style: const TextStyle(fontSize: 15))),
    );
}

/// Texto "Prova em 42 dias" / "Prova hoje" / "Prova foi há 3 dias".
String? contagemProva(DateTime? data) {
  if (data == null) return null;
  final hoje = DateTime.now();
  final d = DateTime(
    data.year,
    data.month,
    data.day,
  ).difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays;
  if (d == 0) return 'Prova hoje';
  if (d == 1) return 'Prova amanhã';
  if (d > 1) return 'Prova em $d dias';
  return 'Prova foi há ${-d} dias';
}
