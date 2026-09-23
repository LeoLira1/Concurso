import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../screens/home_screen.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'comuns.dart';

/// Folha do dia: sessões registradas e registro manual rápido.
/// (O timer pomodoro, na próxima etapa, vai registrar sessões sozinho.)
Future<void> abrirDia(BuildContext context, DateTime dia, Painel painel) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 640),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => _DiaSheet(dia: dia, painel: painel),
  );
}

class _DiaSheet extends StatefulWidget {
  const _DiaSheet({required this.dia, required this.painel});
  final DateTime dia;
  final Painel painel;

  @override
  State<_DiaSheet> createState() => _DiaSheetState();
}

class _DiaSheetState extends State<_DiaSheet> {
  late String? _materia =
      widget.painel.filtro ??
      (widget.painel.materias.isEmpty
          ? null
          : widget.painel.materias.first.materia.id);
  int _minutos = 25;
  late final Stream<List<Sessao>> _sessoes = context
      .read<AppDatabase>()
      .watchSessoes(widget.dia, widget.dia);
  late final Stream<List<Materia>> _materias = context
      .read<AppDatabase>()
      .watchTodasMaterias();

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final t = Theme.of(context).textTheme;
    final futuro = widget.dia.isAfter(soDia(DateTime.now()));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(dataLonga(widget.dia), style: t.headlineMedium),
          const SizedBox(height: 16),
          StreamBuilder<List<Materia>>(
            stream: _materias,
            builder: (context, mSnap) {
              final nomes = {
                for (final m in mSnap.data ?? const <Materia>[]) m.id: m,
              };
              return StreamBuilder<List<Sessao>>(
                stream: _sessoes,
                builder: (context, snap) {
                  final l = snap.data ?? const <Sessao>[];
                  if (l.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Nenhum estudo registrado neste dia.',
                        style: TextStyle(fontSize: 16, color: Cores.tintaSuave),
                      ),
                    );
                  }
                  final total = l.fold<int>(0, (a, s) => a + s.minutos);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: ${minutosFmt(total)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final s in l)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Cores.linha, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Bolinha(
                                nomes[s.materiaId] == null
                                    ? Cores.tintaFraca
                                    : Color(nomes[s.materiaId]!.cor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  nomes[s.materiaId]?.nome ?? 'Estudo livre',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                minutosFmt(s.minutos),
                                style: const TextStyle(color: Cores.tintaSuave),
                              ),
                              IconButton(
                                tooltip: 'Apagar',
                                onPressed: () => db.excluirSessao(s.id),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          if (!futuro) ...[
            const SizedBox(height: 24),
            Text('Registrar estudo', style: t.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in widget.painel.materias)
                  ChoiceChip(
                    avatar: Bolinha(Color(m.materia.cor)),
                    label: Text(m.materia.nome),
                    selected: _materia == m.materia.id,
                    showCheckmark: false,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    onSelected: (_) => setState(() => _materia = m.materia.id),
                  ),
                ChoiceChip(
                  label: const Text('Estudo livre'),
                  selected: _materia == null,
                  showCheckmark: false,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  onSelected: (_) => setState(() => _materia = null),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final m in const [25, 50, 90, 120])
                  ChoiceChip(
                    label: Text(minutosFmt(m)),
                    selected: _minutos == m,
                    showCheckmark: false,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    onSelected: (_) => setState(() => _minutos = m),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                await db.registrarSessao(
                  dia: widget.dia,
                  minutos: _minutos,
                  materiaId: _materia,
                );
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Marcar dia como estudado'),
            ),
          ],
        ],
      ),
    );
  }
}
