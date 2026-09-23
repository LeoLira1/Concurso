import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/notificacoes.dart';
import '../theme.dart';
import '../widgets/comuns.dart';

/// Configuração das notificações: lembrete diário de estudo e revisões.
class LembretesScreen extends StatelessWidget {
  const LembretesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.watch<Notificacoes>();
    final c = n.config;

    Future<void> hora(int h, int m, void Function(TimeOfDay) f) async {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: h, minute: m),
        helpText: 'Horário',
      );
      if (t != null) f(t);
    }

    return Scaffold(
      appBar: AppBar(toolbarHeight: 72),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
            children: [
              Text(
                'Lembretes',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 6),
              const Text(
                'Notificações no tablet/celular, mesmo com o app fechado.',
                style: TextStyle(fontSize: 16, color: Cores.tintaSuave),
              ),
              if (n.disponivel && n.permitido == false) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDEC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_off_outlined,
                        color: Cores.acento,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'As notificações estão bloqueadas para o Edital.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: n.pedirPermissao,
                        child: const Text('Permitir'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _Cartao(
                icone: Icons.menu_book_rounded,
                titulo: 'Lembrete diário de estudo',
                descricao: 'Mostra a próxima matéria do ciclo.',
                ativo: c.estudoAtivo,
                aoAtivar: (v) => n.salvarConfig(c.copyWith(estudoAtivo: v)),
                horario: _fmt(c.estudoHora, c.estudoMinuto),
                aoMudarHorario: () => hora(
                  c.estudoHora,
                  c.estudoMinuto,
                  (t) => n.salvarConfig(
                    c.copyWith(estudoHora: t.hour, estudoMinuto: t.minute),
                  ),
                ),
                extra: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: c.soSeNaoEstudei,
                  onChanged: c.estudoAtivo
                      ? (v) => n.salvarConfig(c.copyWith(soSeNaoEstudei: v))
                      : null,
                  title: const Text(
                    'Só se eu ainda não tiver estudado no dia',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _Cartao(
                icone: Icons.replay_rounded,
                titulo: 'Revisões do dia',
                descricao:
                    'Avisa quantas revisões vencem no dia, com os tópicos.',
                ativo: c.revisoesAtivo,
                aoAtivar: (v) => n.salvarConfig(c.copyWith(revisoesAtivo: v)),
                horario: _fmt(c.revisoesHora, c.revisoesMinuto),
                aoMudarHorario: () => hora(
                  c.revisoesHora,
                  c.revisoesMinuto,
                  (t) => n.salvarConfig(
                    c.copyWith(revisoesHora: t.hour, revisoesMinuto: t.minute),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _Info(
                icone: Icons.timer_outlined,
                texto:
                    'O alarme do cronômetro (meta atingida e fim do foco/pausa) também '
                    'chega como notificação quando o app está em segundo plano.',
              ),
              const SizedBox(height: 8),
              const _Info(
                icone: Icons.battery_alert_outlined,
                texto:
                    'Se algum lembrete não chegar, desative a otimização de bateria '
                    'para o Edital nas configurações do Android.',
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: n.disponivel
                    ? () async {
                        await n.testar();
                        if (context.mounted) {
                          avisar(context, 'Notificação de teste enviada');
                        }
                      }
                    : null,
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Enviar notificação de teste'),
              ),
              if (!n.disponivel)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Notificações indisponíveis neste aparelho.',
                    style: TextStyle(color: Cores.tintaSuave),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

class _Cartao extends StatelessWidget {
  const _Cartao({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.ativo,
    required this.aoAtivar,
    required this.horario,
    required this.aoMudarHorario,
    this.extra,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final bool ativo;
  final ValueChanged<bool> aoAtivar;
  final String horario;
  final VoidCallback aoMudarHorario;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 16, 18),
      decoration: BoxDecoration(
        border: Border.all(
          color: ativo ? Cores.tinta : Cores.linha,
          width: ativo ? 2 : 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icone, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Cores.tintaSuave,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: ativo,
                activeTrackColor: Cores.tinta,
                onChanged: aoAtivar,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: ativo ? 1 : 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text(
                      'Todos os dias às',
                      style: TextStyle(fontSize: 16, color: Cores.tintaSuave),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Cores.fundoLateral,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: ativo ? aoMudarHorario : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Text(
                            horario,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ?extra,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icone, required this.texto});
  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icone, size: 20, color: Cores.tintaSuave),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 14,
            color: Cores.tintaSuave,
            height: 1.4,
          ),
        ),
      ),
    ],
  );
}
