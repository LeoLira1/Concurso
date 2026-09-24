import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../logic/mapa_mental.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import '../widgets/mapa_painter.dart';
import 'topico_screen.dart';

/// Chaves das preferências locais (fora do sync do Turso).
const _prefRecolhidas = 'mapa.recolhidas';
const _prefLegenda = 'mapa.legenda';

/// Espaço livre em volta do mapa, para poder arrastar além das bordas.
const _margem = 600.0;
const _escalaMax = 3.0;

/// Mapa mental gerado a partir do edital: matéria → tópico → subtópico,
/// colorido pela situação de estudo. Só leitura. Segue o mesmo escopo da
/// tela inicial (concurso em foco ou tudo junto).
class MapaMentalScreen extends StatefulWidget {
  const MapaMentalScreen({super.key, this.materiaInicial});

  /// Abre com esta matéria no centro.
  final String? materiaInicial;

  @override
  State<MapaMentalScreen> createState() => MapaMentalScreenState();
}

class MapaMentalScreenState extends State<MapaMentalScreen>
    with SingleTickerProviderStateMixin {
  late String? _filtro = widget.materiaInicial;
  Set<String> _recolhidas = {};
  bool _legendaAberta = true;
  bool _prefsProntas = false;

  final _tc = TransformationController();
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  Animation<Matrix4>? _animMatriz;
  final _limite = ValueNotifier<double>(0);

  // Layout em cache: só refaz quando os dados, o filtro ou os ramos
  // recolhidos mudam.
  List<Object?> _chave = const [];
  NoMapa? _arvore;
  CacheMapa? _cache;
  Size _tamanhoCanvas = Size.zero;
  Map<String, InfoTopico> _porMateria = {};
  Map<String, MateriaMapa> _materias = {};

  Size _viewport = Size.zero;
  String? _escopoAjustado;
  bool _ajustarPendente = true;

  /// Nó que deve ficar parado na tela depois de recolher/expandir.
  (String, Offset)? _ancora;

  _Detalhe? _detalhe;
  final _pilha = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tc.addListener(_aoTransformar);
    _anim.addListener(() {
      final a = _animMatriz;
      if (a != null) _tc.value = a.value;
    });
    _carregarPrefs();
  }

  bool get _telaLarga {
    final v = WidgetsBinding.instance.platformDispatcher.views.first;
    return v.physicalSize.shortestSide / v.devicePixelRatio >= 600;
  }

  Future<void> _carregarPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      _recolhidas = (p.getStringList(_prefRecolhidas) ?? const []).toSet();
      // Em tela estreita (celular) a legenda começa recolhida.
      _legendaAberta = p.getBool(_prefLegenda) ?? _telaLarga;
    } catch (_) {
      // Sem preferências: segue com o padrão.
    }
    if (mounted) setState(() => _prefsProntas = true);
  }

  Future<void> _salvarPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_prefRecolhidas, _recolhidas.toList());
      await p.setBool(_prefLegenda, _legendaAberta);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tc.removeListener(_aoTransformar);
    _tc.dispose();
    _anim.dispose();
    _limite.dispose();
    _cache?.descartar();
    super.dispose();
  }

  double get _escala => _tc.value.getMaxScaleOnAxis();

  void _aoTransformar() => _limite.value = limiteFonte(_escala);

  // ---------------------------------------------------------------------------
  // Dados → árvore → layout
  // ---------------------------------------------------------------------------

  void _atualizarLayout({
    required String rotuloRaiz,
    required List<MateriaInfo> escopo,
    required List<Materia> todas,
    required List<Topico> topicos,
    required List<Sessao> sessoes,
    required List<RevisaoInfo> revisoes,
    required Map<String, int> cartoes,
  }) {
    final filtro = _filtro != null && todas.any((m) => m.id == _filtro)
        ? _filtro
        : null;
    final chave = <Object?>[
      rotuloRaiz,
      escopo,
      todas,
      topicos,
      sessoes,
      revisoes,
      cartoes,
      filtro,
      _recolhidas,
    ];
    if (_chave.length == chave.length &&
        Iterable.generate(chave.length).every(
          (i) => identical(_chave[i], chave[i]) || _chave[i] == chave[i],
        )) {
      return;
    }
    _chave = chave;

    final info = <String, InfoTopico>{};
    final porMateria = <String, InfoTopico>{};
    for (final s in sessoes) {
      if (s.topicoId != null) {
        (info[s.topicoId!] ??= InfoTopico())
          ..minutos += s.minutos
          ..feitas += s.questoesFeitas
          ..acertos += s.questoesAcertos;
      }
      if (s.materiaId != null) {
        (porMateria[s.materiaId!] ??= InfoTopico())
          ..minutos += s.minutos
          ..feitas += s.questoesFeitas
          ..acertos += s.questoesAcertos;
      }
    }
    for (final r in revisoes) {
      final i = info[r.topico.id] ??= InfoTopico();
      final d = r.revisao.dataPrevista;
      if (i.proximaRevisao == null || d.isBefore(i.proximaRevisao!)) {
        i.proximaRevisao = d;
      }
    }
    cartoes.forEach((id, n) => (info[id] ??= InfoTopico()).flashcards = n);

    final lista = [
      for (final m in escopo)
        MateriaMapa(m.materia.id, m.materia.nome, m.materia.cor),
    ];
    // Matéria aberta pela tela dela, mas fora do escopo atual.
    if (filtro != null && !lista.any((m) => m.id == filtro)) {
      final m = todas.firstWhere((m) => m.id == filtro);
      lista.add(MateriaMapa(m.id, m.nome, m.cor));
    }
    _materias = {for (final m in lista) m.id: m};
    _porMateria = porMateria;

    final arvore = montarArvore(
      rotuloRaiz: rotuloRaiz,
      materias: lista,
      topicos: [
        for (final t in topicos)
          TopicoMapa(
            id: t.id,
            materiaId: t.materiaId,
            paiId: t.paiId,
            nome: t.nome,
            visto: t.visto,
            ordem: t.ordem,
          ),
      ],
      info: info,
      recolhidas: _recolhidas,
      materiaCentral: filtro,
      hoje: DateTime.now(),
    );
    final layout = calcularLayout(arvore);
    final origem = -layout.limites.topLeft + const Offset(_margem, _margem);
    _cache?.descartar();
    _cache = CacheMapa(layout, origem);
    _arvore = arvore;
    _tamanhoCanvas = layout.limites.size + const Offset(_margem, _margem) * 2;

    final escopoAtual = '$rotuloRaiz|$filtro';
    if (escopoAtual != _escopoAjustado) {
      _escopoAjustado = escopoAtual;
      _ajustarPendente = true;
      _detalhe = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Câmera
  // ---------------------------------------------------------------------------

  double get _escalaAjuste {
    final c = _cache;
    if (c == null || _viewport.isEmpty) return 1;
    final l = c.layout.limites;
    return math.min(
          _viewport.width / (l.width + 48),
          _viewport.height / (l.height + 48),
        ) *
        0.94;
  }

  double get _escalaMin => math.min(0.4, _escalaAjuste * 0.6);

  Matrix4 _matriz(double escala, Offset pontoCanvas, Offset naTela) {
    final t = naTela - pontoCanvas * escala;
    return Matrix4.diagonal3Values(escala, escala, escala)
      ..setTranslationRaw(t.dx, t.dy, 0);
  }

  void _irPara(Matrix4 alvo, {bool animado = true}) {
    if (!animado) {
      _anim.stop();
      _tc.value = alvo;
      return;
    }
    _animMatriz = Matrix4Tween(
      begin: _tc.value.clone(),
      end: alvo,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward(from: 0);
  }

  /// Mostra o mapa inteiro.
  void _ajustar({bool animado = true}) {
    final c = _cache;
    if (c == null || _viewport.isEmpty) return;
    final centro = c.layout.limites.center + c.origem;
    _irPara(
      _matriz(
        _escalaAjuste.clamp(0.02, 1.2),
        centro,
        _viewport.center(Offset.zero),
      ),
      animado: animado,
    );
  }

  /// Leva o centro do mapa para o meio da tela, num zoom de leitura.
  void _centralizar() {
    final c = _cache;
    if (c == null) return;
    final e = _escala < 0.6 ? 1.0 : _escala;
    _irPara(_matriz(e, c.origem, _viewport.center(Offset.zero)));
  }

  void _zoom(double fator) {
    final e = (_escala * fator).clamp(_escalaMin, _escalaMax);
    final f = e / _escala;
    final c = _viewport.center(Offset.zero);
    final alvo = Matrix4.translationValues(c.dx, c.dy, 0)
      ..multiply(Matrix4.diagonal3Values(f, f, f))
      ..multiply(Matrix4.translationValues(-c.dx, -c.dy, 0))
      ..multiply(_tc.value);
    _irPara(alvo);
  }

  Offset _naTela(Offset canvas) =>
      MatrixUtils.transformPoint(_tc.value, canvas);

  /// Centro do nó [id] na tela (coordenadas globais), para os testes.
  @visibleForTesting
  Offset? posicaoGlobal(String id) {
    final c = _cache;
    final n = c?.layout.porId(id);
    final caixa = _pilha.currentContext?.findRenderObject() as RenderBox?;
    if (c == null || n == null || caixa == null) return null;
    return caixa.localToGlobal(_naTela(n.centro + c.origem));
  }

  /// Escala atual do mapa, para os testes.
  @visibleForTesting
  double get escala => _escala;

  void _depoisDoLayout() {
    if (_ajustarPendente && _cache != null && !_viewport.isEmpty) {
      _ajustarPendente = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ajustar(animado: false);
      });
    }
    final ancora = _ancora;
    if (ancora != null && _cache != null) {
      _ancora = null;
      final n = _cache!.layout.porId(ancora.$1);
      if (n == null) return;
      final novo = n.centro + _cache!.origem;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final d = ancora.$2 - _naTela(novo);
        _tc.value = Matrix4.translationValues(d.dx, d.dy, 0)
          ..multiply(_tc.value);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Toques
  // ---------------------------------------------------------------------------

  NoPosicionado? _noEm(Offset canvas) {
    final c = _cache;
    if (c == null) return null;
    return c.layout.noEm(canvas - c.origem, folga: 6);
  }

  void _tocar(Offset canvas) {
    if (_detalhe != null) {
      setState(() => _detalhe = null);
      return;
    }
    final n = _noEm(canvas);
    if (n == null) return;
    switch (n.no.tipo) {
      case TipoNo.materia when n.profundidade > 0:
        _alternar(n);
      case TipoNo.topico || TipoNo.subtopico:
        _abrirTopico(n.no.id);
      default:
        break;
    }
  }

  void _alternar(NoPosicionado n) {
    final id = n.no.id;
    _ancora = (id, _naTela(n.centro + _cache!.origem));
    setState(() {
      _recolhidas = {..._recolhidas};
      if (!_recolhidas.remove(id)) _recolhidas.add(id);
      _detalhe = null;
    });
    _salvarPrefs();
  }

  void _todas({required bool recolher}) {
    final raiz = _arvore;
    if (raiz == null) return;
    setState(() {
      _recolhidas = recolher
          ? {..._recolhidas, ..._materias.keys}
          : _recolhidas.difference(_materias.keys.toSet());
      _ajustarPendente = true;
    });
    _salvarPrefs();
  }

  void _abrirTopico(String id) {
    setState(() => _detalhe = null);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TopicoScreen(topicoId: id)),
    );
  }

  void _segurar(Offset canvas, Offset global) {
    final n = _noEm(canvas);
    if (n == null) return;
    final caixa = _pilha.currentContext?.findRenderObject() as RenderBox?;
    if (caixa == null) return;
    HapticFeedback.selectionClick();
    setState(() => _detalhe = _Detalhe(n, caixa.globalToLocal(global)));
  }

  void _filtrar(String? materiaId) {
    setState(() {
      _filtro = materiaId;
      _detalhe = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Tela
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final estado = context.watch<AppState>();
    return Assistir<List<Concurso>>(
      chave: 'concursos',
      stream: db.watchConcursos,
      builder: (context, concursos) {
        if (concursos == null || !_prefsProntas) return _vazia();
        if (concursos.isEmpty) return _vazia(texto: 'Nenhum concurso ainda.');
        final foco = concursos.firstWhere(
          (c) => c.foco,
          orElse: () => concursos.first,
        );
        final escopo = estado.verTudo ? null : foco.id;
        final rotuloRaiz = estado.verTudo ? 'Todos' : foco.nome;
        return Assistir<List<MateriaInfo>>(
          chave: escopo,
          stream: () => db.watchMaterias(escopo),
          builder: (context, mats) => Assistir<List<Materia>>(
            chave: 'materias',
            stream: db.watchTodasMaterias,
            builder: (context, todas) => Assistir<List<Topico>>(
              chave: 'topicos',
              stream: db.watchTodosTopicos,
              builder: (context, topicos) => Assistir<List<Sessao>>(
                chave: 'sessoes',
                stream: db.watchTodasSessoes,
                builder: (context, sessoes) => Assistir<List<RevisaoInfo>>(
                  chave: 'revisoes',
                  stream: () => db.watchRevisoesPendentes(DateTime(2100)),
                  builder: (context, revisoes) => Assistir<Map<String, int>>(
                    chave: 'cartoes',
                    stream: db.watchFlashcardsPorTopico,
                    builder: (context, cartoes) {
                      if (mats == null ||
                          todas == null ||
                          topicos == null ||
                          sessoes == null ||
                          revisoes == null ||
                          cartoes == null) {
                        return _vazia();
                      }
                      _atualizarLayout(
                        rotuloRaiz: rotuloRaiz,
                        escopo: mats,
                        todas: todas,
                        topicos: topicos,
                        sessoes: sessoes,
                        revisoes: revisoes,
                        cartoes: cartoes,
                      );
                      return _tela(
                        subtitulo: estado.verTudo
                            ? 'Todos os concursos'
                            : foco.nome,
                        materias: mats,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _vazia({String? texto}) => Scaffold(
    appBar: AppBar(toolbarHeight: 72),
    body: texto == null
        ? const SizedBox.shrink()
        : Center(
            child: Text(texto, style: const TextStyle(color: Cores.tintaSuave)),
          ),
  );

  Widget _tela({
    required String subtitulo,
    required List<MateriaInfo> materias,
  }) {
    final arvore = _arvore!;
    final central = arvore.tipo == TipoNo.materia ? arvore : null;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mapa mental', style: Theme.of(context).textTheme.titleLarge),
            Text(
              central == null ? subtitulo : '$subtitulo · ${central.rotulo}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Cores.tintaSuave),
            ),
          ],
        ),
        actions: [
          _SeletorFiltro(
            materias: materias,
            extra:
                central != null &&
                    !materias.any((m) => m.materia.id == central.id)
                ? central
                : null,
            filtro: central?.id,
            aoEscolher: _filtrar,
          ),
          if (central == null)
            PopupMenuButton<bool>(
              tooltip: 'Mais opções',
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (recolher) => _todas(recolher: recolher),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: false,
                  height: 52,
                  child: Text('Expandir todas as matérias'),
                ),
                PopupMenuItem(
                  value: true,
                  height: 52,
                  child: Text('Recolher todas as matérias'),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          _viewport = box.biggest;
          _depoisDoLayout();
          final cache = _cache!;
          return Stack(
            key: _pilha,
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: Cores.fundo,
                  child: InteractiveViewer(
                    transformationController: _tc,
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: _escalaMin,
                    maxScale: _escalaMax,
                    onInteractionStart: (_) {
                      _anim.stop();
                      if (_detalhe != null) setState(() => _detalhe = null);
                    },
                    child: GestureDetector(
                      onTapUp: (d) => _tocar(d.localPosition),
                      onLongPressStart: (d) =>
                          _segurar(d.localPosition, d.globalPosition),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: _tamanhoCanvas,
                          painter: MapaPainter(cache: cache, limite: _limite),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: RotulosMateriasPainter(
                      cache: cache,
                      transformacao: _tc,
                    ),
                  ),
                ),
              ),
              if (arvore.filhos.isEmpty)
                const Positioned(
                  left: 24,
                  right: 24,
                  top: 24,
                  child: Text(
                    'Nenhum tópico para mostrar. Cadastre o edital em '
                    '"Editar edital" ou toque numa matéria recolhida.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Cores.tintaSuave, fontSize: 15),
                  ),
                ),
              Positioned(
                left: 16,
                bottom: 16,
                child: SafeArea(
                  child: _Legenda(
                    aberta: _legendaAberta,
                    aoAlternar: () {
                      setState(() => _legendaAberta = !_legendaAberta);
                      _salvarPrefs();
                    },
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BotaoMapa(
                        icone: Icons.add_rounded,
                        dica: 'Aproximar',
                        aoTocar: () => _zoom(1.5),
                      ),
                      const SizedBox(height: 10),
                      _BotaoMapa(
                        icone: Icons.remove_rounded,
                        dica: 'Afastar',
                        aoTocar: () => _zoom(1 / 1.5),
                      ),
                      const SizedBox(height: 18),
                      _BotaoMapa(
                        icone: Icons.center_focus_strong_rounded,
                        dica: 'Centralizar',
                        aoTocar: _centralizar,
                      ),
                      const SizedBox(height: 10),
                      _BotaoMapa(
                        icone: Icons.fit_screen_rounded,
                        dica: 'Ajustar à tela',
                        aoTocar: _ajustar,
                      ),
                    ],
                  ),
                ),
              ),
              if (_detalhe != null) ...[
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (_) => setState(() => _detalhe = null),
                  ),
                ),
                _cartaoDetalhe(_detalhe!, box.biggest),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _cartaoDetalhe(_Detalhe d, Size tela) {
    const largura = 320.0;
    final x = (d.posicao.dx - largura / 2)
        .clamp(12.0, math.max(12.0, tela.width - largura - 12))
        .toDouble();
    final emCima = d.posicao.dy > tela.height / 2;
    final n = d.no;
    final materia = n.no.materiaId == null ? null : _materias[n.no.materiaId];
    final cartao = _ResumoNo(
      no: n,
      materia: materia,
      infoMateria: _porMateria[n.no.id],
      aoAbrirTopico: () => _abrirTopico(n.no.id),
      aoAlternar: n.no.tipo == TipoNo.materia && n.profundidade > 0
          ? () => _alternar(n)
          : null,
      aoFiltrar: n.no.tipo == TipoNo.materia
          ? () => _filtrar(n.profundidade == 0 ? null : n.no.id)
          : null,
      central: n.profundidade == 0,
    );
    return Positioned(
      left: x,
      width: math.min(largura, tela.width - 24),
      top: emCima ? null : d.posicao.dy + 20,
      bottom: emCima ? tela.height - d.posicao.dy + 20 : null,
      child: cartao,
    );
  }
}

class _Detalhe {
  const _Detalhe(this.no, this.posicao);
  final NoPosicionado no;

  /// Onde o dedo estava, em coordenadas da tela do mapa.
  final Offset posicao;
}

/// Resumo rápido ao segurar o dedo num nó.
class _ResumoNo extends StatelessWidget {
  const _ResumoNo({
    required this.no,
    required this.materia,
    required this.infoMateria,
    required this.aoAbrirTopico,
    required this.aoAlternar,
    required this.aoFiltrar,
    required this.central,
  });

  final NoPosicionado no;
  final MateriaMapa? materia;
  final InfoTopico? infoMateria;
  final VoidCallback aoAbrirTopico;
  final VoidCallback? aoAlternar;
  final VoidCallback? aoFiltrar;
  final bool central;

  @override
  Widget build(BuildContext context) {
    final n = no.no;
    final ehTopico = n.tipo == TipoNo.topico || n.tipo == TipoNo.subtopico;
    final ehMateria = n.tipo == TipoNo.materia;
    // Matéria: horas e questões de todas as sessões dela (inclusive sem
    // tópico); tópico: dele e dos subtópicos.
    final info = ehMateria ? (infoMateria ?? InfoTopico()) : n.info;
    final cabecalho = switch (n.tipo) {
      TipoNo.raiz => 'EDITAL',
      TipoNo.materia => 'MATÉRIA',
      TipoNo.topico => materia?.nome.toUpperCase() ?? 'TÓPICO',
      TipoNo.subtopico => '${materia?.nome.toUpperCase() ?? ''} · SUBTÓPICO',
    };
    final hoje = soDia(DateTime.now());
    final rev = n.info.proximaRevisao;
    final (textoRev, corRev) = rev == null
        ? ('Nenhuma pendente', null)
        : rev.isBefore(hoje)
        ? ('Atrasada desde ${dataCurta(rev)}', Cores.acento)
        : soDia(rev) == hoje
        ? ('Hoje', null)
        : (dataCurta(rev), null);
    final acerto = info.acerto;

    return Material(
      color: Cores.fundo,
      elevation: 10,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Cores.linha, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (n.tipo != TipoNo.raiz) ...[
                  Bolinha(Color(n.cor), tamanho: 10),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    cabecalho,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: Cores.tintaSuave,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              n.rotulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            if (!ehTopico)
              _Linha(
                Icons.check_circle_outline_rounded,
                'Tópicos vistos',
                '${n.folhasVistas} de ${n.folhas} '
                    '(${(n.progresso * 100).round()}%)',
              )
            else
              _Linha(
                Icons.check_circle_outline_rounded,
                'Situação',
                switch (n.visto) {
                  Visto.sim => 'Visto',
                  Visto.parte => 'Visto em parte',
                  Visto.nao => 'Não visto',
                },
              ),
            _Linha(
              Icons.timer_outlined,
              'Horas estudadas',
              info.minutos == 0 ? '—' : minutosFmt(info.minutos),
            ),
            _Linha(
              Icons.percent_rounded,
              'Acerto',
              acerto == null
                  ? 'Sem questões'
                  : '${(acerto * 100).round()}% '
                        '(${info.acertos} de ${info.feitas})',
              cor: info.acertoBaixo ? corAcertoBaixo : null,
            ),
            _Linha(
              Icons.event_repeat_rounded,
              'Próxima revisão',
              textoRev,
              cor: corRev,
            ),
            _Linha(Icons.style_outlined, 'Flashcards', '${n.info.flashcards}'),
            const SizedBox(height: 10),
            if (ehTopico)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: aoAbrirTopico,
                  icon: const Icon(Icons.open_in_new_rounded, size: 20),
                  label: const Text('Abrir tópico'),
                ),
              ),
            if (ehMateria)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (aoAlternar != null)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: aoAlternar,
                      child: Text(n.ocultos > 0 ? 'Expandir' : 'Recolher'),
                    ),
                  if (aoFiltrar != null)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: aoFiltrar,
                      child: Text(
                        central ? 'Ver edital inteiro' : 'Ver só esta',
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.icone, this.rotulo, this.valor, {this.cor});
  final IconData icone;
  final String rotulo;
  final String valor;
  final Color? cor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icone, size: 18, color: Cores.tintaSuave),
        const SizedBox(width: 10),
        Text(rotulo, style: const TextStyle(color: Cores.tintaSuave)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            valor,
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.w700, color: cor),
          ),
        ),
      ],
    ),
  );
}

class _SeletorFiltro extends StatelessWidget {
  const _SeletorFiltro({
    required this.materias,
    required this.extra,
    required this.filtro,
    required this.aoEscolher,
  });

  final List<MateriaInfo> materias;

  /// Matéria no centro que não é do escopo atual.
  final NoMapa? extra;
  final String? filtro;
  final ValueChanged<String?> aoEscolher;

  @override
  Widget build(BuildContext context) {
    String nome(String id) {
      for (final m in materias) {
        if (m.materia.id == id) return m.materia.nome;
      }
      return extra?.rotulo ?? '';
    }

    final largo = MediaQuery.sizeOf(context).width >= 600;
    return PopupMenuButton<String>(
      tooltip: 'Ver uma matéria só ou o edital inteiro',
      position: PopupMenuPosition.under,
      onSelected: (v) => aoEscolher(v == '*' ? null : v),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: '*',
          height: 52,
          child: Row(
            children: [
              const Icon(Icons.hub_outlined, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Edital inteiro', style: TextStyle(fontSize: 16)),
              ),
              if (filtro == null) const Icon(Icons.check_rounded, size: 20),
            ],
          ),
        ),
        const PopupMenuDivider(),
        for (final m in materias)
          PopupMenuItem(
            value: m.materia.id,
            height: 52,
            child: Row(
              children: [
                Bolinha(Color(m.materia.cor)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m.materia.nome,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                if (filtro == m.materia.id)
                  const Icon(Icons.check_rounded, size: 20)
                else
                  Text(
                    '${(m.progresso * 100).round()}%',
                    style: const TextStyle(color: Cores.tintaSuave),
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        constraints: BoxConstraints(maxWidth: largo ? 280 : 150),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Cores.fundo,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Cores.linha, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list_rounded, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                filtro == null ? 'Edital inteiro' : nome(filtro!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _BotaoMapa extends StatelessWidget {
  const _BotaoMapa({
    required this.icone,
    required this.dica,
    required this.aoTocar,
  });
  final IconData icone;
  final String dica;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: dica,
    child: Material(
      color: Cores.fundo,
      elevation: 3,
      shadowColor: const Color(0x33000000),
      shape: const CircleBorder(
        side: BorderSide(color: Cores.linha, width: 1.5),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: aoTocar,
        child: SizedBox.square(dimension: 52, child: Icon(icone, size: 24)),
      ),
    ),
  );
}

/// Legenda recolhível do canto da tela.
class _Legenda extends StatelessWidget {
  const _Legenda({required this.aberta, required this.aoAlternar});
  final bool aberta;
  final VoidCallback aoAlternar;

  @override
  Widget build(BuildContext context) {
    final exemplo = Color(Cores.paleta.first);
    Widget item(Widget amostra, String texto) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 34, height: 20, child: Center(child: amostra)),
          const SizedBox(width: 10),
          Flexible(child: Text(texto, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
    Widget caixa(Color fundo, {Color? borda, double larguraBorda = 3}) =>
        Container(
          width: 32,
          height: 18,
          decoration: BoxDecoration(
            color: fundo,
            borderRadius: BorderRadius.circular(7),
            border: borda == null
                ? Border.all(color: Cores.linha)
                : Border.all(color: borda, width: larguraBorda),
          ),
        );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: math.min(300, MediaQuery.sizeOf(context).width - 110),
      ),
      child: Material(
        color: Cores.fundo.withValues(alpha: 0.96),
        elevation: 3,
        shadowColor: const Color(0x33000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Cores.linha, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: aoAlternar,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 10, aberta ? 12 : 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.palette_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Legenda',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      aberta
                          ? Icons.expand_more_rounded
                          : Icons.expand_less_rounded,
                      size: 22,
                    ),
                  ],
                ),
                if (aberta) ...[
                  const SizedBox(height: 6),
                  item(caixa(corNaoVisto), 'Não visto'),
                  item(caixa(corEmParte(exemplo)), 'Visto em parte'),
                  item(caixa(exemplo), 'Visto (cor da matéria)'),
                  item(caixa(exemplo, borda: Cores.acento), 'Revisão atrasada'),
                  item(
                    caixa(corNaoVisto, borda: corAcertoBaixo),
                    'Acerto abaixo de 60% (10+ questões)',
                  ),
                  item(
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        width: 32,
                        height: 6,
                        child: LinearProgressIndicator(
                          value: 0.6,
                          color: exemplo,
                          backgroundColor: exemplo.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                    'Matéria: % de tópicos vistos',
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Toque na matéria para recolher.\n'
                    'Segure o dedo para ver detalhes.',
                    style: TextStyle(fontSize: 12.5, color: Cores.tintaSuave),
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
