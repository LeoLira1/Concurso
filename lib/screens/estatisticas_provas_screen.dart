import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/provas_db.dart';
import '../logic/provas.dart';
import '../theme.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import '../widgets/escopo.dart';
import '../widgets/provas_comuns.dart';
import 'questoes_screen.dart';

/// % de acerto por matéria, tópico e banca; evolução semanal; tempo por
/// questão; erros por motivo e caderno de erros. Segue o escopo da tela
/// inicial (concurso em foco ou tudo junto).
class EstatisticasProvasScreen extends StatelessWidget {
  const EstatisticasProvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Text('Estatísticas das provas'),
      ),
      body: ComEscopo(
        builder: (context, escopo) => Assistir<List<RespostaInfo>>(
          chave: 'respostas',
          stream: db.watchRespostasInfo,
          builder: (context, respostas) => FutureBuilder<_Dados>(
            // Refaz quando as respostas ou o escopo mudam.
            key: ValueKey((
              escopo,
              respostas?.length,
              respostas?.lastOrNull?.resposta,
            )),
            future: _Dados.carregar(db, escopo),
            builder: (context, snap) {
              final d = snap.data;
              if (respostas == null || d == null) {
                return const SizedBox.shrink();
              }
              final e = EstatisticasProvas([
                for (final r in respostas)
                  if (d.noEscopo.contains(r.questaoId)) r,
              ], hoje: DateTime.now());
              return _Corpo(e: e, d: d);
            },
          ),
        ),
      ),
    );
  }
}

class _Dados {
  _Dados(this.noEscopo, this.materias, this.topicos);
  final Set<String> noEscopo;
  final Map<String, Materia> materias;
  final Map<String, Topico> topicos;

  static Future<_Dados> carregar(AppDatabase db, String? escopo) async {
    final qs = await db.questoesCompletas(
      filtro: FiltroQuestoes(concursoId: escopo),
    );
    return _Dados(
      {for (final q in qs) q.id},
      {for (final m in await db.todasMaterias()) m.id: m},
      {for (final t in await db.select(db.topicos).get()) t.id: t},
    );
  }
}

class _Corpo extends StatelessWidget {
  const _Corpo({required this.e, required this.d});
  final EstatisticasProvas e;
  final _Dados d;

  @override
  Widget build(BuildContext context) {
    if (e.geral.feitas == 0 && e.cadernoDeErros.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Resolva algumas questões para ver as estatísticas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Cores.tintaSuave),
          ),
        ),
      );
    }
    final seg = e.segundosPorQuestao;
    final erros = e.errosPorMotivo.values.fold<int>(0, (a, b) => a + b);
    final tiles = [
      _Numero('Questões', '${e.geral.feitas}'),
      _Numero(
        'Acerto',
        e.geral.acerto == null ? '—' : '${(e.geral.acerto! * 100).round()}%',
      ),
      _Numero(
        'Tempo médio',
        seg == null
            ? '—'
            : seg < 60
            ? '${seg.round()}s'
            : '${seg ~/ 60}min${(seg % 60).round().toString().padLeft(2, '0')}',
      ),
      _Numero('Erros', '$erros'),
    ];

    final materias = e.porMateria.entries.toList()
      ..sort((a, b) => b.value.acerto!.compareTo(a.value.acerto!));
    final topicos = e.porTopico.entries.toList()
      ..sort((a, b) => a.value.acerto!.compareTo(b.value.acerto!));
    final bancas = e.porBanca.entries.toList()
      ..sort((a, b) => b.value.feitas.compareTo(a.value.feitas));

    final cartoes = [
      Cartao(
        titulo: '% de acerto por matéria',
        child: Column(
          children: [
            for (final x in materias)
              _Barra(
                rotulo: d.materias[x.key]?.nome ?? '—',
                cor: d.materias[x.key] == null
                    ? Cores.tintaFraca
                    : Color(d.materias[x.key]!.cor),
                p: x.value,
              ),
          ],
        ),
      ),
      Cartao(
        titulo: '% de acerto por tópico',
        child: Column(
          children: [
            if (topicos.isEmpty)
              const Text(
                'As questões respondidas estão sem tópico.',
                style: TextStyle(color: Cores.tintaSuave),
              ),
            for (final x in topicos.take(15))
              _Barra(
                rotulo: d.topicos[x.key]?.nome ?? '—',
                cor: d.materias[d.topicos[x.key]?.materiaId] == null
                    ? Cores.tintaFraca
                    : Color(d.materias[d.topicos[x.key]!.materiaId]!.cor),
                p: x.value,
              ),
            if (topicos.length > 15)
              Text(
                'e mais ${topicos.length - 15} tópicos',
                style: const TextStyle(color: Cores.tintaSuave),
              ),
          ],
        ),
      ),
      Cartao(
        titulo: '% de acerto por banca',
        child: Column(
          children: [
            for (final x in bancas)
              _Barra(rotulo: x.key, cor: Cores.tinta, p: x.value),
          ],
        ),
      ),
      Cartao(
        titulo: 'Evolução semanal',
        child: _Evolucao(semanas: e.semanas),
      ),
      Cartao(
        titulo: 'Erros por motivo',
        child: Column(
          children: [
            for (final m in [...motivosErro.keys, ''])
              if ((e.errosPorMotivo[m] ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.isEmpty ? 'Não informado' : motivosErro[m]!,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      Text(
                        '${e.errosPorMotivo[m]}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
            if (erros == 0)
              const Text(
                'Nenhum erro ainda.',
                style: TextStyle(color: Cores.tintaSuave),
              ),
          ],
        ),
      ),
      _CadernoDeErros(ids: e.cadernoDeErros),
    ];

    return LayoutBuilder(
      builder: (context, box) {
        final largo = box.maxWidth >= 1000;
        return ListView(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in tiles)
                  SizedBox(
                    width: largo
                        ? (box.maxWidth - 48 - 36) / 4
                        : (box.maxWidth - 48 - 12) / 2,
                    child: t,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (largo)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (final c in [cartoes[0], cartoes[2], cartoes[4]])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: c,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        for (final c in [cartoes[3], cartoes[1], cartoes[5]])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: c,
                          ),
                      ],
                    ),
                  ),
                ],
              )
            else
              for (final c in cartoes)
                Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
          ],
        );
      },
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero(this.rotulo, this.valor);
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) => Cartao(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Cores.tintaSuave,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
      ],
    ),
  );
}

class _Barra extends StatelessWidget {
  const _Barra({required this.rotulo, required this.cor, required this.p});
  final String rotulo;
  final Color cor;
  final Placar p;

  @override
  Widget build(BuildContext context) {
    final a = p.acerto ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Bolinha(cor, tamanho: 10),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Text(
              rotulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: box.maxWidth * a,
                    decoration: BoxDecoration(
                      color: p.baixo ? corAviso : Cores.tinta,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: Text(
              '${(a * 100).round()}% · ${p.acertos}/${p.feitas}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: p.baixo ? corAviso : Cores.tinta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Evolucao extends StatelessWidget {
  const _Evolucao({required this.semanas});
  final Map<DateTime, Placar> semanas;

  @override
  Widget build(BuildContext context) {
    final l = semanas.entries.toList();
    if (l.every((e) => e.value.feitas == 0)) {
      return const Text(
        'Sem respostas nas últimas 12 semanas.',
        style: TextStyle(color: Cores.tintaSuave),
      );
    }
    return SizedBox(
      height: 170,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, e) in l.indexed)
            Expanded(
              child: Tooltip(
                message:
                    'Semana de ${e.key.day.toString().padLeft(2, '0')}/'
                    '${e.key.month.toString().padLeft(2, '0')}: '
                    '${e.value.feitas} questões'
                    '${e.value.acerto == null ? '' : ', ${(e.value.acerto! * 100).round()}%'}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (e.value.acerto != null)
                        Text(
                          '${(e.value.acerto! * 100).round()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        height: 110 * (e.value.acerto ?? 0) + 2,
                        decoration: BoxDecoration(
                          color: i == l.length - 1 ? Cores.acento : Cores.tinta,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${e.key.day.toString().padLeft(2, '0')}/'
                        '${e.key.month.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Cores.tintaSuave,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CadernoDeErros extends StatelessWidget {
  const _CadernoDeErros({required this.ids});
  final List<String> ids;

  Future<void> _refazer(BuildContext context, List<String> ids) async {
    final db = context.read<AppDatabase>();
    final qs = await db.questoesCompletas(
      filtro: const FiltroQuestoes(),
      ids: ids,
    );
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestoesScreen(
          questoes: qs..shuffle(),
          modo: ModoQuestoes.treino,
          titulo: 'Caderno de erros',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Cartao(
      titulo: 'Caderno de erros (${ids.length})',
      child: FutureBuilder<List<QuestaoCompleta>>(
        key: ValueKey(ids.join()),
        future: db.questoesCompletas(filtro: const FiltroQuestoes(), ids: ids),
        builder: (context, snap) {
          final qs = snap.data ?? const <QuestaoCompleta>[];
          if (ids.isEmpty) {
            return const Text(
              'Nenhuma questão errada na última tentativa.',
              style: TextStyle(color: Cores.tintaSuave),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final q in qs)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Bolinha(Color(q.materia.cor)),
                  title: Text(
                    '${q.prova.orgao} ${q.prova.ano} · questão ${doisDigitos(q.questao.numero)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    q.topico?.nome ?? q.questao.topicoOriginal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: TextButton(
                    onPressed: () => _refazer(context, [q.id]),
                    child: const Text('Refazer'),
                  ),
                ),
              const SizedBox(height: 8),
              if (qs.length > 1)
                OutlinedButton.icon(
                  onPressed: () => _refazer(context, ids),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Refazer todas'),
                ),
            ],
          );
        },
      ),
    );
  }
}
