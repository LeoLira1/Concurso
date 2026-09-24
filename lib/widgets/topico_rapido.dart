import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/provas_db.dart';
import '../logic/metodo.dart';
import '../screens/cronometro_screen.dart';
import '../screens/topico_screen.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'assistir.dart';
import 'comuns.dart';

/// Janela rápida de um tópico (aberta pela sidebar): estudar agora,
/// marcar como visto e histórico de sessões e revisões.
Future<void> abrirTopicoRapido(BuildContext context, String topicoId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 680),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => _TopicoRapido(topicoId: topicoId),
  );
}

class _TopicoRapido extends StatelessWidget {
  const _TopicoRapido({required this.topicoId});
  final String topicoId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<List<Topico>>(
      chave: topicoId,
      stream: () =>
          (db.select(db.topicos)..where((t) => t.id.equals(topicoId))).watch(),
      builder: (context, l) {
        final t = (l == null || l.isEmpty) ? null : l.first;
        if (t == null) return const SizedBox(height: 240);
        return Assistir<Materia?>(
          chave: t.materiaId,
          stream: () => db.watchMateria(t.materiaId),
          builder: (context, m) {
            if (m == null) return const SizedBox(height: 240);
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.72,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, rolagem) => ListView(
                controller: rolagem,
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                children: [
                  Row(
                    children: [
                      Bolinha(Color(m.cor), tamanho: 12),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m.nome.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Cores.tintaSuave,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.nome,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 64),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      abrirCronometro(context, materiaId: m.id, topicoId: t.id);
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: const Text(
                      'Estudar agora',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await db.marcarVisto(t.id, !t.visto);
                            if (!t.visto && context.mounted) {
                              avisar(
                                context,
                                'Visto! Revisões agendadas para amanhã, em 7 e em 30 dias.',
                              );
                            }
                          },
                          icon: Icon(
                            t.visto
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                          ),
                          label: Text(
                            t.visto ? 'Visto — desmarcar' : 'Marcar como visto',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TopicoScreen(topicoId: t.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.style_outlined),
                          label: const Text('Resumos e flashcards'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  _Historico(topico: t),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Historico extends StatelessWidget {
  const _Historico({required this.topico});
  final Topico topico;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<List<Revisao>>(
      chave: topico.id,
      stream: () => db.watchRevisoesDoTopico(topico.id),
      builder: (context, revs) => Assistir<List<Sessao>>(
        chave: topico.id,
        stream: () => db.watchSessoesDoTopicoComQuestoes(topico.id),
        builder: (context, sessoes) {
          final ss = sessoes ?? const <Sessao>[];
          final total = ss.fold<int>(0, (a, s) => a + s.minutos);
          final feitas = ss.fold<int>(0, (a, s) => a + s.questoesFeitas);
          final acertos = ss.fold<int>(0, (a, s) => a + s.questoesAcertos);
          final resumo = [
            if (topico.visto && topico.vistoEm != null)
              'visto em ${dataCurta(topico.vistoEm!)}',
            '${ss.length} ${ss.length == 1 ? 'sessão' : 'sessões'}',
            if (total > 0) minutosFmt(total),
            if (feitas > 0)
              '${(acertos * 100 / feitas).round()}% em $feitas questões',
          ].join('  ·  ');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Histórico', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                resumo,
                style: const TextStyle(fontSize: 14, color: Cores.tintaSuave),
              ),
              if ((revs ?? const []).isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in revs!)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: r.feitaEm != null
                              ? Cores.fundoLateral
                              : Cores.fundo,
                          border: Border.all(color: Cores.linha, width: 1.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              r.feitaEm != null
                                  ? Icons.check_rounded
                                  : Icons.replay_rounded,
                              size: 16,
                              color: r.feitaEm != null
                                  ? const Color(0xFF1F9D55)
                                  : Cores.tintaSuave,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Revisão ${r.intervaloDias}d · '
                              '${r.feitaEm != null ? 'feita ${dataCurta(r.feitaEm!)}' : dataCurta(r.dataPrevista)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              if (ss.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Nenhuma sessão registrada neste tópico ainda.',
                    style: TextStyle(fontSize: 15, color: Cores.tintaSuave),
                  ),
                ),
              for (final s in ss) _LinhaSessao(s),
            ],
          );
        },
      ),
    );
  }
}

class _LinhaSessao extends StatelessWidget {
  const _LinhaSessao(this.s);
  final Sessao s;

  @override
  Widget build(BuildContext context) {
    final metodo = Metodo.deChave(s.metodo);
    final detalhes = [
      minutosFmt(s.minutos),
      if (metodo != null) metodo.rotulo,
      if (s.questoesFeitas > 0)
        '${s.questoesAcertos}/${s.questoesFeitas} questões',
      if (s.paginas > 0) '${s.paginas} pág.',
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Cores.fundoLateral,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              '${s.dia.day.toString().padLeft(2, '0')}/${s.dia.month.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detalhes,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (s.pontoParada != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.bookmark_rounded,
                          size: 16,
                          color: Color(0xFFB8892F),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          s.pontoParada!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Cores.tintaSuave,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
