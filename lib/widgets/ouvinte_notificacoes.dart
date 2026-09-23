import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/lembretes.dart';
import '../screens/cronometro_screen.dart';
import '../screens/revisoes_screen.dart';
import '../state/notificacoes.dart';
import '../state/sessao_ativa.dart';

/// Navega para a tela certa quando o usuário toca numa notificação.
class OuvinteNotificacoes extends StatefulWidget {
  const OuvinteNotificacoes({super.key, required this.child});
  final Widget child;

  @override
  State<OuvinteNotificacoes> createState() => _OuvinteNotificacoesState();
}

class _OuvinteNotificacoesState extends State<OuvinteNotificacoes> {
  Notificacoes? _n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final n = context.read<Notificacoes>();
    if (n != _n) {
      _n?.removeListener(_aoMudar);
      _n = n..addListener(_aoMudar);
      WidgetsBinding.instance.addPostFrameCallback((_) => _aoMudar());
    }
  }

  void _aoMudar() {
    final payload = _n?.payloadPendente;
    if (payload == null || !mounted) return;
    _n!.consumirPayload();
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    switch (payload) {
      case payloadRevisoes:
        nav.push(MaterialPageRoute(builder: (_) => const RevisoesScreen()));
      case payloadCronometro:
        if (context.read<SessaoAtiva>().atual != null) {
          nav.push(
            MaterialPageRoute(
              builder: (_) => const CronometroScreen(),
              fullscreenDialog: true,
            ),
          );
        }
    }
  }

  @override
  void dispose() {
    _n?.removeListener(_aoMudar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
