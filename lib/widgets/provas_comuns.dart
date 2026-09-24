import 'package:flutter/material.dart';

import '../logic/provas.dart';
import '../theme.dart';

/// Laranja dos avisos (lei mudou, sem tópico, acerto baixo).
const corAviso = Color(0xFFE08A00);
const corCerto = Color(0xFF1F9D55);

/// Etiqueta pequena e arredondada.
class Selo extends StatelessWidget {
  const Selo(this.texto, {super.key, this.cor = Cores.tintaSuave, this.icone});
  final String texto;
  final Color cor;
  final IconData? icone;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: cor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icone != null) ...[
          Icon(icone, size: 15, color: cor),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
        ),
      ],
    ),
  );
}

String rotuloStatus(String s) => switch (s) {
  StatusQuestao.anulada => 'Anulada',
  StatusQuestao.imagem => 'Imagem',
  StatusQuestao.revisar => 'Revisar',
  StatusQuestao.desatualizada => 'Desatualizada',
  _ => s,
};

Color corStatus(String s) => switch (s) {
  StatusQuestao.anulada => Cores.tintaSuave,
  StatusQuestao.imagem => const Color(0xFF2F7CF6),
  StatusQuestao.revisar => const Color(0xFF8E5CF7),
  StatusQuestao.desatualizada => corAviso,
  _ => Cores.tintaSuave,
};

IconData iconeStatus(String s) => switch (s) {
  StatusQuestao.anulada => Icons.block_rounded,
  StatusQuestao.imagem => Icons.image_outlined,
  StatusQuestao.revisar => Icons.fact_check_outlined,
  StatusQuestao.desatualizada => Icons.history_rounded,
  _ => Icons.label_outline_rounded,
};

String doisDigitos(int n) => n.toString().padLeft(2, '0');

/// Cartão com borda fina (padrão das telas do app).
class Cartao extends StatelessWidget {
  const Cartao({
    super.key,
    required this.child,
    this.titulo,
    this.corBorda = Cores.linha,
    this.fundo = Cores.fundo,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final String? titulo;
  final Color corBorda;
  final Color fundo;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Material(
    color: fundo,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: corBorda, width: 1.5),
    ),
    child: Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (titulo != null) ...[
            Text(titulo!, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    ),
  );
}

/// Caixa de observação ("obs" da questão).
class CaixaObs extends StatelessWidget {
  const CaixaObs(this.texto, {super.key, this.titulo = 'Observação'});
  final String texto;
  final String titulo;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Cores.fundoLateral,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Cores.tintaSuave,
          ),
        ),
        const SizedBox(height: 6),
        Text(texto, style: const TextStyle(fontSize: 15, height: 1.4)),
      ],
    ),
  );
}
