import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../theme.dart';
import '../widgets/comuns.dart';

/// Árvore de tópicos a partir de uma lista plana.
class ArvoreTopicos {
  ArvoreTopicos(List<Topico> todos) {
    for (final t in todos) {
      (filhos[t.paiId] ??= []).add(t);
    }
  }

  final Map<String?, List<Topico>> filhos = {};

  List<Topico> raiz() => filhos[null] ?? const [];
  List<Topico> de(String id) => filhos[id] ?? const [];

  /// Folhas abaixo de [t] (ou o próprio [t] se não tiver filhos).
  List<Topico> folhas(Topico t) {
    final f = de(t.id);
    if (f.isEmpty) return [t];
    return [for (final c in f) ...folhas(c)];
  }
}

class MateriaScreen extends StatelessWidget {
  const MateriaScreen({
    super.key,
    required this.materiaId,
    required this.concursoId,
  });
  final String materiaId;
  final String concursoId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return StreamBuilder<Materia?>(
      stream: db.watchMateria(materiaId),
      builder: (context, snap) {
        final m = snap.data;
        if (m == null) return const Scaffold(body: SizedBox.shrink());
        final cor = Color(m.cor);
        return Scaffold(
          appBar: AppBar(toolbarHeight: 72),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _adicionarVarios(context),
            backgroundColor: Cores.tinta,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Tópicos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          body: StreamBuilder<List<Topico>>(
            stream: db.watchTopicos(materiaId),
            builder: (context, tSnap) {
              final arvore = ArvoreTopicos(tSnap.data ?? const []);
              final raiz = arvore.raiz();
              final folhas = [for (final t in raiz) ...arvore.folhas(t)];
              final vistos = folhas.where((t) => t.visto).length;
              final p = folhas.isEmpty ? 0.0 : vistos / folhas.length;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 120),
                    buildDefaultDragHandles: false,
                    header: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Bolinha(cor, tamanho: 14),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'MATÉRIA',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: Cores.tintaSuave,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  m.nome,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$vistos de ${folhas.length} tópicos vistos',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Cores.tintaSuave,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _Compartilhada(materiaId: m.id),
                              ],
                            ),
                          ),
                          AnelProgresso(
                            valor: p,
                            cor: cor,
                            tamanho: 96,
                            espessura: 10,
                          ),
                        ],
                      ),
                    ),
                    itemCount: raiz.length,
                    onReorderItem: (de, para) {
                      final ids = raiz.map((t) => t.id).toList();
                      ids.insert(para, ids.removeAt(de));
                      db.reordenarTopicos(ids);
                    },
                    itemBuilder: (context, i) => Padding(
                      key: ValueKey(raiz[i].id),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Cores.fundo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Cores.linha,
                            width: 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _NoTopico(
                          topico: raiz[i],
                          arvore: arvore,
                          irmaos: raiz,
                          cor: cor,
                          nivel: 0,
                          indiceRaiz: i,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _adicionarVarios(BuildContext context) async {
    final texto = await pedirTexto(
      context,
      titulo: 'Adicionar tópicos',
      multilinha: true,
      confirmar: 'Adicionar',
      ajuda: 'Um tópico por linha. Comece a linha com "-" para criar um subtópico do tópico acima.',
      dica: 'Crase\nPontuação\nConcordância\n- Nominal\n- Verbal',
    );
    if (texto == null || !context.mounted) return;
    await context.read<AppDatabase>().adicionarTopicosEmLote(materiaId, texto);
  }
}

class _Compartilhada extends StatelessWidget {
  const _Compartilhada({required this.materiaId});
  final String materiaId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Concurso>>(
      stream: context.read<AppDatabase>().watchConcursosDaMateria(materiaId),
      builder: (context, snap) {
        final l = snap.data ?? const [];
        if (l.length < 2) return const SizedBox.shrink();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Compartilhada com',
              style: TextStyle(fontSize: 13, color: Cores.tintaSuave),
            ),
            for (final c in l)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Cores.linha, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Bolinha(Color(c.cor), tamanho: 8),
                    const SizedBox(width: 6),
                    Text(
                      c.nome,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NoTopico extends StatelessWidget {
  const _NoTopico({
    required this.topico,
    required this.arvore,
    required this.irmaos,
    required this.cor,
    required this.nivel,
    this.indiceRaiz,
  });

  final Topico topico;
  final ArvoreTopicos arvore;
  final List<Topico> irmaos;
  final Color cor;
  final int nivel;
  final int? indiceRaiz;

  static const _maxNivel = 2;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final filhos = arvore.de(topico.id);
    final folhas = arvore.folhas(topico);
    final nVistos = folhas.where((t) => t.visto).length;
    final bool? marcado = filhos.isEmpty
        ? topico.visto
        : nVistos == folhas.length
        ? true
        : nVistos == 0
        ? false
        : null;

    Future<void> alternar() async {
      final alvo = marcado != true;
      if (filhos.isEmpty) {
        await db.marcarVisto(topico.id, alvo);
      } else {
        for (final f in folhas) {
          if (f.visto != alvo) await db.marcarVisto(f.id, alvo);
        }
        await db.marcarVisto(topico.id, alvo);
      }
      if (alvo && context.mounted) {
        avisar(
          context,
          'Visto! Revisões agendadas para amanhã, em 7 e em 30 dias.',
        );
      }
    }

    final linha = InkWell(
      onTap: alternar,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.0 + nivel * 28, 6, 4, 6),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.3,
              child: Checkbox(
                value: marcado,
                tristate: filhos.isNotEmpty,
                activeColor: cor,
                onChanged: (_) => alternar(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                topico.nome,
                style: TextStyle(
                  fontSize: nivel == 0 ? 18 : 16,
                  fontWeight: nivel == 0 ? FontWeight.w700 : FontWeight.w500,
                  color: marcado == true ? Cores.tintaSuave : Cores.tinta,
                  decoration: marcado == true
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: Cores.tintaFraca,
                ),
              ),
            ),
            if (filhos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '$nVistos/${folhas.length}',
                  style: const TextStyle(
                    color: Cores.tintaSuave,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: Cores.tintaSuave,
              ),
              onSelected: (v) => _acao(context, v),
              itemBuilder: (_) {
                final i = irmaos.indexWhere((t) => t.id == topico.id);
                return [
                  const PopupMenuItem(
                    value: 'renomear',
                    child: Text('Renomear'),
                  ),
                  if (nivel < _maxNivel)
                    const PopupMenuItem(
                      value: 'sub',
                      child: Text('Adicionar subtópico'),
                    ),
                  if (i > 0)
                    const PopupMenuItem(
                      value: 'subir',
                      child: Text('Mover para cima'),
                    ),
                  if (i < irmaos.length - 1)
                    const PopupMenuItem(
                      value: 'descer',
                      child: Text('Mover para baixo'),
                    ),
                  const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                ];
              },
            ),
            if (indiceRaiz != null)
              ReorderableDragStartListener(
                index: indiceRaiz!,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: Cores.tintaFraca,
                  ),
                ),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );

    if (filhos.isEmpty) return linha;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        linha,
        for (final f in filhos)
          _NoTopico(
            topico: f,
            arvore: arvore,
            irmaos: filhos,
            cor: cor,
            nivel: nivel + 1,
          ),
        const SizedBox(height: 6),
      ],
    );
  }

  Future<void> _acao(BuildContext context, String v) async {
    final db = context.read<AppDatabase>();
    switch (v) {
      case 'renomear':
        final nome = await pedirTexto(
          context,
          titulo: 'Renomear tópico',
          inicial: topico.nome,
        );
        if (nome != null) await db.renomearTopico(topico.id, nome);
      case 'sub':
        final nome = await pedirTexto(
          context,
          titulo: 'Novo subtópico',
          dica: 'Subtópico de "${topico.nome}"',
          confirmar: 'Adicionar',
        );
        if (nome != null) {
          await db.adicionarTopico(topico.materiaId, nome, paiId: topico.id);
        }
      case 'subir' || 'descer':
        final ids = irmaos.map((t) => t.id).toList();
        final i = ids.indexOf(topico.id);
        final j = v == 'subir' ? i - 1 : i + 1;
        ids[i] = ids[j];
        ids[j] = topico.id;
        await db.reordenarTopicos(ids);
      case 'excluir':
        final temFilhos = arvore.de(topico.id).isNotEmpty;
        final ok = await confirmar(
          context,
          titulo: 'Excluir "${topico.nome}"?',
          mensagem: temFilhos
              ? 'Os subtópicos e as revisões também serão apagados.'
              : 'As revisões deste tópico também serão apagadas.',
        );
        if (ok) await db.excluirTopico(topico.id);
    }
  }
}
