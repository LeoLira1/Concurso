import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/provas_db.dart';
import '../logic/provas.dart';
import '../state/arquivos.dart';
import '../theme.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import '../widgets/provas_comuns.dart';
import 'colar_prova_screen.dart';
import 'estatisticas_provas_screen.dart';
import 'resolver_screen.dart';

/// Central das provas: colar, resolver, estatísticas e a lista das provas
/// salvas (ver detalhes ou excluir).
class ProvasScreen extends StatelessWidget {
  const ProvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    void abrir(Widget tela) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
    return Scaffold(
      appBar: AppBar(toolbarHeight: 72, title: const Text('Provas')),
      body: Assistir<List<ProvaResumo>>(
        chave: 'provas',
        stream: db.watchProvas,
        builder: (context, provas) {
          final l = provas ?? const <ProvaResumo>[];
          final total = l.fold<int>(0, (a, p) => a + p.questoes);
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  LayoutBuilder(
                    builder: (context, box) {
                      final acoes = [
                        _Acao(
                          chave: 'acao-colar',
                          icone: Icons.content_paste_go_rounded,
                          titulo: 'Colar prova',
                          texto: 'JSON "edital-prova-v1"',
                          aoTocar: () => abrir(const ColarProvaScreen()),
                        ),
                        _Acao(
                          chave: 'acao-resolver',
                          icone: Icons.quiz_outlined,
                          titulo: 'Resolver',
                          texto: '$total questões salvas',
                          destaque: true,
                          aoTocar: total == 0
                              ? null
                              : () => abrir(const ResolverScreen()),
                        ),
                        _Acao(
                          chave: 'acao-estatisticas',
                          icone: Icons.insights_rounded,
                          titulo: 'Estatísticas das provas',
                          texto: 'acertos, tempo e erros',
                          aoTocar: () =>
                              abrir(const EstatisticasProvasScreen()),
                        ),
                      ];
                      if (box.maxWidth < 700) {
                        return Column(
                          children: [
                            for (final a in acoes)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: a,
                              ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          for (final (i, a) in acoes.indexed) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(child: a),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Minhas provas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  if (l.isEmpty)
                    const Text(
                      'Nenhuma prova ainda. Toque em "Colar prova" para '
                      'começar.',
                      style: TextStyle(fontSize: 16, color: Cores.tintaSuave),
                    ),
                  for (final p in l)
                    _LinhaProva(
                      p: p,
                      aoTocar: () =>
                          abrir(ProvaDetalheScreen(provaId: p.prova.id)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Acao extends StatelessWidget {
  const _Acao({
    required this.chave,
    required this.icone,
    required this.titulo,
    required this.texto,
    required this.aoTocar,
    this.destaque = false,
  });
  final String chave;
  final IconData icone;
  final String titulo;
  final String texto;
  final VoidCallback? aoTocar;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final escuro = destaque && aoTocar != null;
    return Material(
      color: escuro ? Cores.tinta : Cores.fundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: escuro ? Cores.tinta : Cores.linha, width: 1.5),
      ),
      child: InkWell(
        key: ValueKey(chave),
        borderRadius: BorderRadius.circular(24),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icone, size: 30, color: escuro ? Colors.white : Cores.tinta),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: escuro ? Colors.white : Cores.tinta,
                      ),
                    ),
                    Text(
                      texto,
                      style: TextStyle(
                        color: escuro ? Colors.white70 : Cores.tintaSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinhaProva extends StatelessWidget {
  const _LinhaProva({required this.p, required this.aoTocar});
  final ProvaResumo p;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final pr = p.prova;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Cores.fundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Cores.linha, width: 1.5),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 6,
          ),
          onTap: aoTocar,
          title: Text(
            '${pr.orgao} · ${pr.ano}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${pr.cargo} · ${pr.banca}\n${p.questoes} questões · '
            '${p.respostas} respostas · gabarito ${pr.gabarito}',
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}

/// Detalhes de uma prova, com a opção de excluir.
class ProvaDetalheScreen extends StatelessWidget {
  const ProvaDetalheScreen({super.key, required this.provaId});
  final String provaId;

  Future<void> _excluir(BuildContext context, ProvaResumo p) async {
    final db = context.read<AppDatabase>();
    final ok = await confirmar(
      context,
      titulo: 'Excluir a prova?',
      mensagem:
          'Saem ${p.questoes} questões e ${p.respostas} respostas. As '
          'respostas também saem das estatísticas. Não dá para desfazer.',
    );
    if (!ok) return;
    await db.excluirProva(provaId);
    ArquivosAnexos.limparOrfaos(db);
    if (context.mounted) {
      Navigator.pop(context);
      avisar(context, 'Prova excluída');
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<List<ProvaResumo>>(
      chave: 'provas',
      stream: db.watchProvas,
      builder: (context, provas) {
        final p = provas?.where((x) => x.prova.id == provaId).firstOrNull;
        if (p == null) return Scaffold(appBar: AppBar(toolbarHeight: 72));
        final pr = p.prova;
        final descartadas = [
          for (final d in jsonDecode(pr.descartadas) as List)
            Descartada((d['numero'] as num).toInt(), '${d['motivo']}'),
        ];
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 72,
            title: Text('${pr.orgao} · ${pr.ano}'),
            actions: [
              IconButton(
                key: const ValueKey('excluir-prova'),
                tooltip: 'Excluir prova',
                onPressed: () => _excluir(context, p),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: FutureBuilder<List<QuestaoCompleta>>(
            future: db.questoesCompletas(),
            builder: (context, snap) {
              final qs = [
                for (final q in snap.data ?? const <QuestaoCompleta>[])
                  if (q.prova.id == provaId) q,
              ];
              final porMateria = <String, int>{};
              for (final q in qs) {
                porMateria[q.materia.nome] =
                    (porMateria[q.materia.nome] ?? 0) + 1;
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  Cartao(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: [
                            Selo(
                              'Gabarito ${pr.gabarito}',
                              cor: pr.gabarito == 'definitivo'
                                  ? corCerto
                                  : corAviso,
                            ),
                            Selo('${pr.numAlternativas} alternativas'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${pr.cargo} · ${pr.banca}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${p.questoes} questões · ${descartadas.length} '
                          'descartadas · total ${pr.totalQuestoes} · '
                          '${p.respostas} respostas',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Cartao(
                    titulo: 'Por matéria',
                    child: Column(
                      children: [
                        for (final e in porMateria.entries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Expanded(child: Text(e.key)),
                                Text(
                                  '${e.value}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (descartadas.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Cartao(
                      titulo: 'Descartadas',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final d in descartadas)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'Questão ${doisDigitos(d.numero)}: ${d.motivo}',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Cartao(
                    titulo: 'Questões',
                    child: Column(
                      children: [
                        for (final q in qs)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Text(
                              doisDigitos(q.questao.numero),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            title: Text(q.materia.nome),
                            subtitle: Text(
                              [
                                q.topico?.nome ??
                                    'sem tópico (${q.questao.topicoOriginal})',
                                for (final s in StatusQuestao.todos)
                                  if (q.status.contains(s)) rotuloStatus(s),
                              ].join(' · '),
                            ),
                            trailing: Text(
                              q.questao.resposta,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
