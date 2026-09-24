import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/provas_db.dart';
import '../logic/provas.dart';
import '../theme.dart';
import '../util/texto.dart' show chaveMateria;
import '../widgets/comuns.dart';
import '../widgets/provas_comuns.dart';

/// Colar uma prova no formato "edital-prova-v1": valida, mostra a prévia
/// (com edição de cada questão) e importa sem duplicar.
class ColarProvaScreen extends StatefulWidget {
  const ColarProvaScreen({super.key, this.textoInicial = ''});

  /// Usado nos testes.
  final String textoInicial;

  @override
  State<ColarProvaScreen> createState() => _ColarProvaScreenState();
}

class _ColarProvaScreenState extends State<ColarProvaScreen> {
  late final _texto = TextEditingController(text: widget.textoInicial);
  LeituraProva? _leitura;
  Map<int, List<CandidatoTopico>> _sugestoes = {};

  /// Nome de cada tópico (id → nome), para a prévia.
  Map<String, String> _nomesTopicos = {};

  /// Chaves das matérias que já existem.
  Set<String> _materiasExistentes = {};
  Prova? _existente;
  bool _lendo = false;
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
    // Colar de novo com texto no campo = continuação da mesma prova.
    _texto.text = _texto.text.trim().isEmpty ? t : '${_texto.text}\n$t';
    setState(() => _leitura = null);
  }

  Future<void> _ler() async {
    FocusScope.of(context).unfocus();
    final db = context.read<AppDatabase>();
    setState(() => _lendo = true);
    final l = lerProva(_texto.text);
    var sug = <int, List<CandidatoTopico>>{};
    Prova? existente;
    if (l.prova != null) {
      sug = await db.ligarTopicos(l.prova!);
      existente = await db.provaPorChave(l.prova!.chave);
    }
    final topicos = await db.select(db.topicos).get();
    final mats = await db.todasMaterias();
    if (!mounted) return;
    setState(() {
      _leitura = l;
      _sugestoes = sug;
      _existente = existente;
      _nomesTopicos = {for (final t in topicos) t.id: t.nome};
      _materiasExistentes = {for (final m in mats) m.chave};
      _lendo = false;
    });
  }

  Future<void> _importar() async {
    final l = _leitura;
    if (l == null || !l.podeImportar) return;
    final db = context.read<AppDatabase>();
    setState(() => _importando = true);
    l.aplicarEscolhas();
    final r = await db.importarProva(l.prova!);
    if (!mounted) return;
    setState(() => _importando = false);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          r.provaNova ? 'Prova importada' : 'Prova atualizada',
          style: Theme.of(ctx).textTheme.headlineSmall,
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  [
                    '${r.novas} ${r.novas == 1 ? 'questão nova' : 'questões novas'}.',
                    if (r.repetidas > 0)
                      '${r.repetidas} já existiam e não foram duplicadas.',
                  ].join(' '),
                  style: const TextStyle(fontSize: 16),
                ),
                if (r.viraDefinitivo) ...[
                  const SizedBox(height: 14),
                  Text(
                    r.mudancas.isEmpty
                        ? 'Gabarito atualizado para definitivo. Nenhuma resposta mudou.'
                        : 'Gabarito atualizado para definitivo. O que mudou:',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  for (final m in r.mudancas)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('• $m'),
                    ),
                ],
                if (r.materiasCriadas.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Matérias criadas (não entram em nenhum concurso; '
                    'adicione no edital se quiser): '
                    '${r.materiasCriadas.join(', ')}.',
                    style: const TextStyle(color: Cores.tintaSuave),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _editar(QuestaoImportada q) async {
    final l = _leitura!;
    final db = context.read<AppDatabase>();
    final div = l.divergencias.where((d) => d.numero == q.numero).firstOrNull;
    final mudou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditarQuestao(
        questao: q,
        letras: l.prova!.letras,
        sugestoes: _sugestoes[q.numero] ?? const [],
      ),
    );
    if (mudou == true) {
      if (div != null) div.escolhida = q.resposta;
      final topicos = await db.select(db.topicos).get();
      if (!mounted) return;
      setState(() => _nomesTopicos = {for (final t in topicos) t.id: t.nome});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = _leitura;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(l == null ? 'Colar prova' : 'Prévia da prova'),
        leading: l == null
            ? null
            : IconButton(
                tooltip: 'Voltar ao texto',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _leitura = null),
              ),
      ),
      body: l == null ? _editor() : _previa(l),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                children: [
                  Expanded(child: _resumoRodape(l)),
                  const SizedBox(width: 12),
                  if (l == null)
                    FilledButton.icon(
                      key: const ValueKey('ler-prova'),
                      onPressed: _lendo || _texto.text.trim().isEmpty
                          ? null
                          : _ler,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Conferir'),
                    )
                  else
                    FilledButton.icon(
                      key: const ValueKey('importar-prova'),
                      onPressed: l.podeImportar && !_importando
                          ? _importar
                          : null,
                      icon: const Icon(Icons.download_done_rounded),
                      label: const Text('Importar'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumoRodape(LeituraProva? l) {
    final String t;
    if (l == null) {
      t = 'Cole o JSON gerado a partir da prova.';
    } else if (l.erros.isNotEmpty) {
      t = 'Corrija ${l.erros.length} ${l.erros.length == 1 ? 'problema' : 'problemas'} no JSON.';
    } else if (l.pendentes) {
      final n = l.divergencias.where((d) => d.escolhida == null).length;
      t = 'Escolha a resposta que vale em $n ${n == 1 ? 'questão' : 'questões'}.';
    } else {
      t = '${l.prova!.questoes.length} questões prontas para importar.';
    }
    return Text(
      t,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: l != null && !l.podeImportar ? Cores.acento : Cores.tinta,
      ),
    );
  }

  Widget _editor() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Cole o JSON "edital-prova-v1". Se a prova veio em partes, '
            'cole uma depois da outra: o app junta os blocos da mesma prova.',
            style: TextStyle(fontSize: 15, color: Cores.tintaSuave),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Pilula(
                icone: Icons.content_paste_rounded,
                rotulo: 'Colar',
                aoTocar: _colar,
              ),
              const SizedBox(width: 8),
              Pilula(
                icone: Icons.clear_rounded,
                rotulo: 'Limpar',
                aoTocar: () => setState(() => _texto.clear()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              key: const ValueKey('texto-prova'),
              controller: _texto,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: '{ "formato": "edital-prova-v1", "prova": { ... } }',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previa(LeituraProva l) {
    final p = l.prova;
    final divPorNumero = {for (final d in l.divergencias) d.numero: d};
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        if (l.erros.isNotEmpty) ...[
          Cartao(
            titulo: 'Não dá para importar ainda',
            corBorda: Cores.acento,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in l.erros)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• ${e.mensagem}',
                      style: const TextStyle(fontSize: 15, color: Cores.acento),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (l.avisos.isNotEmpty) ...[
          Cartao(
            titulo: 'Avisos',
            corBorda: corAviso,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final a in l.avisos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• ${a.mensagem}'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (p != null) ...[
          _Cabecalho(prova: p, existente: _existente),
          const SizedBox(height: 16),
          if (l.divergencias.isNotEmpty) ...[
            Cartao(
              titulo: 'Resposta diferente do gabarito lido',
              corBorda: Cores.acento,
              child: Column(
                children: [
                  for (final d in l.divergencias)
                    _Divergencia(d: d, aoMudar: () => setState(() {})),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          LayoutBuilder(
            builder: (context, box) {
              final materias = _PorMateria(
                prova: p,
                existentes: _materiasExistentes,
              );
              final status = _PorStatus(prova: p);
              if (box.maxWidth < 800) {
                return Column(
                  children: [materias, const SizedBox(height: 16), status],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: materias),
                    const SizedBox(width: 16),
                    Expanded(child: status),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (p.descartadas.isNotEmpty) ...[
            Cartao(
              titulo: 'Descartadas (${p.descartadas.length})',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final d in p.descartadas)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Questão ${doisDigitos(d.numero)}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: d.motivo),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(
              'Questões — toque para editar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final q in p.questoes)
            _LinhaQuestao(
              questao: q,
              divergencia: divPorNumero[q.numero],
              nomeTopico: q.topicoId == null ? null : _nomesTopicos[q.topicoId],
              temSugestao: (_sugestoes[q.numero] ?? const []).isNotEmpty,
              aoTocar: () => _editar(q),
            ),
        ],
      ],
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.prova, required this.existente});
  final ProvaImportada prova;
  final Prova? existente;

  @override
  Widget build(BuildContext context) {
    final p = prova;
    final e = existente;
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Selo(
                p.definitivo ? 'Gabarito definitivo' : 'Gabarito preliminar',
                cor: p.definitivo ? corCerto : corAviso,
              ),
              Selo('${p.ano}', cor: Cores.tinta),
              Selo('${p.numAlternativas} alternativas'),
            ],
          ),
          const SizedBox(height: 12),
          Text(p.orgao, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${p.cargo} · ${p.banca}',
            style: const TextStyle(fontSize: 16, color: Cores.tintaSuave),
          ),
          const SizedBox(height: 12),
          Text(
            '${p.questoes.length} questões · ${p.descartadas.length} '
            'descartadas · total da prova: ${p.totalQuestoes}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (e != null) ...[
            const SizedBox(height: 12),
            Text(
              e.gabarito != 'definitivo' && p.definitivo
                  ? 'Esta prova já está salva com gabarito preliminar. '
                        'Ao importar, respostas e status serão atualizados.'
                  : 'Esta prova já está salva. Questões repetidas não serão '
                        'duplicadas; só as novas entram.',
              style: const TextStyle(
                color: corAviso,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Divergencia extends StatelessWidget {
  const _Divergencia({required this.d, required this.aoMudar});
  final Divergencia d;
  final VoidCallback aoMudar;

  @override
  Widget build(BuildContext context) {
    Widget opcao(String letra, String rotulo) => ChoiceChip(
      label: Text(rotulo),
      selected: d.escolhida == letra,
      labelStyle: TextStyle(
        color: d.escolhida == letra ? Colors.white : Cores.tinta,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) {
        d.escolhida = letra;
        aoMudar();
      },
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Questão ${doisDigitos(d.numero)}: ${d.mensagem}',
              style: const TextStyle(
                color: Cores.acento,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 8,
            children: [
              opcao(d.resposta, 'Vale ${d.resposta}'),
              opcao(d.gabarito, 'Vale ${d.gabarito}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PorMateria extends StatelessWidget {
  const _PorMateria({required this.prova, required this.existentes});
  final ProvaImportada prova;
  final Set<String> existentes;

  @override
  Widget build(BuildContext context) {
    final c = contarPorMateria(prova.questoes);
    return Cartao(
      titulo: 'Por matéria',
      child: Column(
        children: [
          for (final e in c.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(e.key, style: const TextStyle(fontSize: 15)),
                  ),
                  if (!existentes.contains(
                    chaveMateria(nomeOficialMateria(e.key)),
                  ))
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Selo('nova'),
                    ),
                  Text(
                    '${e.value}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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

class _PorStatus extends StatelessWidget {
  const _PorStatus({required this.prova});
  final ProvaImportada prova;

  @override
  Widget build(BuildContext context) {
    final c = contarPorStatus(prova.questoes);
    return Cartao(
      titulo: 'Por status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in c.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Selo(
                    rotuloStatus(e.key),
                    cor: corStatus(e.key),
                    icone: iconeStatus(e.key),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.value.isEmpty
                          ? 'nenhuma'
                          : '${e.value.length}: ${e.value.map(doisDigitos).join(', ')}',
                      style: const TextStyle(fontSize: 15),
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

class _LinhaQuestao extends StatelessWidget {
  const _LinhaQuestao({
    required this.questao,
    required this.divergencia,
    required this.nomeTopico,
    required this.temSugestao,
    required this.aoTocar,
  });
  final QuestaoImportada questao;
  final Divergencia? divergencia;
  final String? nomeTopico;
  final bool temSugestao;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final q = questao;
    final d = divergencia;
    final String topico;
    final Color corTopico;
    if (q.topicoId != null) {
      topico = '→ ${nomeTopico ?? 'tópico escolhido'}';
      corTopico = Cores.tintaSuave;
    } else if (q.criarTopico) {
      topico = '→ tópico novo: ${q.topico}';
      corTopico = Cores.tintaSuave;
    } else {
      topico = temSugestao
          ? 'Sem tópico · toque para ver sugestões'
          : 'Sem tópico';
      corTopico = corAviso;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Cores.fundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: d != null && d.escolhida == null
                ? Cores.acento
                : Cores.linha,
            width: 1.5,
          ),
        ),
        child: InkWell(
          key: ValueKey('questao-previa-${q.numero}'),
          borderRadius: BorderRadius.circular(20),
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      doisDigitos(q.numero),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q.materia,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'Resp. ${q.resposta}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(q.topicoOriginal, style: const TextStyle(fontSize: 14)),
                Text(topico, style: TextStyle(fontSize: 14, color: corTopico)),
                if (q.status.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in StatusQuestao.todos)
                        if (q.status.contains(s))
                          Selo(
                            rotuloStatus(s),
                            cor: corStatus(s),
                            icone: iconeStatus(s),
                          ),
                    ],
                  ),
                ],
                if (d != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    d.escolhida == null
                        ? d.mensagem
                        : '${d.mensagem} · vale ${d.escolhida}',
                    style: const TextStyle(
                      color: Cores.acento,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (q.obs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    q.obs,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Cores.tintaSuave,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Edição de uma questão na prévia: matéria, tópico, status e resposta.
class _EditarQuestao extends StatefulWidget {
  const _EditarQuestao({
    required this.questao,
    required this.letras,
    required this.sugestoes,
  });
  final QuestaoImportada questao;
  final List<String> letras;
  final List<CandidatoTopico> sugestoes;

  @override
  State<_EditarQuestao> createState() => _EditarQuestaoState();
}

/// Escolha de tópico: id existente, "novo" ou "nenhum".
const _novo = '*novo*';
const _nenhum = '*nenhum*';

class _EditarQuestaoState extends State<_EditarQuestao> {
  late String _materia = nomeOficialMateria(widget.questao.materia);
  late String _escolha =
      widget.questao.topicoId ?? (widget.questao.criarTopico ? _novo : _nenhum);
  late final Set<String> _status = {...widget.questao.status};
  late String _resposta = widget.questao.resposta;
  late final _nomeNovo = TextEditingController(text: widget.questao.topico);

  /// Tópicos da matéria escolhida (id, nome), e os parecidos.
  List<({String id, String nome})> _topicos = [];
  List<CandidatoTopico> _parecidos = [];
  List<String> _nomesMaterias = [...materiasDeProva];

  @override
  void initState() {
    super.initState();
    _parecidos = widget.sugestoes;
    _carregar(primeira: true);
  }

  @override
  void dispose() {
    _nomeNovo.dispose();
    super.dispose();
  }

  Future<void> _carregar({bool primeira = false}) async {
    final db = context.read<AppDatabase>();
    final mats = await db.todasMaterias();
    final m = await db.materiaPorNome(_materia);
    final ts = m == null
        ? <Topico>[]
        : await (db.select(db.topicos)
                ..where((t) => t.materiaId.equals(m.id))
                ..orderBy([(t) => OrderingTerm.asc(t.ordem)]))
              .get();
    if (!mounted) return;
    setState(() {
      _nomesMaterias = {
        ...materiasDeProva,
        for (final x in mats) x.nome,
        _materia,
      }.toList();
      _topicos = [for (final t in ts) (id: t.id, nome: t.nome)];
      _parecidos = candidatosTopico(widget.questao.topico, _topicos);
      if (!primeira) _escolha = melhorTopico(_parecidos)?.id ?? _nenhum;
      if (_escolha != _novo &&
          _escolha != _nenhum &&
          !_topicos.any((t) => t.id == _escolha)) {
        _escolha = _nenhum;
      }
    });
  }

  void _salvar() {
    final q = widget.questao;
    q.materia = _materia;
    q.status = {..._status};
    q.resposta = _resposta;
    q.topicoDecidido = true;
    q.criarTopico = _escolha == _novo;
    q.topicoId = _escolha == _novo || _escolha == _nenhum ? null : _escolha;
    if (_escolha == _novo && _nomeNovo.text.trim().isNotEmpty) {
      q.topico = _nomeNovo.text.trim();
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questao;
    final letras = [
      ...widget.letras,
      if (_status.contains(StatusQuestao.anulada)) 'X',
    ];
    if (!letras.contains(_resposta)) _resposta = letras.first;
    final outros = [
      for (final t in _topicos)
        if (!_parecidos.take(4).any((p) => p.id == t.id)) t,
    ];
    Widget opcaoTopico(String valor, String rotulo, {String? detalhe}) =>
        RadioListTile<String>(
          value: valor,
          contentPadding: EdgeInsets.zero,
          title: Text(rotulo),
          subtitle: detalhe == null ? null : Text(detalhe),
        );
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Questão ${doisDigitos(q.numero)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  q.enunciado,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Cores.tintaSuave),
                ),
                const SizedBox(height: 20),
                const _Rotulo('Matéria'),
                DropdownButtonFormField<String>(
                  initialValue: _materia,
                  isExpanded: true,
                  items: [
                    for (final m in _nomesMaterias)
                      DropdownMenuItem(value: m, child: Text(m)),
                  ],
                  onChanged: (v) {
                    if (v == null || v == _materia) return;
                    setState(() => _materia = v);
                    _carregar();
                  },
                ),
                const SizedBox(height: 20),
                const _Rotulo('Tópico'),
                Text(
                  'No JSON: ${q.topicoOriginal}',
                  style: const TextStyle(color: Cores.tintaSuave),
                ),
                RadioGroup<String>(
                  groupValue: _escolha,
                  onChanged: (v) => setState(() => _escolha = v ?? _nenhum),
                  child: Column(
                    children: [
                      for (final c in _parecidos.take(4))
                        opcaoTopico(
                          c.id,
                          c.nome,
                          detalhe: 'parecido (${(c.nota * 100).round()}%)',
                        ),
                      if (outros.isNotEmpty &&
                          _escolha != _novo &&
                          _escolha != _nenhum &&
                          outros.any((t) => t.id == _escolha))
                        opcaoTopico(
                          _escolha,
                          outros.firstWhere((t) => t.id == _escolha).nome,
                        ),
                      opcaoTopico(_novo, 'Criar tópico novo'),
                      if (_escolha == _novo)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(controller: _nomeNovo),
                        ),
                      opcaoTopico(_nenhum, 'Deixar sem tópico'),
                    ],
                  ),
                ),
                if (outros.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PopupMenuButton<String>(
                      onSelected: (id) => setState(() => _escolha = id),
                      itemBuilder: (_) => [
                        for (final t in outros)
                          PopupMenuItem(value: t.id, child: Text(t.nome)),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Outro tópico da matéria…',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const _Rotulo('Status'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in StatusQuestao.todos)
                      FilterChip(
                        label: Text(rotuloStatus(s)),
                        selected: _status.contains(s),
                        labelStyle: TextStyle(
                          color: _status.contains(s)
                              ? Colors.white
                              : Cores.tinta,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (v) => setState(() {
                          v ? _status.add(s) : _status.remove(s);
                          if (s == StatusQuestao.anulada && v) _resposta = 'X';
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const _Rotulo('Resposta'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final l in letras)
                      ChoiceChip(
                        label: Text(l),
                        selected: _resposta == l,
                        labelStyle: TextStyle(
                          color: _resposta == l ? Colors.white : Cores.tinta,
                          fontWeight: FontWeight.w800,
                        ),
                        onSelected: (_) => setState(() => _resposta = l),
                      ),
                  ],
                ),
                if (q.obs.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  CaixaObs(q.obs),
                ],
                const SizedBox(height: 24),
                FilledButton(onPressed: _salvar, child: const Text('Salvar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      texto.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Cores.tintaSuave,
      ),
    ),
  );
}
