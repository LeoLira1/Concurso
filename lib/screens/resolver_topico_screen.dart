import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/questoes_topico_db.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/comuns.dart';
import '../widgets/provas_comuns.dart';

/// Abre o "Resolver questões" de um tópico (com os subtópicos) ou de uma
/// matéria. Entram as que vencem hoje (erradas e novas primeiro); se não
/// houver nenhuma, oferece praticar todas.
Future<void> abrirResolverQuestoes(
  BuildContext context, {
  required String titulo,
  String? topicoId,
  String? materiaId,
  String? concursoId,
  bool todas = false,
}) async {
  final db = context.read<AppDatabase>();
  var fila = await db.filaQuestoesTopico(
    topicoId: topicoId,
    materiaId: materiaId,
    concursoId: concursoId,
    todas: todas,
  );
  if (!context.mounted) return;
  if (fila.isEmpty && !todas) {
    final total = await db
        .watchQuestoesTopico(
          topicoId: topicoId,
          materiaId: materiaId,
          concursoId: concursoId,
        )
        .first;
    if (!context.mounted) return;
    if (total.isEmpty) {
      avisar(context, 'Nenhuma questão ainda. Use "Colar questões".');
      return;
    }
    final ok = await confirmar(
      context,
      titulo: 'Nada para hoje',
      mensagem:
          'Você está em dia com as ${total.length} questões. '
          'Quer praticar todas mesmo assim?',
      acao: 'Praticar todas',
    );
    if (!ok || !context.mounted) return;
    fila = await db.filaQuestoesTopico(
      topicoId: topicoId,
      materiaId: materiaId,
      concursoId: concursoId,
      todas: true,
    );
    if (!context.mounted) return;
  }
  if (fila.isEmpty) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ResolverTopicoScreen(titulo: titulo, fila: fila),
    ),
  );
}

/// Uma questão por tela: toque na alternativa e veja na hora se acertou,
/// com a explicação. A errada volta para o fim da fila (e, pelo Leitner,
/// volta mais vezes nos próximos dias). Ao terminar, as questões feitas e
/// os acertos viram uma sessão de estudo com método "Questões".
class ResolverTopicoScreen extends StatefulWidget {
  const ResolverTopicoScreen({
    super.key,
    required this.titulo,
    required this.fila,
  });

  final String titulo;
  final List<QuestaoTopicoInfo> fila;

  @override
  State<ResolverTopicoScreen> createState() => _ResolverTopicoScreenState();
}

class _ResolverTopicoScreenState extends State<ResolverTopicoScreen> {
  late final AppDatabase _db = context.read<AppDatabase>();
  late final List<QuestaoTopicoInfo> _fila = [...widget.fila];
  late final int _total = widget.fila.length;

  /// Primeira resposta de cada questão nesta sessão (é o que conta nas
  /// estatísticas; repetir a errada só serve para fixar).
  final _primeiras = <String, RespostaTopico>{};

  /// Questões erradas na primeira tentativa (para "Refazer as erradas").
  final _erradas = <QuestaoTopicoInfo>[];

  /// Como cada questão chegou à sessão (os selos não mudam ao responder).
  late final _nova = {for (final q in widget.fila) q.id: q.nova};
  late final _erradaAntes = {
    for (final q in widget.fila)
      q.id: q.questao.erros > 0 && q.questao.caixa == 0,
  };

  /// Errou nesta sessão e voltou para o fim da fila.
  final _repetidas = <String>{};
  String? _marcada;
  DateTime _inicioQuestao = DateTime.now();
  final _inicio = DateTime.now();
  bool _salva = false;
  bool _fim = false;
  final _rolagem = ScrollController();
  final _rolagemAlts = ScrollController();

  QuestaoTopicoInfo? get _atual => _fila.isEmpty ? null : _fila.first;
  int get _certas => _primeiras.values.where((r) => r.acertou).length;
  int get _feitas => _primeiras.length;

  @override
  void dispose() {
    _rolagem.dispose();
    _rolagemAlts.dispose();
    _salvar();
    super.dispose();
  }

  Future<void> _responder(String letra) async {
    final q = _atual;
    if (q == null || _marcada != null) return;
    final acertou = letra == q.questao.gabarito;
    final segs = DateTime.now().difference(_inicioQuestao).inSeconds;
    setState(() => _marcada = letra);
    _primeiras.putIfAbsent(q.id, () {
      if (!acertou) _erradas.add(q);
      return (
        materiaId: q.materia.id,
        topicoId: q.topico.id,
        acertou: acertou,
        segundos: segs,
      );
    });
    q.questao = await _db.responderQuestaoTopico(q.questao, acertou: acertou);
  }

  void _proxima() {
    final q = _fila.removeAt(0);
    // Errou: volta no fim da fila desta sessão.
    if (_marcada != null && _marcada != q.questao.gabarito) {
      _fila.add(q);
      _repetidas.add(q.id);
    }
    setState(() {
      _marcada = null;
      _inicioQuestao = DateTime.now();
      if (_fila.isEmpty) _fim = true;
    });
    if (_fila.isEmpty) _salvar();
    if (_rolagem.hasClients) _rolagem.jumpTo(0);
    if (_rolagemAlts.hasClients) _rolagemAlts.jumpTo(0);
  }

  Future<void> _encerrar() async {
    setState(() => _fim = true);
    await _salvar();
  }

  Future<void> _suspeito() async {
    final q = _atual;
    if (q == null) return;
    final novo = !q.questao.suspeito;
    await _db.marcarSuspeito(q.id, novo);
    // Sem aviso por cima: o selo e a bandeira laranja já mostram.
    if (mounted) {
      setState(() => q.questao = q.questao.copyWith(suspeito: novo));
    }
  }

  /// Grava a sessão (uma vez só) e faz o ciclo andar se a matéria da vez
  /// foi estudada.
  Future<void> _salvar() async {
    if (_salva || _primeiras.isEmpty) return;
    _salva = true;
    final estudadas = await _db.registrarSessaoQuestoesTopico(
      _primeiras.values.toList(),
    );
    final foco = await _db.watchFoco().first;
    if (foco == null) return;
    final ciclo = await _db.watchCiclo(foco.id).first;
    final atual = ciclo.atual;
    if (atual != null && estudadas.contains(atual.materiaId)) {
      await _db.avancarCiclo(foco.id, ciclo.fila.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _atual;
    if (_fim || q == null) return _resumo();
    final respondida = _marcada != null;
    final restantes = _total - _feitas;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(widget.titulo, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(
            key: const ValueKey('encerrar'),
            onPressed: _feitas == 0 ? () => Navigator.pop(context) : _encerrar,
            child: const Text('Encerrar'),
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _total == 0 ? 0 : _feitas / _total,
            minHeight: 4,
            backgroundColor: Cores.linha,
            color: Cores.tinta,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  final deitado =
                      box.maxWidth >= 900 && box.maxWidth > box.maxHeight;
                  final cabecalho = _Cabecalho(
                    q: q,
                    nova: (_nova[q.id] ?? false) && !_repetidas.contains(q.id),
                    voltou: _voltou(q),
                  );
                  final enunciado = SelectableText(
                    q.questao.enunciado,
                    style: TextStyle(fontSize: deitado ? 20 : 19, height: 1.55),
                  );
                  final alternativas = [
                    for (final e in q.alternativas.entries)
                      BotaoAlternativa(
                        letra: e.key,
                        texto: e.value,
                        marcada: _marcada == e.key,
                        estado: !respondida
                            ? null
                            : e.key == q.questao.gabarito
                            ? true
                            : _marcada == e.key
                            ? false
                            : null,
                        aoTocar: respondida ? null : () => _responder(e.key),
                      ),
                    if (respondida) ...[
                      const SizedBox(height: 6),
                      _Veredito(certa: q.questao.gabarito, marcada: _marcada!),
                      if (q.questao.explicacao.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        CaixaObs(q.questao.explicacao, titulo: 'Explicação'),
                      ],
                    ],
                  ];
                  if (deitado) {
                    // Tablet deitado: enunciado à esquerda, alternativas e
                    // correção à direita, cada lado com a sua rolagem.
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 11,
                          child: ListView(
                            controller: _rolagem,
                            padding: const EdgeInsets.fromLTRB(36, 20, 28, 24),
                            children: [
                              cabecalho,
                              const SizedBox(height: 18),
                              enunciado,
                            ],
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          flex: 10,
                          child: ListView(
                            controller: _rolagemAlts,
                            padding: const EdgeInsets.fromLTRB(28, 20, 36, 24),
                            children: alternativas,
                          ),
                        ),
                      ],
                    );
                  }
                  // Em pé / celular: tudo numa coluna.
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: ListView(
                        controller: _rolagem,
                        padding: EdgeInsets.fromLTRB(
                          box.maxWidth < 600 ? 18 : 32,
                          16,
                          box.maxWidth < 600 ? 18 : 32,
                          24,
                        ),
                        children: [
                          cabecalho,
                          const SizedBox(height: 16),
                          enunciado,
                          const SizedBox(height: 20),
                          ...alternativas,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        if (restantes > 0) 'faltam $restantes',
                        if (restantes == 0 && _fila.isNotEmpty)
                          'refazendo as erradas',
                        '$_certas ${_certas == 1 ? 'certa' : 'certas'}',
                        if (_feitas - _certas > 0)
                          '${_feitas - _certas} '
                              '${_feitas - _certas == 1 ? 'errada' : 'erradas'}',
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Cores.tintaSuave,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _BotaoSuspeito(ativo: q.questao.suspeito, aoTocar: _suspeito),
                  const SizedBox(width: 10),
                  FilledButton(
                    key: const ValueKey('proxima'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 52),
                    ),
                    onPressed: respondida ? _proxima : null,
                    child: Text(
                      _fila.length == 1 &&
                              (_marcada == null ||
                                  _marcada == q.questao.gabarito)
                          ? 'Concluir'
                          : 'Próxima',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A questão voltou porque foi errada (nesta sessão ou antes).
  bool _voltou(QuestaoTopicoInfo q) =>
      _repetidas.contains(q.id) || (_erradaAntes[q.id] ?? false);

  Widget _resumo() {
    final pct = _feitas == 0 ? 0 : (_certas * 100 / _feitas).round();
    final minutos = (DateTime.now().difference(_inicio).inSeconds / 60).ceil();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 72, title: const Text('Sessão concluída')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Cartao(
                child: Row(
                  children: [
                    AnelProgresso(
                      valor: _feitas == 0 ? 0 : _certas / _feitas,
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
                            _feitas == 0
                                ? 'Nenhuma questão respondida'
                                : '$_certas de $_feitas certas ($pct%)',
                            key: const ValueKey('placar'),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _feitas == 0
                                ? 'Nada foi registrado.'
                                : 'Registrado como sessão de "Questões" '
                                      '(${minutosFmt(minutos)}): entra na % '
                                      'de acerto da matéria e do tópico.',
                            style: const TextStyle(color: Cores.tintaSuave),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_erradas.isNotEmpty) ...[
                const SizedBox(height: 16),
                Cartao(
                  titulo: 'Erradas (voltam mais vezes)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final q in _erradas)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            '• ${_curto(q.questao.enunciado)}',
                            style: const TextStyle(fontSize: 15, height: 1.35),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.end,
                children: [
                  if (_erradas.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => ResolverTopicoScreen(
                            titulo: widget.titulo,
                            fila: _erradas,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Refazer as erradas'),
                    ),
                  FilledButton(
                    key: const ValueKey('fechar'),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _curto(String s) {
  final t = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return t.length <= 140 ? t : '${t.substring(0, 137)}…';
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.q, required this.nova, required this.voltou});
  final QuestaoTopicoInfo q;
  final bool nova;
  final bool voltou;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Bolinha(Color(q.materia.cor)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${q.materia.nome} · ${q.caminho}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Selo(
            'Dificuldade ${q.questao.dificuldade}/5',
            icone: Icons.signal_cellular_alt_rounded,
          ),
          if (nova)
            const Selo('Nova', cor: corCerto, icone: Icons.fiber_new_rounded)
          else if (voltou)
            const Selo(
              'Voltou: você errou',
              cor: Cores.acento,
              icone: Icons.replay_rounded,
            ),
          if (q.questao.suspeito)
            const Selo(
              'Gabarito suspeito',
              cor: corAviso,
              icone: Icons.flag_rounded,
            ),
        ],
      ),
    ],
  );
}

class _Veredito extends StatelessWidget {
  const _Veredito({required this.certa, required this.marcada});
  final String certa;
  final String marcada;

  @override
  Widget build(BuildContext context) {
    final ok = marcada == certa;
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: ok ? corCerto : Cores.acento,
          size: 28,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ok ? 'Certa!' : 'Errou. A certa é $certa.',
            key: const ValueKey('veredito'),
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: ok ? corCerto : Cores.acento,
            ),
          ),
        ),
      ],
    );
  }
}

class _BotaoSuspeito extends StatelessWidget {
  const _BotaoSuspeito({required this.ativo, required this.aoTocar});
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final estreito = MediaQuery.sizeOf(context).width < 600;
    final icone = Icon(
      ativo ? Icons.flag_rounded : Icons.outlined_flag_rounded,
      color: ativo ? corAviso : Cores.tinta,
    );
    const rotulo = 'Gabarito suspeito';
    if (estreito) {
      return IconButton(
        key: const ValueKey('suspeito'),
        tooltip: rotulo,
        onPressed: aoTocar,
        icon: icone,
      );
    }
    return OutlinedButton.icon(
      key: const ValueKey('suspeito'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        foregroundColor: ativo ? corAviso : Cores.tinta,
        side: BorderSide(color: ativo ? corAviso : Cores.linha, width: 1.5),
      ),
      onPressed: aoTocar,
      icon: icone,
      label: const Text(rotulo),
    );
  }
}
