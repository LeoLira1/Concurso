import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/provas_db.dart';
import '../logic/provas.dart';
import '../state/arquivos.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import '../widgets/provas_comuns.dart';

enum ModoQuestoes {
  treino('treino', 'Treino'),
  simulado('simulado', 'Simulado');

  const ModoQuestoes(this.chave, this.rotulo);
  final String chave;
  final String rotulo;
}

/// Uma questão respondida nesta sessão.
class _Feita {
  _Feita(this.q, this.marcada, this.segundos, this.respostaId);
  final QuestaoCompleta q;
  final String marcada;
  final int segundos;
  final String respostaId;
  String? motivo;

  bool get acertou => marcada == q.questao.resposta;

  /// Nulo = anulada (não conta como acerto nem erro).
  bool? get conta => q.anulada ? null : acertou;
}

/// Resolver questões: Treino (uma por vez, correção na hora) ou Simulado
/// (cronômetro, correção só no final).
class QuestoesScreen extends StatefulWidget {
  const QuestoesScreen({
    super.key,
    required this.questoes,
    required this.modo,
    this.minutos,
    this.titulo,
  });
  final List<QuestaoCompleta> questoes;
  final ModoQuestoes modo;

  /// Tempo do simulado (nulo = sem limite).
  final int? minutos;
  final String? titulo;

  @override
  State<QuestoesScreen> createState() => _QuestoesScreenState();
}

class _QuestoesScreenState extends State<QuestoesScreen> {
  late final AppDatabase _db = context.read<AppDatabase>();
  late final List<QuestaoCompleta> _qs = [...widget.questoes];
  int _i = 0;

  /// Treino: letra marcada na questão atual e a resposta registrada.
  String? _marcada;
  _Feita? _atual;
  final _feitas = <_Feita>[];

  /// Simulado: marcações e segundos por questão.
  final _marcacoes = <String, String>{};
  final _segundos = <String, int>{};
  bool _entregue = false;
  int? _aberta;

  DateTime _inicioQuestao = DateTime.now();
  final _inicio = DateTime.now();
  Timer? _timer;
  bool _sessaoSalva = false;
  final _rolagem = ScrollController();

  bool get _simulado => widget.modo == ModoQuestoes.simulado;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _entregue) return;
      setState(() {});
      if (_simulado && widget.minutos != null && _restante <= Duration.zero) {
        _entregar(tempoAcabou: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rolagem.dispose();
    _salvarSessao();
    super.dispose();
  }

  Duration get _decorrido => DateTime.now().difference(_inicio);
  Duration get _restante => Duration(minutes: widget.minutos ?? 0) - _decorrido;

  int _tempoNaQuestao() => DateTime.now().difference(_inicioQuestao).inSeconds;

  void _irPara(int i) {
    if (_simulado && !_entregue) {
      final id = _qs[_i].id;
      _segundos[id] = (_segundos[id] ?? 0) + _tempoNaQuestao();
    }
    setState(() {
      _i = i.clamp(0, _qs.length - 1);
      _marcada = null;
      _atual = null;
      _inicioQuestao = DateTime.now();
    });
    if (_rolagem.hasClients) _rolagem.jumpTo(0);
  }

  // ---------------------------------------------------------------------------
  // Treino
  // ---------------------------------------------------------------------------

  Future<void> _responder() async {
    final letra = _marcada;
    if (letra == null || _atual != null) return;
    final q = _qs[_i];
    final segs = _tempoNaQuestao();
    final id = await _db.registrarResposta(
      questaoId: q.id,
      marcada: letra,
      acertou: letra == q.questao.resposta,
      segundos: segs,
      modo: widget.modo.chave,
    );
    final f = _Feita(q, letra, segs, id);
    _feitas.add(f);
    if (mounted) setState(() => _atual = f);
  }

  Future<void> _motivo(_Feita f, String? m) async {
    setState(() => f.motivo = m ?? '');
    if (m != null) await _db.definirMotivoErro(f.respostaId, m);
  }

  // ---------------------------------------------------------------------------
  // Simulado
  // ---------------------------------------------------------------------------

  Future<void> _entregar({bool tempoAcabou = false}) async {
    if (_entregue) return;
    if (!tempoAcabou) {
      final faltam = _qs.where((q) => !_marcacoes.containsKey(q.id)).length;
      if (faltam > 0) {
        final ok = await confirmar(
          context,
          titulo: 'Entregar o simulado?',
          mensagem:
              '$faltam ${faltam == 1 ? 'questão está' : 'questões estão'} '
              'sem resposta e não vão contar.',
          acao: 'Entregar',
        );
        if (!ok) return;
      }
    }
    final atualId = _qs[_i].id;
    _segundos[atualId] = (_segundos[atualId] ?? 0) + _tempoNaQuestao();
    setState(() => _entregue = true);
    for (final q in _qs) {
      final m = _marcacoes[q.id];
      if (m == null) continue;
      final id = await _db.registrarResposta(
        questaoId: q.id,
        marcada: m,
        acertou: m == q.questao.resposta,
        segundos: _segundos[q.id] ?? 0,
        modo: widget.modo.chave,
      );
      _feitas.add(_Feita(q, m, _segundos[q.id] ?? 0, id));
    }
    await _salvarSessao();
    if (mounted) {
      setState(() {});
      if (tempoAcabou) avisar(context, 'O tempo acabou. Simulado entregue.');
    }
  }

  // ---------------------------------------------------------------------------
  // Sessão de estudo (método Questões) e ciclo
  // ---------------------------------------------------------------------------

  Future<void> _salvarSessao() async {
    if (_sessaoSalva || _feitas.isEmpty) return;
    _sessaoSalva = true;
    final estudadas = await _db.registrarSessoesDeQuestoes([
      for (final f in _feitas)
        (
          materiaId: f.q.questao.materiaId,
          topicoId: f.q.questao.topicoId,
          acertou: f.conta,
          segundos: f.segundos,
        ),
    ]);
    // Se a etapa atual do ciclo é de uma matéria estudada, ele avança.
    final foco = await _db.watchFoco().first;
    if (foco == null) return;
    final ciclo = await _db.watchCiclo(foco.id).first;
    final atual = ciclo.atual;
    if (atual != null && estudadas.contains(atual.materiaId)) {
      await _db.avancarCiclo(foco.id, ciclo.fila.length);
    }
  }

  Future<void> _conferir(QuestaoCompleta q) async {
    await _db.conferirQuestao(q.id);
    final s = q.status..remove(StatusQuestao.revisar);
    setState(() {
      q.questao = q.questao.copyWith(status: StatusQuestao.juntar(s));
    });
    if (mounted) avisar(context, 'Questão conferida');
  }

  // ---------------------------------------------------------------------------
  // Tela
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_qs.isEmpty) {
      return Scaffold(
        appBar: AppBar(toolbarHeight: 72),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Nenhuma questão com esses filtros.',
              style: TextStyle(fontSize: 18, color: Cores.tintaSuave),
            ),
          ),
        ),
      );
    }
    if (_simulado && _entregue) return _resultado();
    final q = _qs[_i];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(
          '${widget.titulo ?? widget.modo.rotulo} · ${_i + 1} de ${_qs.length}',
        ),
        actions: [
          if (_simulado)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: _Relogio(
                  restante: _restante,
                  limite: widget.minutos != null,
                  decorrido: _decorrido,
                ),
              ),
            ),
          if (_simulado)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton(
                key: const ValueKey('entregar'),
                onPressed: _entregar,
                child: const Text('Entregar'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_simulado)
            _Navegador(
              total: _qs.length,
              atual: _i,
              respondida: (i) => _marcacoes.containsKey(_qs[i].id),
              aoTocar: _irPara,
            ),
          Expanded(
            child: _VistaQuestao(
              key: ValueKey(q.id),
              controller: _rolagem,
              q: q,
              marcada: _simulado ? _marcacoes[q.id] : _marcada,
              corrigida: !_simulado && _atual != null,
              aoMarcar: !_simulado && _atual != null
                  ? null
                  : (l) => setState(() {
                      if (_simulado) {
                        _marcacoes[q.id] = l;
                      } else {
                        _marcada = l;
                      }
                    }),
              aoConferir: () => _conferir(q),
              rodape:
                  !_simulado && _atual != null && !_atual!.acertou && !q.anulada
                  ? _PerguntaMotivo(
                      feita: _atual!,
                      aoEscolher: (m) => _motivo(_atual!, m),
                    )
                  : null,
            ),
          ),
          const Divider(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                children: [
                  if (_i > 0 && _simulado)
                    OutlinedButton(
                      onPressed: () => _irPara(_i - 1),
                      child: const Text('Anterior'),
                    ),
                  const Spacer(),
                  if (!_simulado && _atual == null)
                    FilledButton(
                      key: const ValueKey('responder'),
                      onPressed: _marcada == null ? null : _responder,
                      child: const Text('Responder'),
                    )
                  else if (_i < _qs.length - 1)
                    FilledButton(
                      key: const ValueKey('proxima'),
                      onPressed: () => _irPara(_i + 1),
                      child: const Text('Próxima'),
                    )
                  else if (!_simulado)
                    FilledButton(
                      key: const ValueKey('concluir'),
                      onPressed: () async {
                        await _salvarSessao();
                        if (context.mounted) _resumoTreino();
                      },
                      child: const Text('Concluir'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resumoTreino() {
    final contam = _feitas.where((f) => f.conta != null).toList();
    final acertos = contam.where((f) => f.acertou).length;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Treino concluído',
          style: Theme.of(ctx).textTheme.headlineSmall,
        ),
        content: Text(
          contam.isEmpty
              ? 'Nenhuma questão contou (anuladas não contam).'
              : '$acertos de ${contam.length} certas '
                    '(${(acertos * 100 / contam.length).round()}%) em '
                    '${minutosFmt((_decorrido.inSeconds / 60).ceil())}.',
          style: const TextStyle(fontSize: 17),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _resultado() {
    final contam = _feitas.where((f) => f.conta != null).toList();
    final acertos = contam.where((f) => f.acertou).length;
    final porId = {for (final f in _feitas) f.q.id: f};
    final aberta = _aberta;
    if (aberta != null) {
      final q = _qs[aberta];
      final f = porId[q.id];
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: Text('Correção · questão ${aberta + 1}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => setState(() => _aberta = null),
          ),
        ),
        body: _VistaQuestao(
          q: q,
          marcada: f?.marcada,
          corrigida: true,
          aoMarcar: null,
          aoConferir: () => _conferir(q),
          rodape: f != null && !f.acertou && !q.anulada
              ? _PerguntaMotivo(feita: f, aoEscolher: (m) => _motivo(f, m))
              : null,
        ),
      );
    }
    final segs = _feitas.fold<int>(0, (a, f) => a + f.segundos);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Text('Resultado do simulado'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Cartao(
            child: Row(
              children: [
                AnelProgresso(
                  valor: contam.isEmpty ? 0 : acertos / contam.length,
                  cor: corCerto,
                  tamanho: 96,
                  espessura: 9,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$acertos de ${contam.length} certas',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          '${_qs.length - _feitas.length} em branco',
                          if (_feitas.length > contam.length)
                            '${_feitas.length - contam.length} anuladas (não contam)',
                          'tempo: ${minutosFmt((_decorrido.inSeconds / 60).ceil())}',
                          if (_feitas.isNotEmpty)
                            'média: ${(segs / _feitas.length).round()}s por questão',
                        ].join(' · '),
                        style: const TextStyle(color: Cores.tintaSuave),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final (i, q) in _qs.indexed)
            _LinhaResultado(
              indice: i,
              q: q,
              feita: porId[q.id],
              aoTocar: () => setState(() => _aberta = i),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _Relogio extends StatelessWidget {
  const _Relogio({
    required this.restante,
    required this.limite,
    required this.decorrido,
  });
  final Duration restante;
  final bool limite;
  final Duration decorrido;

  @override
  Widget build(BuildContext context) {
    final d = limite ? restante : decorrido;
    final neg = d.isNegative;
    final s = d.abs().inSeconds;
    final t =
        '${neg ? '-' : ''}${s ~/ 3600 > 0 ? '${s ~/ 3600}:' : ''}'
        '${(s ~/ 60 % 60).toString().padLeft(2, '0')}:'
        '${(s % 60).toString().padLeft(2, '0')}';
    final pouco = limite && restante.inMinutes < 5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, color: pouco ? Cores.acento : Cores.tinta),
        const SizedBox(width: 6),
        Text(
          t,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: pouco ? Cores.acento : Cores.tinta,
          ),
        ),
      ],
    );
  }
}

class _Navegador extends StatelessWidget {
  const _Navegador({
    required this.total,
    required this.atual,
    required this.respondida,
    required this.aoTocar,
  });
  final int total;
  final int atual;
  final bool Function(int) respondida;
  final ValueChanged<int> aoTocar;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      itemCount: total,
      separatorBuilder: (_, _) => const SizedBox(width: 6),
      itemBuilder: (_, i) {
        final r = respondida(i);
        return Material(
          color: r ? Cores.tinta : Cores.fundo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: i == atual ? Cores.acento : Cores.linha,
              width: i == atual ? 2.5 : 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => aoTocar(i),
            child: SizedBox(
              width: 44,
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: r ? Colors.white : Cores.tinta,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _LinhaResultado extends StatelessWidget {
  const _LinhaResultado({
    required this.indice,
    required this.q,
    required this.feita,
    required this.aoTocar,
  });
  final int indice;
  final QuestaoCompleta q;
  final _Feita? feita;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final f = feita;
    final (IconData icone, Color cor, String txt) = q.anulada
        ? (Icons.block_rounded, Cores.tintaSuave, 'Anulada')
        : f == null
        ? (
            Icons.remove_rounded,
            Cores.tintaSuave,
            'Em branco · certa: ${q.questao.resposta}',
          )
        : f.acertou
        ? (Icons.check_circle_rounded, corCerto, 'Certa: ${f.marcada}')
        : (
            Icons.cancel_rounded,
            Cores.acento,
            'Marcou ${f.marcada} · certa: ${q.questao.resposta}'
                '${f.motivo != null && f.motivo!.isNotEmpty ? ' · ${motivosErro[f.motivo]}' : ''}',
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Cores.fundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Cores.linha, width: 1.5),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onTap: aoTocar,
          leading: Icon(icone, color: cor, size: 30),
          title: Text(
            '${indice + 1}. ${q.materia.nome}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(txt),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}

class _PerguntaMotivo extends StatelessWidget {
  const _PerguntaMotivo({required this.feita, required this.aoEscolher});
  final _Feita feita;
  final ValueChanged<String?> aoEscolher;

  @override
  Widget build(BuildContext context) {
    final m = feita.motivo;
    return Cartao(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m == null ? 'Por que errou?' : 'Motivo do erro',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in motivosErro.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: m == e.key,
                  labelStyle: TextStyle(
                    color: m == e.key ? Colors.white : Cores.tinta,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => aoEscolher(e.key),
                ),
              if (m == null)
                TextButton(
                  onPressed: () => aoEscolher(null),
                  child: const Text('Pular'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A questão: selos, texto-base, enunciado, prints e alternativas.
class _VistaQuestao extends StatelessWidget {
  const _VistaQuestao({
    super.key,
    required this.q,
    required this.marcada,
    required this.corrigida,
    required this.aoMarcar,
    required this.aoConferir,
    this.rodape,
    this.controller,
  });
  final QuestaoCompleta q;
  final String? marcada;
  final bool corrigida;
  final ValueChanged<String>? aoMarcar;
  final VoidCallback aoConferir;
  final Widget? rodape;
  final ScrollController? controller;

  void _abrirTexto(BuildContext context, TextoBase t) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          children: [
            if (t.titulo.isNotEmpty)
              Text(t.titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SelectableText(
              t.conteudo,
              style: const TextStyle(fontSize: 17, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _anexar(BuildContext context, ImageSource fonte) async {
    final db = context.read<AppDatabase>();
    try {
      final f = await ImagePicker().pickImage(
        source: fonte,
        maxWidth: 2400,
        imageQuality: 85,
      );
      if (f == null) return;
      await ArquivosAnexos.importarPrint(db: db, questaoId: q.id, origem: f);
    } catch (_) {
      if (context.mounted) avisar(context, 'Não foi possível anexar a imagem');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = q.status;
    final alts = q.alternativas;
    final prova = q.prova;
    final legislacaoAntiga =
        ehLegislacao(q.materia.nome, q.questao.topicoOriginal) &&
        provaAntiga(prova.ano, DateTime.now());
    final certa = q.questao.resposta;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Text(
              '${prova.orgao} · ${prova.ano} · questão ${doisDigitos(q.questao.numero)}',
              style: const TextStyle(color: Cores.tintaSuave),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Bolinha(Color(q.materia.cor)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      q.materia.nome,
                      q.topico?.nome ?? q.questao.topicoOriginal,
                    ].where((x) => x.isNotEmpty).join(' · '),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (s.contains(StatusQuestao.anulada))
                  const Selo('Anulada: não conta', icone: Icons.block_rounded),
                if (s.contains(StatusQuestao.desatualizada))
                  const Selo(
                    'Lei mudou',
                    cor: corAviso,
                    icone: Icons.history_rounded,
                  ),
                if (legislacaoAntiga)
                  Selo(
                    'Prova de ${prova.ano}: confira a lei atual',
                    cor: corAviso,
                    icone: Icons.gavel_rounded,
                  ),
                if (s.contains(StatusQuestao.revisar))
                  Selo(
                    'Revisar',
                    cor: corStatus(StatusQuestao.revisar),
                    icone: iconeStatus(StatusQuestao.revisar),
                  ),
              ],
            ),
            if (s.contains(StatusQuestao.desatualizada) &&
                q.questao.obs.isNotEmpty) ...[
              const SizedBox(height: 12),
              CaixaObs(q.questao.obs, titulo: 'Lei mudou'),
            ],
            if (s.contains(StatusQuestao.revisar)) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'A extração desta questão pode ter erro. Confira com a '
                      'prova original.',
                      style: TextStyle(color: Cores.tintaSuave),
                    ),
                  ),
                  TextButton.icon(
                    key: const ValueKey('conferi'),
                    onPressed: aoConferir,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Conferi, está certa'),
                  ),
                ],
              ),
            ],
            if (q.texto != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  key: const ValueKey('abrir-texto'),
                  onPressed: () => _abrirTexto(context, q.texto!),
                  icon: const Icon(Icons.article_outlined),
                  label: Text(
                    q.texto!.titulo.isEmpty
                        ? 'Ler o texto ${q.texto!.codigo}'
                        : 'Ler o texto',
                  ),
                ),
              ),
            ],
            if (s.contains(StatusQuestao.imagem)) ...[
              const SizedBox(height: 12),
              _Imagem(q: q, aoAnexar: (f) => _anexar(context, f)),
            ],
            const SizedBox(height: 16),
            SelectableText(
              q.questao.enunciado,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 16),
            for (final e in alts.entries)
              _Alternativa(
                letra: e.key,
                texto: e.value,
                marcada: marcada == e.key,
                estado: !corrigida
                    ? null
                    : e.key == certa
                    ? true
                    : marcada == e.key
                    ? false
                    : null,
                aoTocar: aoMarcar == null ? null : () => aoMarcar!(e.key),
              ),
            if (corrigida) ...[
              const SizedBox(height: 8),
              _Veredito(q: q, marcada: marcada),
              if (q.questao.obs.isNotEmpty &&
                  !s.contains(StatusQuestao.desatualizada)) ...[
                const SizedBox(height: 12),
                CaixaObs(q.questao.obs),
              ],
              if (rodape != null) ...[const SizedBox(height: 12), rodape!],
            ],
          ],
        ),
      ),
    );
  }
}

class _Veredito extends StatelessWidget {
  const _Veredito({required this.q, required this.marcada});
  final QuestaoCompleta q;
  final String? marcada;

  @override
  Widget build(BuildContext context) {
    final certa = q.questao.resposta;
    final (String t, Color c) = q.anulada
        ? ('Questão anulada: não conta como acerto nem erro.', Cores.tintaSuave)
        : marcada == null
        ? ('Em branco. A certa é $certa.', Cores.tintaSuave)
        : marcada == certa
        ? ('Certa!', corCerto)
        : ('Errou. A certa é $certa.', Cores.acento);
    return Text(
      t,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: c),
    );
  }
}

class _Alternativa extends StatelessWidget {
  const _Alternativa({
    required this.letra,
    required this.texto,
    required this.marcada,
    required this.estado,
    required this.aoTocar,
  });
  final String letra;
  final String texto;
  final bool marcada;

  /// true = certa, false = marcada errada, nulo = neutra.
  final bool? estado;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final cor = estado == true
        ? corCerto
        : estado == false
        ? Cores.acento
        : marcada
        ? Cores.tinta
        : Cores.linha;
    final destaque = estado != null || marcada;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: estado == true
            ? corCerto.withValues(alpha: 0.08)
            : estado == false
            ? Cores.acento.withValues(alpha: 0.08)
            : Cores.fundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: cor, width: destaque ? 2.5 : 1.5),
        ),
        child: InkWell(
          key: ValueKey('alt-$letra'),
          borderRadius: BorderRadius.circular(18),
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: destaque ? cor : Cores.fundoLateral,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    letra,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: destaque ? Colors.white : Cores.tinta,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      texto,
                      style: const TextStyle(fontSize: 17, height: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aviso de questão com imagem: descrição do "obs" e prints anexados.
class _Imagem extends StatelessWidget {
  const _Imagem({required this.q, required this.aoAnexar});
  final QuestaoCompleta q;
  final ValueChanged<ImageSource> aoAnexar;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Cartao(
      corBorda: corStatus(StatusQuestao.imagem),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image_outlined),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Esta questão tem uma imagem que não veio no texto.',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          if (q.questao.obs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(q.questao.obs, style: const TextStyle(height: 1.4)),
          ],
          Assistir<List<PrintQuestao>>(
            chave: q.id,
            stream: () => db.watchPrints(q.id),
            builder: (context, prints) => _Prints(prints: prints ?? const []),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pilula(
                icone: Icons.photo_camera_outlined,
                rotulo: 'Câmera',
                aoTocar: () => aoAnexar(ImageSource.camera),
              ),
              Pilula(
                icone: Icons.photo_library_outlined,
                rotulo: 'Galeria',
                aoTocar: () => aoAnexar(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Prints extends StatelessWidget {
  const _Prints({required this.prints});
  final List<PrintQuestao> prints;

  @override
  Widget build(BuildContext context) {
    if (prints.isEmpty) return const SizedBox.shrink();
    final db = context.read<AppDatabase>();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          for (final p in prints)
            FutureBuilder<File>(
              future: ArquivosAnexos.arquivo(p.arquivo),
              builder: (context, snap) {
                final f = snap.data;
                if (f == null) return const SizedBox(height: 120);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          body: InteractiveViewer(
                            maxScale: 6,
                            child: Center(child: Image.file(f)),
                          ),
                        ),
                      ),
                    ),
                    onLongPress: () async {
                      final ok = await confirmar(
                        context,
                        titulo: 'Excluir print?',
                        mensagem: 'A imagem sai só desta questão.',
                      );
                      if (ok) await ArquivosAnexos.excluirPrint(db, p);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        f,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
