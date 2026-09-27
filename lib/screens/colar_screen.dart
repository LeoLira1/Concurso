import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/colagem_db.dart';
import '../data/database.dart';
import '../logic/colagem.dart';
import '../theme.dart';
import '../widgets/comuns.dart';
import '../widgets/provas_comuns.dart';

/// O que muda entre "Colar questões" e "Colar flashcards".
class TipoColagem<T extends ItemColado> {
  const TipoColagem({
    required this.chave,
    required this.titulo,
    required this.singular,
    required this.plural,
    required this.feminino,
    required this.rotulo,
    required this.exemplo,
    required this.instrucao,
    required this.campos,
    required this.ler,
    required this.marcar,
    required this.importar,
    required this.texto,
    required this.detalhes,
  });

  /// Sufixo das chaves dos widgets ("questoes", "flashcards").
  final String chave;
  final String titulo;
  final String singular;
  final String plural;

  /// "questão" é feminino ("2 novas"), "cartão" é masculino ("2 novos").
  final bool feminino;

  /// Nas mensagens de erro: "Questão 3: ...", "Cartão 3: ...".
  final String rotulo;
  final String exemplo;
  final String instrucao;
  final String campos;
  final LeituraColagem<T> Function(
    String texto, {
    String? materiaPadrao,
    String? topicoPadrao,
    String? subtopicoPadrao,
  })
  ler;
  final Future<void> Function(AppDatabase db, LeituraColagem<T> l) marcar;
  final Future<ResultadoColagem> Function(
    AppDatabase db,
    LeituraColagem<T> l,
    String? concursoId,
  )
  importar;

  /// Texto principal do item na prévia (enunciado, frente).
  final String Function(T item) texto;

  /// Detalhes embaixo do texto na prévia.
  final List<String> Function(T item) detalhes;

  String get artigo => feminino ? 'a' : 'o';

  /// "1 questão", "3 cartões".
  String contar(int n) => '$n ${n == 1 ? singular : plural}';

  /// Adjetivo no gênero e número do item: "novo" → "novas".
  String concordar(int n, String masculino) {
    final base = feminino
        ? '${masculino.substring(0, masculino.length - 1)}a'
        : masculino;
    return n == 1 ? base : '${base}s';
  }
}

/// Destino padrão de quem cola a partir de um tópico: o tópico (ou, num
/// subtópico, o tópico de cima + o subtópico).
Future<({String? topico, String? subtopico})> destinoPadrao(
  AppDatabase db,
  Topico? topico,
) async {
  if (topico == null) return (topico: null, subtopico: null);
  final pai = topico.paiId == null ? null : await db.topico(topico.paiId!);
  return (
    topico: pai?.nome ?? topico.nome,
    subtopico: pai == null ? null : topico.nome,
  );
}

/// Tela genérica de colar uma lista em JSON (questões, flashcards): lê,
/// mostra a prévia (onde cada item vai parar, o que é novo, o que já
/// existe e o que tem erro) e importa. Na tela do tópico, o que faltar no
/// JSON (matéria, tópico) vem do tópico.
class ColarScreen<T extends ItemColado> extends StatefulWidget {
  const ColarScreen({
    super.key,
    required this.tipo,
    this.materiaPadrao,
    this.topicoPadrao,
    this.subtopicoPadrao,
    this.concursoId,
    this.textoInicial,
  });

  final TipoColagem<T> tipo;
  final String? materiaPadrao;
  final String? topicoPadrao;
  final String? subtopicoPadrao;

  /// Edital que recebe os tópicos novos (nulo = "Tudo junto").
  final String? concursoId;
  final String? textoInicial;

  @override
  State<ColarScreen<T>> createState() => _ColarScreenState<T>();
}

class _ColarScreenState<T extends ItemColado> extends State<ColarScreen<T>> {
  late final _texto = TextEditingController(text: widget.textoInicial);
  TipoColagem<T> get _tipo => widget.tipo;
  LeituraColagem<T>? _leitura;
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
    final l = _tipo.ler(
      _texto.text,
      materiaPadrao: widget.materiaPadrao,
      topicoPadrao: widget.topicoPadrao,
      subtopicoPadrao: widget.subtopicoPadrao,
    );
    await _tipo.marcar(db, l);
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
    final r = await _tipo.importar(
      context.read<AppDatabase>(),
      l,
      widget.concursoId,
    );
    if (!mounted) return;
    setState(() => _importando = false);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${_tipo.contar(r.novas)} '
          '${_tipo.concordar(r.novas, 'importado')}',
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
        title: Text(_tipo.titulo),
        actions: [
          if (l != null && l.novas > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                key: ValueKey('importar-${_tipo.chave}'),
                onPressed: _importando ? null : _importar,
                icon: const Icon(Icons.download_done_rounded),
                label: Text('Importar ${_tipo.contar(l.novas)}'),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          final deitado = box.maxWidth >= 900 && box.maxWidth > box.maxHeight;
          final entrada = _Entrada(
            tipo: _tipo,
            controller: _texto,
            aoColar: _colar,
            aoConferir: _conferir,
            dica: widget.topicoPadrao == null
                ? null
                : 'Sem "materia"/"topico" no JSON, ${_tipo.artigo} '
                      '${_tipo.singular} vai para '
                      '${[widget.topicoPadrao, widget.subtopicoPadrao].whereType<String>().join(' › ')}.',
            expandir: deitado,
          );
          final previa = l == null
              ? _SemPrevia(tipo: _tipo)
              : _Previa<T>(tipo: _tipo, leitura: l, destinos: _destinos);
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
    required this.tipo,
    required this.controller,
    required this.aoColar,
    required this.aoConferir,
    required this.dica,
    required this.expandir,
  });
  final TipoColagem tipo;
  final TextEditingController controller;
  final VoidCallback aoColar;
  final VoidCallback aoConferir;
  final String? dica;
  final bool expandir;

  @override
  Widget build(BuildContext context) {
    final campo = TextField(
      key: ValueKey('texto-${tipo.chave}'),
      controller: controller,
      maxLines: expandir ? null : 8,
      minLines: expandir ? null : 8,
      expands: expandir,
      textAlignVertical: TextAlignVertical.top,
      style: const TextStyle(fontSize: 14, height: 1.4),
      decoration: InputDecoration(
        hintText: tipo.exemplo,
        hintMaxLines: 8,
        alignLabelWithHint: true,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tipo.instrucao,
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
              key: ValueKey('conferir-${tipo.chave}'),
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
  const _SemPrevia({required this.tipo});
  final TipoColagem tipo;

  @override
  Widget build(BuildContext context) => Cartao(
    titulo: 'Prévia',
    child: Text(
      'Toque em "Colar" (ou cole no campo e toque em "Ver prévia").\n\n'
      'Campos: ${tipo.campos}.',
      style: const TextStyle(
        fontSize: 15,
        height: 1.45,
        color: Cores.tintaSuave,
      ),
    ),
  );
}

class _Previa<T extends ItemColado> extends StatelessWidget {
  const _Previa({
    required this.tipo,
    required this.leitura,
    required this.destinos,
  });
  final TipoColagem<T> tipo;
  final LeituraColagem<T> leitura;
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
    final grupos = <(String, String, String), List<T>>{};
    final comErro = <T>[];
    for (final q in l.itens) {
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
              '${l.novas} ${tipo.concordar(l.novas, 'novo')}',
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
          _Grupo<T>(
            tipo: tipo,
            materia: e.key.$1,
            topico: e.key.$2,
            subtopico: e.key.$3,
            destino: destinos[e.value.first.indice],
            itens: e.value,
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
                      '${tipo.rotulo} ${q.indice}: ${q.erros.join('; ')}.',
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

class _Grupo<T extends ItemColado> extends StatelessWidget {
  const _Grupo({
    required this.tipo,
    required this.materia,
    required this.topico,
    required this.subtopico,
    required this.destino,
    required this.itens,
  });
  final TipoColagem<T> tipo;
  final String materia;
  final String topico;
  final String subtopico;
  final DestinoColagem? destino;
  final List<T> itens;

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
          for (final q in itens) _Linha<T>(tipo: tipo, item: q),
        ],
      ),
    );
  }
}

class _Linha<T extends ItemColado> extends StatelessWidget {
  const _Linha({required this.tipo, required this.item});
  final TipoColagem<T> tipo;
  final T item;

  @override
  Widget build(BuildContext context) {
    final q = item;
    final t = tipo.texto(q).replaceAll(RegExp(r'\s+'), ' ');
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
                    ...tipo.detalhes(q),
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
