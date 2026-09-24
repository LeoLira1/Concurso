import 'package:flutter/material.dart';

import '../screens/resolver_screen.dart';
import '../theme.dart';

/// Atalho da tela inicial: "Treino rápido: 10 questões" do concurso em
/// foco, primeiro as nunca feitas e as que errei.
class BotaoTreinoRapido extends StatelessWidget {
  const BotaoTreinoRapido({super.key, this.compacto = false});
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final botao = Material(
      color: Cores.fundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Cores.linha, width: 1.5),
      ),
      child: InkWell(
        key: const ValueKey('treino-rapido'),
        borderRadius: BorderRadius.circular(22),
        onTap: () => abrirTreinoRapido(context),
        child: SizedBox(
          height: 68,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compacto ? 16 : 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, size: 26),
                if (!compacto) ...[
                  const SizedBox(width: 10),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TREINO RÁPIDO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Cores.tintaSuave,
                        ),
                      ),
                      Text(
                        '10 questões',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return compacto
        ? Tooltip(message: 'Treino rápido: 10 questões', child: botao)
        : botao;
  }
}
