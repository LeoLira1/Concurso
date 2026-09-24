import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../screens/revisoes_screen.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'assistir.dart';
import 'escopo.dart';

/// Atalho da tela inicial para as revisões de hoje (com contador).
class BotaoRevisoes extends StatelessWidget {
  const BotaoRevisoes({super.key, this.compacto = false});
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final hoje = soDia(DateTime.now());
    return ComEscopo(
      builder: (context, escopo) => Assistir<List<RevisaoInfo>>(
        chave: (hoje, escopo),
        stream: () => db.watchRevisoesPendentes(hoje, concursoId: escopo),
        builder: (context, l) {
          final n = l?.length ?? 0;
          return Material(
            color: Cores.fundo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: n > 0 ? Cores.tinta : Cores.linha,
                width: n > 0 ? 2 : 1.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RevisoesScreen()),
              ),
              child: SizedBox(
                height: 68,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: compacto ? 16 : 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.replay_rounded, size: 24),
                      if (!compacto) ...[
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REVISÕES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Cores.tintaSuave,
                              ),
                            ),
                            Text(
                              n == 0 ? 'Em dia' : 'Hoje',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (n > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          constraints: const BoxConstraints(minWidth: 30),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Cores.acento,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '$n',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
