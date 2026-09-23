import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../screens/ciclo_screen.dart';
import '../screens/concursos_screen.dart';
import '../screens/edital_screen.dart';
import '../screens/home_screen.dart';
import '../screens/materia_screen.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'assistir.dart';
import 'comuns.dart';

/// Sidebar de matérias (referência: biblioteca — bolinha colorida,
/// contagem à direita e subitens aninhados com linha-guia).
class Sidebar extends StatefulWidget {
  const Sidebar({super.key, required this.painel});
  final Painel painel;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final _abertas = <String>{};

  void _fecharDrawer() {
    final s = Scaffold.maybeOf(context);
    if (s != null && s.isDrawerOpen) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final estado = context.read<AppState>();
    final p = widget.painel;
    final totalTopicos = p.materias.fold<int>(0, (s, m) => s + m.total);

    return ColoredBox(
      color: Cores.fundoLateral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Marca(tamanho: 34),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SeletorConcurso(painel: p, verTudo: estado.verTudo),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Alternador(
              verTudo: estado.verTudo,
              aoMudar: (v) => estado.verTudo = v,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Assistir<List<Topico>>(
              chave: 'topicos',
              stream: db.watchTodosTopicos,
              builder: (context, topicos) {
                final arvore = ArvoreTopicos(
                  (topicos ?? const <Topico>[])
                      .where((t) => t.paiId != null)
                      .toList(),
                );
                final raizPorMateria = <String, List<Topico>>{};
                for (final t in topicos ?? const <Topico>[]) {
                  if (t.paiId == null)
                    (raizPorMateria[t.materiaId] ??= []).add(t);
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  children: [
                    _Linha(
                      icone: Icons.grid_view_rounded,
                      rotulo: 'Todas as matérias',
                      contagem: totalTopicos,
                      selecionada: p.filtro == null,
                      aoTocar: estado.limparFiltro,
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 20, 14, 8),
                      child: Text(
                        'Matérias',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Cores.tintaSuave,
                        ),
                      ),
                    ),
                    if (p.materias.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text(
                          'Nenhuma matéria neste edital ainda.',
                          style: TextStyle(color: Cores.tintaSuave),
                        ),
                      ),
                    for (final m in p.materias) ...[
                      _Linha(
                        cor: Color(m.materia.cor),
                        rotulo: m.materia.nome,
                        contagem: m.total,
                        selecionada: p.filtro == m.materia.id,
                        aberta: _abertas.contains(m.materia.id),
                        aoAbrir:
                            (raizPorMateria[m.materia.id] ?? const []).isEmpty
                            ? null
                            : () => setState(() {
                                if (!_abertas.remove(m.materia.id)) {
                                  _abertas.add(m.materia.id);
                                }
                              }),
                        aoTocar: () => estado.alternarFiltro(m.materia.id),
                        aoSegurar: () {
                          _fecharDrawer();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MateriaScreen(
                                materiaId: m.materia.id,
                                concursoId: p.foco.id,
                              ),
                            ),
                          );
                        },
                      ),
                      if (_abertas.contains(m.materia.id))
                        _Aninhados(
                          topicos: raizPorMateria[m.materia.id] ?? const [],
                          arvore: arvore,
                          cor: Color(m.materia.cor),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: [
                if (!estado.verTudo)
                  _Linha(
                    icone: Icons.checklist_rounded,
                    rotulo: 'Editar edital',
                    aoTocar: () {
                      _fecharDrawer();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditalScreen(concursoId: p.foco.id),
                        ),
                      );
                    },
                  ),
                _Linha(
                  icone: Icons.autorenew_rounded,
                  rotulo: 'Ciclo de estudos',
                  aoTocar: () {
                    _fecharDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CicloScreen(concursoId: p.foco.id),
                      ),
                    );
                  },
                ),
                _Linha(
                  icone: Icons.folder_open_rounded,
                  rotulo: 'Meus concursos',
                  contagem: p.concursos.length,
                  aoTocar: () {
                    _fecharDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConcursosScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeletorConcurso extends StatelessWidget {
  const _SeletorConcurso({required this.painel, required this.verTudo});
  final Painel painel;
  final bool verTudo;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final estado = context.read<AppState>();
    final c = painel.foco;
    final sub = verTudo
        ? '${painel.concursos.length} concursos juntos'
        : [
            if (c.banca.isNotEmpty) c.banca,
            contagemProva(c.dataProva) ?? 'Sem data de prova',
          ].join(' · ');
    return Material(
      color: Cores.fundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Cores.linha, width: 1.5),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Trocar concurso em foco',
        position: PopupMenuPosition.under,
        onSelected: (id) async {
          if (id == '*') {
            estado.verTudo = true;
          } else {
            await db.definirFoco(id);
            estado.verTudo = false;
          }
        },
        itemBuilder: (_) => [
          for (final x in painel.concursos)
            PopupMenuItem(
              value: x.id,
              height: 52,
              child: Row(
                children: [
                  Bolinha(Color(x.cor)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      x.nome,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: x.foco ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (x.foco && !verTudo)
                    const Icon(Icons.check_rounded, size: 20),
                ],
              ),
            ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: '*',
            height: 52,
            child: Row(
              children: [
                const Icon(Icons.layers_outlined, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ver todos juntos',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                if (verTudo) const Icon(Icons.check_rounded, size: 20),
              ],
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              if (verTudo)
                const Icon(Icons.layers_outlined, size: 22)
              else
                Bolinha(Color(c.cor), tamanho: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verTudo ? 'TODOS OS CONCURSOS' : 'FOCO ATUAL',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: Cores.tintaSuave,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      verTudo ? 'Visão geral' : c.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Cores.tintaSuave,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.unfold_more_rounded, color: Cores.tintaSuave),
            ],
          ),
        ),
      ),
    );
  }
}

class _Alternador extends StatelessWidget {
  const _Alternador({required this.verTudo, required this.aoMudar});
  final bool verTudo;
  final ValueChanged<bool> aoMudar;

  @override
  Widget build(BuildContext context) {
    Widget opcao(String rotulo, bool valor) {
      final ativo = verTudo == valor;
      return Expanded(
        child: GestureDetector(
          onTap: () => aoMudar(valor),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ativo ? Cores.fundo : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: ativo
                  ? const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              rotulo,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ativo ? Cores.tinta : Cores.tintaSuave,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDECE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [opcao('Foco', false), opcao('Tudo junto', true)]),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    this.cor,
    this.icone,
    required this.rotulo,
    this.contagem,
    this.selecionada = false,
    this.aberta = false,
    this.aoAbrir,
    required this.aoTocar,
    this.aoSegurar,
  });

  final Color? cor;
  final IconData? icone;
  final String rotulo;
  final int? contagem;
  final bool selecionada;
  final bool aberta;
  final VoidCallback? aoAbrir;
  final VoidCallback aoTocar;
  final VoidCallback? aoSegurar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selecionada ? const Color(0xFFEDECE8) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: aoTocar,
          onLongPress: aoSegurar,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: Row(
              children: [
                const SizedBox(width: 14),
                if (cor != null)
                  Bolinha(cor!, tamanho: 13)
                else if (icone != null)
                  Icon(icone, size: 20, color: Cores.tinta),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rotulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selecionada
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
                if (contagem != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '$contagem',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Cores.tintaSuave,
                      ),
                    ),
                  ),
                if (aoAbrir != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: aoAbrir,
                    icon: AnimatedRotation(
                      turns: aberta ? 0.25 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Cores.tintaSuave,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Aninhados extends StatelessWidget {
  const _Aninhados({
    required this.topicos,
    required this.arvore,
    required this.cor,
  });
  final List<Topico> topicos;
  final ArvoreTopicos arvore;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 2, bottom: 8),
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Cores.linha, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final t in topicos) ...[
            _TopicoMini(t, arvore.de(t.id).length, cor),
            if (arvore.de(t.id).isNotEmpty)
              _Aninhados(topicos: arvore.de(t.id), arvore: arvore, cor: cor),
          ],
        ],
      ),
    );
  }
}

class _TopicoMini extends StatelessWidget {
  const _TopicoMini(this.t, this.nFilhos, this.cor);
  final Topico t;
  final int nFilhos;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.visto ? cor : Colors.transparent,
              border: Border.all(
                color: t.visto ? cor : cor.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: t.visto ? Cores.tintaSuave : Cores.tinta,
              ),
            ),
          ),
          if (nFilhos > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 14),
              child: Text(
                '$nFilhos',
                style: const TextStyle(fontSize: 13, color: Cores.tintaSuave),
              ),
            ),
        ],
      ),
    );
  }
}
