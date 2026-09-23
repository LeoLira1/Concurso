import 'package:flutter/material.dart';

/// Método de estudo de uma sessão (guardado como texto no banco).
enum Metodo {
  videoaula('videoaula', 'Videoaula', Icons.play_circle_outline_rounded),
  pdf('pdf', 'PDF', Icons.picture_as_pdf_outlined),
  questoes('questoes', 'Questões', Icons.quiz_outlined),
  revisao('revisao', 'Revisão', Icons.replay_rounded),
  leiSeca('lei_seca', 'Lei seca', Icons.gavel_rounded);

  const Metodo(this.chave, this.rotulo, this.icone);
  final String chave;
  final String rotulo;
  final IconData icone;

  static Metodo? deChave(String? chave) {
    for (final m in values) {
      if (m.chave == chave) return m;
    }
    return null;
  }
}
