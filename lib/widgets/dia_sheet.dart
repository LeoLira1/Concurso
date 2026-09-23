import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/metodo.dart';
import '../screens/home_screen.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'comuns.dart';
import 'registro_sessao.dart';

/// Folha do dia: sessões registradas (com método, questões, páginas e
/// ponto de parada) e registro manual de uma sessão.
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
  late final Stream<List<Sessao>> _sessoes = context
      .read<AppDatabase>()
      .watchSessoes(widget.dia, widget.dia);
  late final Stream<List<Materia>> _materias = context
      .read<AppDatabase>()
      .watchTodasMaterias();
  late final Stream<List<Topico>> _topicos = context
      .read<AppDatabase>()
      .watchTodosTopicos();

  Future<void> _registrar() async {
    final db = context.read<AppDatabase>();
    final p = widget.painel;
    final r = await abrirRegistro(
      context,
      titulo: 'Registrar estudo',
      materias: p.materias,
      inicial: RegistroSessao(
        materiaId:
            p.filtro ??
            (p.materias.isEmpty ? null : p.materias.first.materia.id),
        minutos: 50,
      ),
    );
    if (r != null && !r.descartar) await r.salvar(db, widget.dia);
  }

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
          StreamBuilder<List<Topico>>(
            stream: _topicos,
            builder: (context, tSnap) {
              final topicos = {
                for (final x in tSnap.data ?? const <Topico>[]) x.id: x,
              };
              return StreamBuilder<List<Materia>>(
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Cores.tintaSuave,
                            ),
                          ),
                        );
                      }
                      final total = l.fold<int>(0, (a, s) => a + s.minutos);
                      final feitas = l.fold<int>(
                        0,
                        (a, s) => a + s.questoesFeitas,
                      );
                      final acertos = l.fold<int>(
                        0,
                        (a, s) => a + s.questoesAcertos,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            [
                              'Total: ${minutosFmt(total)}',
                              if (feitas > 0)
                                '$feitas questões · ${(acertos * 100 / feitas).round()}% de acerto',
                            ].join('  ·  '),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final s in l)
                            _LinhaSessao(
                              s: s,
                              materia: nomes[s.materiaId],
                              topico: topicos[s.topicoId],
                              aoApagar: () => db.excluirSessao(s.id),
                            ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          if (!futuro) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _registrar,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar estudo'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinhaSessao extends StatelessWidget {
  const _LinhaSessao({
    required this.s,
    required this.materia,
    required this.topico,
    required this.aoApagar,
  });

  final Sessao s;
  final Materia? materia;
  final Topico? topico;
  final VoidCallback aoApagar;

  @override
  Widget build(BuildContext context) {
    final metodo = Metodo.deChave(s.metodo);
    final detalhes = [
      minutosFmt(s.minutos),
      if (metodo != null) metodo.rotulo,
      if (s.questoesFeitas > 0)
        '${s.questoesAcertos}/${s.questoesFeitas} questões (${(s.questoesAcertos * 100 / s.questoesFeitas).round()}%)',
      if (s.paginas > 0) '${s.paginas} pág.',
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(
        border: Border.all(color: Cores.linha, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Bolinha(
              materia == null ? Cores.tintaFraca : Color(materia!.cor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  materia?.nome ?? 'Estudo livre',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (topico != null)
                  Text(topico!.nome, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  detalhes,
                  style: const TextStyle(fontSize: 14, color: Cores.tintaSuave),
                ),
                if (s.pontoParada != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.bookmark_rounded,
                        size: 16,
                        color: Color(0xFFB8892F),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          s.pontoParada!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Apagar',
            onPressed: aoApagar,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}
