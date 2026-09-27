import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/questoes_topico_db.dart';
import '../logic/questoes_topico.dart';
import '../theme.dart';
import '../widgets/comuns.dart';
import '../widgets/provas_comuns.dart';

/// Exemplo mostrado na tela (e no README).
const exemploQuestoesJson =
    '''[{"materia":"Língua Portuguesa","topico":"Conjunções","subtopico":"Adversativas","dificuldade":2,"enunciado":"...","alternativas":{"A":"...","B":"...","C":"...","D":"...","E":"..."},"gabarito":"C","explicacao":"..."}]''';

/// "Colar questões": lê a lista em JSON, mostra a prévia (onde cada questão
/// vai parar, o que é novo, o que já existe e o que tem erro) e importa.
/// Na tela do tópico, o que faltar no JSON (matéria, tópico) vem do tópico.
class ColarQuestoesScreen extends StatefulWidget {
  const ColarQuestoesScreen({
    super.key,
    this.materiaPadrao,
    this.topicoPadrao,
    this.subtopicoPadrao,
    this.concursoId,
    this.textoInicial,
  });

  final String? materiaPadrao;
  final String? topicoPadrao;
  final String? subtopicoPadrao;

  /// Edital que recebe os tópicos novos (nulo = "Tudo junto").
  final String? concursoId;
  final String? textoInicial;

  @override
  State<ColarQuestoesScreen> createState() => _ColarQuestoesScreenState();
}

class _ColarQuestoesScreenState extends State<ColarQuestoesScreen> {
  late final _texto = TextEditingController(text: widget.textoInicial);
  LeituraQuestoes? _leitura;
  Map<int, DestinoColagem> _destinos = const {};
  bool _importando = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _colar() async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    final t = d?.text ?? '';
    if (t.trim().isEmpty) {
      if (mounted) avisar(context, 'A área de transferência está vazia');
      return;
    }
    _texto.text = t;
    await _conferir();
  }

  Future<void> _conferir() async {
    final db = context.read<AppDatabase>();
    final l = lerQuestoes(
      _texto.text,
      materiaPadrao: widget.materiaPadrao,
      topicoPadrao: widget.topicoPadrao,
      subtopicoPadrao: widget.subtopicoPadrao,
    );
    await db.marcarRepetidas(l);
    final destinos = await db.destinosColagem(l, concursoId: widget.concursoId);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _leitura = l;
      _destinos = destinos;
    });
  }

  Future<void> _importar() async {
    final l = _leitura;
    if (l == null || l.novas == 0 || _importando) return;
    setState(() => _importando = true);
    final r = await context.read<AppDatabase>().importarQuestoesTopico(
      l,
      concursoId: widget.concursoId,
    );
    if (!mounted) return;
    setState(() => _importando = false);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${r.novas} ${r.novas == 1 ? 'questão importada' : 'questões importadas'}',
          style: Theme.of(ctx).textTheme.headlineSmall,
        ),
        content: Text(
          [
            if (r.repetidas > 0)
              '${r.repetidas} já existiam e ficaram de fora.',
            if (r.materiasCriadas.isNotEmpty)
              'Matéria nova: ${r.materiasCriadas.join(', ')}.',
            if (r.topicosCriados.isNotEmpty)
              'Tópicos criados no edital: ${r.topicosCriados.join('; ')}.',
            if (r.repetidas == 0 &&
                r.materiasCriadas.isEmpty &&
                r.topicosCriados.isEmpty)
              'Tudo entrou em tópicos que já existiam.',
          ].join('\n\n'),
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, r);
  }

  @override
  Widget build(BuildContext context) {
    final l = _leitura;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Text('Colar questões'),
        actions: [
          if (l != null && l.novas > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                key: const ValueKey('importar-questoes'),
                onPressed: _importando ? null : _importar,
                icon: const Icon(Icons.download_done_rounded),
                label: Text(
                  'Importar ${l.novas} ${l.novas == 1 ? 'questão' : 'questões'}',
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          final deitado = box.maxWidth >= 900 && box.maxWidth > box.maxHeight;
          final entrada = _Entrada(
            controller: _texto,
            aoColar: _colar,
            aoConferir: _conferir,
            dica: widget.topicoPadrao == null
                ? null
                : 'Sem "materia"/"topico" no JSON, a questão vai para '
                      '${[widget.topicoPadrao, widget.subtopicoPadrao].whereType<String>().join(' › ')}.',
            expandir: deitado,
          );
          final previa = l == null
              ? const _SemPrevia()
              : _Previa(leitura: l, destinos: _destinos);
          if (deitado) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 14, 24),
                    child: entrada,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 8, 28, 24),
                    children: [previa],
                  ),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [entrada, const SizedBox(height: 20), previa],
          );
        },
      ),
    );
  }
}

class _Entrada extends StatelessWidget {
  const _Entrada({
    required this.controller,
    required this.aoColar,
    required this.aoConferir,
    required this.dica,
    required this.expandir,
  });
  final TextEditingController controller;
  final VoidCallback aoColar;
  final VoidCallback aoConferir;
  final String? dica;
  final bool expandir;

  @override
  Widget build(BuildContext context) {
    final campo = TextField(
      key: const ValueKey('texto-questoes'),
      controller: controller,
      maxLines: expandir ? null : 8,
      minLines: expandir ? null : 8,
      expands: expandir,
      textAlignVertical: TextAlignVertical.top,
      style: const TextStyle(fontSize: 14, height: 1.4),
      decoration: const InputDecoration(
        hintText: exemploQuestoesJson,
        hintMaxLines: 8,
        alignLabelWithHint: true,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cole a lista de questões em JSON. Antes de importar, você vê a '
          'prévia. Tópicos que não existem no edital são criados, e questões '
          'com o mesmo enunciado não são duplicadas.',
          style: const TextStyle(fontSize: 15, color: Cores.tintaSuave),
        ),
        if (dica != null) ...[
          const SizedBox(height: 6),
          Text(
            dica!,
            style: const TextStyle(fontSize: 14, color: Cores.tintaSuave),
          ),
        ],
        const SizedBox(height: 12),
        if (expandir) Expanded(child: campo) else campo,
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              key: const ValueKey('colar-area'),
              onPressed: aoColar,
              icon: const Icon(Icons.content_paste_rounded),
              label: const Text('Colar'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              key: const ValueKey('conferir-questoes'),
              onPressed: aoConferir,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Ver prévia'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SemPrevia extends StatelessWidget {
  const _SemPrevia();

  @override
  Widget build(BuildContext context) => Cartao(
    titulo: 'Prévia',
    child: const Text(
      'Toque em "Colar" (ou cole no campo e toque em "Ver prévia").\n\n'
      'Campos: materia, topico, subtopico (opcional), dificuldade (1 a 5), '
      'enunciado, alternativas (A a E), gabarito e explicacao.',
      style: TextStyle(fontSize: 15, height: 1.45, color: Cores.tintaSuave),
    ),
  );
}

class _Previa extends StatelessWidget {
  const _Previa({required this.leitura, required this.destinos});
  final LeituraQuestoes leitura;
  final Map<int, DestinoColagem> destinos;

  @override
  Widget build(BuildContext context) {
    final l = leitura;
    if (l.erro != null) {
      return Cartao(
        titulo: 'Não deu para ler',
        corBorda: Cores.acento,
        child: Text(
          l.erro!,
          key: const ValueKey('erro-leitura'),
          style: const TextStyle(fontSize: 16, color: Cores.acento),
        ),
      );
    }
    // Agrupa por matéria › tópico › subtópico, na ordem em que vieram.
    final grupos = <(String, String, String), List<QuestaoColada>>{};
    final comErro = <QuestaoColada>[];
    for (final q in l.questoes) {
      if (!q.valida) {
        comErro.add(q);
        continue;
      }
      (grupos[(q.materia, q.topico, q.subtopico)] ??= []).add(q);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Selo(
              '${l.novas} ${l.novas == 1 ? 'nova' : 'novas'}',
              cor: corCerto,
              icone: Icons.add_circle_outline_rounded,
            ),
            if (l.repetidas > 0)
              Selo(
                '${l.repetidas} já ${l.repetidas == 1 ? 'existe' : 'existem'} (fica de fora)',
                icone: Icons.content_copy_rounded,
              ),
            if (l.comErro > 0)
              Selo(
                '${l.comErro} com erro (fica de fora)',
                cor: Cores.acento,
                icone: Icons.error_outline_rounded,
              ),
          ],
        ),
        const SizedBox(height: 16),
        for (final e in grupos.entries) ...[
          _Grupo(
            materia: e.key.$1,
            topico: e.key.$2,
            subtopico: e.key.$3,
            destino: destinos[e.value.first.indice],
            questoes: e.value,
          ),
          const SizedBox(height: 12),
        ],
        if (comErro.isNotEmpty)
          Cartao(
            titulo: 'Com erro',
            corBorda: Cores.acento,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final q in comErro)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Questão ${q.indice}: ${q.erros.join('; ')}.',
                      style: const TextStyle(fontSize: 15, color: Cores.acento),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({
    required this.materia,
    required this.topico,
    required this.subtopico,
    required this.destino,
    required this.questoes,
  });
  final String materia;
  final String topico;
  final String subtopico;
  final DestinoColagem? destino;
  final List<QuestaoColada> questoes;

  @override
  Widget build(BuildContext context) {
    final d = destino;
    return Cartao(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            materia,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Cores.tintaSuave,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtopico.isEmpty ? topico : '$topico › $subtopico',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (d != null &&
              (d.materiaNova ||
                  d.topicoNovo ||
                  d.subtopicoNovo ||
                  d.entraNoEdital)) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (d.materiaNova) const Selo('Matéria nova', cor: corAviso),
                if (d.topicoNovo)
                  const Selo(
                    'Tópico novo no edital',
                    cor: corAviso,
                    icone: Icons.add_rounded,
                  ),
                if (d.subtopicoNovo)
                  const Selo(
                    'Subtópico novo',
                    cor: corAviso,
                    icone: Icons.add_rounded,
                  ),
                if (d.entraNoEdital)
                  const Selo(
                    'Entra no edital do concurso',
                    cor: corAviso,
                    icone: Icons.link_rounded,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          for (final q in questoes) _LinhaQuestao(q),
        ],
      ),
    );
  }
}

class _LinhaQuestao extends StatelessWidget {
  const _LinhaQuestao(this.q);
  final QuestaoColada q;

  @override
  Widget build(BuildContext context) {
    final t = q.enunciado.replaceAll(RegExp(r'\s+'), ' ');
    final cor = q.repetida ? Cores.tintaFraca : Cores.tinta;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '${q.indice}.',
              style: TextStyle(fontWeight: FontWeight.w800, color: cor),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.length > 160 ? '${t.substring(0, 157)}…' : t,
                  style: TextStyle(fontSize: 15, height: 1.35, color: cor),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (q.repetida) 'já existe',
                    '${q.alternativas.length} alternativas',
                    'gabarito ${q.gabarito}',
                    'dificuldade ${q.dificuldade}',
                    if (q.explicacao.isEmpty) 'sem explicação',
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 13,
                    color: q.repetida ? Cores.tintaFraca : Cores.tintaSuave,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Abre "Colar questões" a partir de um tópico (o que faltar no JSON vai
/// para ele) ou de uma matéria.
Future<void> abrirColarQuestoes(
  BuildContext context, {
  required Materia materia,
  Topico? topico,
  String? concursoId,
}) async {
  final db = context.read<AppDatabase>();
  String? topicoPadrao, subtopicoPadrao;
  if (topico != null) {
    final pai = topico.paiId == null ? null : await db.topico(topico.paiId!);
    topicoPadrao = pai?.nome ?? topico.nome;
    subtopicoPadrao = pai == null ? null : topico.nome;
  }
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ColarQuestoesScreen(
        materiaPadrao: materia.nome,
        topicoPadrao: topicoPadrao,
        subtopicoPadrao: subtopicoPadrao,
        concursoId: concursoId,
      ),
    ),
  );
}
