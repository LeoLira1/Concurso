import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/comuns.dart';
import 'concurso_form.dart';
import 'materia_screen.dart';

/// Edital verticalizado de um concurso: matérias com anel de progresso.
class EditalScreen extends StatelessWidget {
  const EditalScreen({super.key, required this.concursoId});
  final String concursoId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return StreamBuilder<Concurso?>(
      stream: db.watchConcurso(concursoId),
      builder: (context, snap) {
        final c = snap.data;
        if (c == null) {
          return const Scaffold(body: SizedBox.shrink());
        }
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 72,
            actions: [
              if (!c.foco)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Pilula(
                    icone: Icons.center_focus_strong_outlined,
                    rotulo: 'Definir como foco',
                    aoTocar: () => db.definirFoco(c.id),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Pilula(
                  icone: Icons.edit_outlined,
                  tooltip: 'Editar concurso',
                  aoTocar: () => abrirFormConcurso(context, concurso: c),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _novaMateria(context, c),
            backgroundColor: Cores.tinta,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Matéria',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          body: StreamBuilder<List<MateriaInfo>>(
            stream: db.watchMaterias(c.id),
            builder: (context, mSnap) {
              final mats = mSnap.data ?? const <MateriaInfo>[];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 120),
                    buildDefaultDragHandles: false,
                    header: _Cabecalho(c, mats),
                    itemCount: mats.length,
                    onReorderItem: (de, para) {
                      final ids = mats.map((m) => m.materia.id).toList();
                      ids.insert(para, ids.removeAt(de));
                      db.reordenarMaterias(c.id, ids);
                    },
                    itemBuilder: (context, i) => Padding(
                      key: ValueKey(mats[i].materia.id),
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CardMateria(
                        concurso: c,
                        info: mats[i],
                        indice: i,
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

  Future<void> _novaMateria(BuildContext context, Concurso c) async {
    final db = context.read<AppDatabase>();
    final existentes = await db.todasMaterias();
    if (!context.mounted) return;
    final r = await showDialog<(String, int)>(
      context: context,
      builder: (_) => _NovaMateriaDialog(existentes: existentes),
    );
    if (r == null) return;
    await db.adicionarMateria(c.id, r.$1, r.$2);
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho(this.c, this.mats);
  final Concurso c;
  final List<MateriaInfo> mats;

  @override
  Widget build(BuildContext context) {
    final total = mats.fold<int>(0, (s, m) => s + m.total);
    final vistos = mats.fold<int>(0, (s, m) => s + m.vistos);
    final p = total == 0 ? 0.0 : vistos / total;
    final contagem = contagemProva(c.dataProva);
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Bolinha(Color(c.cor), tamanho: 14),
                    const SizedBox(width: 8),
                    Text(
                      c.foco ? 'FOCO ATUAL' : 'EDITAL',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: Cores.tintaSuave,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(c.nome, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 6),
                Text(
                  [
                    if (c.banca.isNotEmpty) c.banca,
                    if (c.dataProva != null)
                      '${dataCurta(c.dataProva!)} · $contagem',
                    '${mats.length} matérias',
                  ].join('  ·  '),
                  style: const TextStyle(fontSize: 16, color: Cores.tintaSuave),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AnelProgresso(
            valor: p,
            cor: Color(c.cor),
            tamanho: 96,
            espessura: 10,
          ),
        ],
      ),
    );
  }
}

class _CardMateria extends StatelessWidget {
  const _CardMateria({
    required this.concurso,
    required this.info,
    required this.indice,
  });
  final Concurso concurso;
  final MateriaInfo info;
  final int indice;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final m = info.materia;
    final cor = Color(m.cor);
    return Material(
      color: Cores.fundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Cores.linha, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MateriaScreen(materiaId: m.id, concursoId: concurso.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 8, 18),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 56,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.total == 0
                          ? 'Nenhum tópico ainda'
                          : '${info.vistos} de ${info.total} tópicos vistos',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Cores.tintaSuave,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnelProgresso(valor: info.progresso, cor: cor, tamanho: 60),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (v) async {
                  switch (v) {
                    case 'renomear':
                      final nome = await pedirTexto(
                        context,
                        titulo: 'Renomear matéria',
                        inicial: m.nome,
                      );
                      if (nome == null) return;
                      final ok = await db.renomearMateria(m.id, nome);
                      if (!ok && context.mounted) {
                        avisar(
                          context,
                          'Já existe uma matéria chamada "$nome"',
                        );
                      }
                    case 'cor':
                      final c = await escolherCor(context, m.cor);
                      if (c != null) await db.corMateria(m.id, c);
                    case 'remover':
                      final ok = await confirmar(
                        context,
                        titulo: 'Remover "${m.nome}"?',
                        mensagem: 'A matéria sai deste edital. Se nenhum outro concurso usar, os tópicos e o progresso dela serão apagados.',
                        acao: 'Remover',
                      );
                      if (ok)
                        await db.removerMateriaDoConcurso(concurso.id, m.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'renomear', child: Text('Renomear')),
                  PopupMenuItem(value: 'cor', child: Text('Mudar cor')),
                  PopupMenuItem(
                    value: 'remover',
                    child: Text('Remover do edital'),
                  ),
                ],
              ),
              ReorderableDragStartListener(
                index: indice,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: Cores.tintaFraca,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NovaMateriaDialog extends StatefulWidget {
  const _NovaMateriaDialog({required this.existentes});
  final List<Materia> existentes;

  @override
  State<_NovaMateriaDialog> createState() => _NovaMateriaDialogState();
}

class _NovaMateriaDialogState extends State<_NovaMateriaDialog> {
  String _nome = '';
  late int _cor = Cores.proximaCor(widget.existentes.map((m) => m.cor));

  Materia? get _existente {
    final k = chaveMateria(_nome);
    for (final m in widget.existentes) {
      if (m.chave == k) return m;
    }
    return null;
  }

  void _ok() {
    if (_nome.trim().isEmpty) return;
    Navigator.pop(context, (_nome.trim(), _existente?.cor ?? _cor));
  }

  @override
  Widget build(BuildContext context) {
    final existente = _existente;
    return AlertDialog(
      title: Text(
        'Nova matéria',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<String>(
              optionsBuilder: (v) {
                final k = chaveMateria(v.text);
                if (k.isEmpty) return const [];
                return widget.existentes
                    .where((m) => m.chave.contains(k))
                    .map((m) => m.nome);
              },
              onSelected: (v) => setState(() => _nome = v),
              fieldViewBuilder: (context, ctrl, foco, onSubmit) => TextField(
                controller: ctrl,
                focusNode: foco,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Ex.: Língua Portuguesa',
                ),
                onChanged: (v) => setState(() => _nome = v),
                onSubmitted: (_) => _ok(),
              ),
            ),
            const SizedBox(height: 20),
            if (existente != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Cores.fundoLateral,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Bolinha(Color(existente.cor), tamanho: 14),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Essa matéria já existe em outro concurso. Tópicos, progresso, revisões e questões serão compartilhados.',
                        style: TextStyle(fontSize: 14, color: Cores.tintaSuave),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              const Text('Cor', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SeletorCores(
                valor: _cor,
                aoMudar: (c) => setState(() => _cor = c),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _ok, child: const Text('Adicionar')),
      ],
    );
  }
}
