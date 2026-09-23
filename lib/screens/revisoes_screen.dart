import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/metodo.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import 'cronometro_screen.dart';
import 'flashcards_screen.dart';

/// Revisões espaçadas: atrasadas, de hoje e dos próximos 7 dias.
class RevisoesScreen extends StatelessWidget {
  const RevisoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final hoje = soDia(DateTime.now());
    final ate = hoje.add(const Duration(days: 7));
    return Scaffold(
      appBar: AppBar(toolbarHeight: 72),
      body: Assistir<List<RevisaoInfo>>(
        chave: hoje,
        stream: () => db.watchRevisoesPendentes(ate),
        builder: (context, lista) {
          final l = lista ?? const <RevisaoInfo>[];
          final atrasadas = [
            for (final r in l)
              if (r.revisao.dataPrevista.isBefore(hoje)) r,
          ];
          final deHoje = [
            for (final r in l)
              if (soDia(r.revisao.dataPrevista) == hoje) r,
          ];
          final proximas = [
            for (final r in l)
              if (r.revisao.dataPrevista.isAfter(hoje)) r,
          ];
          final paraFazer = atrasadas.length + deHoje.length;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                children: [
                  Text(
                    'Revisões',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    paraFazer == 0
                        ? 'Nada para revisar hoje.'
                        : '$paraFazer para fazer hoje${atrasadas.isEmpty ? '' : ' (${atrasadas.length} atrasada${atrasadas.length == 1 ? '' : 's'})'}.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Cores.tintaSuave,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ao marcar um tópico como visto, o app agenda revisões em 1, 7 e 30 dias. '
                    'Uma sessão com método "Revisão" no tópico já conta como feita.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Cores.tintaSuave,
                      height: 1.4,
                    ),
                  ),
                  if (l.isEmpty && lista != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(
                        child: Icon(
                          Icons.done_all_rounded,
                          size: 64,
                          color: Cores.tintaFraca,
                        ),
                      ),
                    ),
                  const _Flashcards(),
                  if (atrasadas.isNotEmpty)
                    _Secao('Atrasadas', atrasadas, destaque: Cores.acento),
                  if (deHoje.isNotEmpty) _Secao('Hoje', deHoje),
                  if (proximas.isNotEmpty)
                    _Secao('Próximos 7 dias', proximas, futura: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.titulo, this.itens, {this.destaque, this.futura = false});
  final String titulo;
  final List<RevisaoInfo> itens;
  final Color? destaque;
  final bool futura;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                titulo,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: destaque),
              ),
              const SizedBox(width: 8),
              Text(
                '${itens.length}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Cores.tintaSuave,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final r in itens) _LinhaRevisao(r, futura: futura),
        ],
      ),
    );
  }
}

class _LinhaRevisao extends StatelessWidget {
  const _LinhaRevisao(this.r, {required this.futura});
  final RevisaoInfo r;
  final bool futura;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final cor = Color(r.materia.cor);
    final d = r.revisao.intervaloDias;
    final quando = futura
        ? dataLonga(r.revisao.dataPrevista)
        : 'visto em ${dataCurta(r.topico.vistoEm ?? r.revisao.dataPrevista)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
      decoration: BoxDecoration(
        border: Border.all(color: Cores.linha, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 44,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.topico.nome,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${r.materia.nome}  ·  revisão de $d ${d == 1 ? 'dia' : 'dias'}  ·  $quando',
                  style: const TextStyle(fontSize: 14, color: Cores.tintaSuave),
                ),
              ],
            ),
          ),
          if (!futura) ...[
            const SizedBox(width: 8),
            Pilula(
              icone: Icons.play_arrow_rounded,
              rotulo: 'Revisar',
              aoTocar: () => abrirCronometro(
                context,
                materiaId: r.materia.id,
                topicoId: r.topico.id,
                metodo: Metodo.revisao.chave,
                metaMin: 25,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Pilula(
            icone: Icons.check_rounded,
            tooltip: 'Marcar como feita',
            aoTocar: () async {
              await db.concluirRevisao(r.revisao.id);
              if (context.mounted) {
                avisar(context, 'Revisão de "${r.topico.nome}" feita');
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Cartões de flashcard que vencem hoje (todas as matérias).
class _Flashcards extends StatelessWidget {
  const _Flashcards();

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<List<CartaoInfo>>(
      chave: 'cartoes',
      stream: db.watchCartoesParaRevisar,
      builder: (context, l) {
        final n = l?.length ?? 0;
        if (n == 0) return const SizedBox.shrink();
        final materias = {for (final c in l!) c.materia.id: c.materia}.values
            .toList();
        return Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
          decoration: BoxDecoration(
            color: Cores.fundoLateral,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.style_outlined, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$n flashcard${n == 1 ? '' : 's'} para revisar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        for (final m in materias.take(4))
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Bolinha(Color(m.cor), tamanho: 9),
                              const SizedBox(width: 5),
                              Text(
                                m.nome,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Cores.tintaSuave,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => abrirEstudoFlashcards(
                  context,
                  titulo: 'Flashcards de hoje',
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Estudar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
