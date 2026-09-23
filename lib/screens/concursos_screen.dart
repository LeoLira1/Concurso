import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../theme.dart';
import '../widgets/comuns.dart';
import 'concurso_form.dart';
import 'edital_screen.dart';

class ConcursosScreen extends StatelessWidget {
  const ConcursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 72),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormConcurso(context),
        backgroundColor: Cores.tinta,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Novo concurso',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<List<Concurso>>(
        stream: db.watchConcursos(),
        builder: (context, snap) {
          final lista = snap.data ?? const <Concurso>[];
          final temExemplo = lista.any((c) => c.exemplo);
          return StreamBuilder<Map<String, ProgressoConcurso>>(
            stream: db.watchProgressoConcursos(),
            builder: (context, progSnap) {
              final prog = progSnap.data ?? const {};
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                    sliver: SliverToBoxAdapter(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 16,
                        spacing: 16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meus concursos',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lista.isEmpty
                                    ? 'Cadastre quantos quiser.'
                                    : '${lista.length} ${lista.length == 1 ? 'concurso' : 'concursos'} · toque para editar o edital',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Cores.tintaSuave,
                                ),
                              ),
                            ],
                          ),
                          if (!temExemplo)
                            OutlinedButton.icon(
                              onPressed: () async {
                                await db.carregarExemplo();
                                if (context.mounted) {
                                  avisar(
                                    context,
                                    'Exemplo "Guarda Municipal" carregado',
                                  );
                                }
                              },
                              icon: const Icon(Icons.auto_awesome_outlined),
                              label: const Text('Carregar exemplo'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (lista.isEmpty && snap.hasData)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _Vazio(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 120),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 440,
                              mainAxisExtent: 250,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) =>
                              _CardConcurso(lista[i], prog[lista[i].id]),
                          childCount: lista.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'Nenhum concurso ainda.\nToque em "Novo concurso" ou carregue o exemplo.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Cores.tintaSuave, height: 1.5),
      ),
    ),
  );
}

class _CardConcurso extends StatelessWidget {
  const _CardConcurso(this.c, this.prog);
  final Concurso c;
  final ProgressoConcurso? prog;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final cor = Color(c.cor);
    final p = prog?.progresso ?? 0;
    final contagem = contagemProva(c.dataProva);
    return Material(
      color: Cores.fundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: c.foco ? Cores.tinta : Cores.linha,
          width: c.foco ? 2.5 : 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditalScreen(concursoId: c.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 8, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Bolinha(cor, tamanho: 18),
                  const SizedBox(width: 10),
                  if (c.foco)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Cores.tinta,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'FOCO ATUAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  if (c.exemplo) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Cores.linha, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'EXEMPLO',
                        style: TextStyle(
                          color: Cores.tintaSuave,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded),
                    onSelected: (v) async {
                      switch (v) {
                        case 'foco':
                          await db.definirFoco(c.id);
                        case 'editar':
                          await abrirFormConcurso(context, concurso: c);
                        case 'excluir':
                          final ok = await confirmar(
                            context,
                            titulo: 'Excluir "${c.nome}"?',
                            mensagem: 'O edital deste concurso será apagado. Matérias usadas por outros concursos continuam lá, com o progresso.',
                          );
                          if (ok) await db.excluirConcurso(c.id);
                      }
                    },
                    itemBuilder: (_) => [
                      if (!c.foco)
                        const PopupMenuItem(
                          value: 'foco',
                          child: Text('Definir como foco'),
                        ),
                      const PopupMenuItem(
                        value: 'editar',
                        child: Text('Editar'),
                      ),
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  c.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (c.banca.isNotEmpty) c.banca,
                  contagem ?? 'Sem data de prova',
                ].join(' · '),
                style: const TextStyle(fontSize: 15, color: Cores.tintaSuave),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: p,
                          minHeight: 10,
                          color: cor,
                          backgroundColor: cor.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(p * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${prog?.materias ?? 0} matérias · ${prog?.vistos ?? 0}/${prog?.total ?? 0} tópicos',
                style: const TextStyle(fontSize: 13, color: Cores.tintaSuave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
