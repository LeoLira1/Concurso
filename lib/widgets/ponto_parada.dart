import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/metodo.dart';
import '../theme.dart';
import '../util/texto.dart';

/// "Onde você parou": o último ponto de parada registrado na matéria.
class PontoDeParada extends StatefulWidget {
  const PontoDeParada({
    super.key,
    required this.materiaId,
    this.compacto = false,
  });
  final String materiaId;
  final bool compacto;

  @override
  State<PontoDeParada> createState() => _PontoDeParadaState();
}

class _PontoDeParadaState extends State<PontoDeParada> {
  late Stream<Sessao?> _stream = context.read<AppDatabase>().watchUltimaParada(
    widget.materiaId,
  );

  @override
  void didUpdateWidget(PontoDeParada old) {
    super.didUpdateWidget(old);
    if (old.materiaId != widget.materiaId) {
      _stream = context.read<AppDatabase>().watchUltimaParada(widget.materiaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return StreamBuilder<Sessao?>(
      stream: _stream,
      builder: (context, snap) {
        final s = snap.data;
        if (s == null || s.pontoParada == null) return const SizedBox.shrink();
        return FutureBuilder<Topico?>(
          future: s.topicoId == null
              ? Future.value(null)
              : db.topico(s.topicoId!),
          builder: (context, tSnap) {
            final metodo = Metodo.deChave(s.metodo);
            final detalhes = [
              if (tSnap.data != null) tSnap.data!.nome,
              if (metodo != null) metodo.rotulo,
            ].join(' · ');
            return Container(
              constraints: const BoxConstraints(maxWidth: 640),
              padding: EdgeInsets.fromLTRB(
                18,
                widget.compacto ? 12 : 16,
                18,
                widget.compacto ? 12 : 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6DB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1DE9E), width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.bookmark_rounded,
                      color: Color(0xFFB8892F),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ONDE VOCÊ PAROU · ${_quando(s.dia)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Color(0xFF8A6A1F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.pontoParada!,
                          style: TextStyle(
                            fontSize: widget.compacto ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            color: Cores.tinta,
                          ),
                        ),
                        if (detalhes.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            detalhes,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Cores.tintaSuave,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _quando(DateTime d) {
    final dias = soDia(DateTime.now()).difference(soDia(d)).inDays;
    if (dias == 0) return 'HOJE';
    if (dias == 1) return 'ONTEM';
    if (dias < 7) return 'HÁ $dias DIAS';
    return dataCurta(d);
  }
}
