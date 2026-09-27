import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/mapa_conteudo_db.dart';
import '../logic/mapa_conteudo.dart';
import '../logic/mapa_mental.dart';
import '../theme.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import '../widgets/escopo.dart';
import '../widgets/mapa_painter.dart';
import 'colar_mapa_screen.dart';

/// Ícone de cada tipo de nó.
IconData iconeDoTipo(TipoNoConteudo t) => switch (t) {
  TipoNoConteudo.conceito => Icons.label_outline_rounded,
  TipoNoConteudo.artigo => Icons.gavel_rounded,
  TipoNoConteudo.exemplo => Icons.format_quote_rounded,
  TipoNoConteudo.pegadinha => Icons.warning_amber_rounded,
  TipoNoConteudo.dica => Icons.lightbulb_outline_rounded,
};

/// Ícone colorido do tipo (prévia, detalhe e legenda).
class IconeTipo extends StatelessWidget {
  const IconeTipo(this.tipo, {super.key, this.tamanho = 20});
  final TipoNoConteudo tipo;
  final double tamanho;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tipo.rotulo,
    child: Icon(iconeDoTipo(tipo), size: tamanho, color: Color(tipo.cor)),
  );
}

const _margem = 400.0;
const _escalaMax = 3.0;

/// Mapa do conteúdo de um tópico: o título no centro e os nós em balões
/// (o mesmo layout do mapa mental). Tocar num nó mostra o detalhe; no
/// "Modo treino" os nós a partir do 2º nível ficam cobertos e o toque
/// revela um por um.
class MapaConteudoScreen extends StatefulWidget {
  const MapaConteudoScreen({super.key, required this.topicoId});
  final String topicoId;

  @override
  State<MapaConteudoScreen> createState() => MapaConteudoScreenState();
}

class MapaConteudoScreenState extends State<MapaConteudoScreen>
    with SingleTickerProviderStateMixin {
  final _tc = TransformationController();
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  Animation<Matrix4>? _animMatriz;
  final _limite = ValueNotifier<double>(0);
  final _pilha = GlobalKey();

  MapaSalvo? _mapa;
  CacheMapa? _cache;
  Map<String, NoConteudo> _nos = {};
  Size _tamanhoCanvas = Size.zero;
  Size _viewport = Size.zero;
  bool _ajustarPendente = true;

  String? _selecionado;
  bool _treino = false;
  Set<String> _revelados = {};

  @override
  void initState() {
    super.initState();
    _tc.addListener(() => _limite.value = limiteFonte(_escala));
    _anim.addListener(() {
      final a = _animMatriz;
      if (a != null) _tc.value = a.value;
    });
  }

  @override
  void dispose() {
    _tc.dispose();
    _anim.dispose();
    _limite.dispose();
    _cache?.descartar();
    super.dispose();
  }

  double get _escala => _tc.value.getMaxScaleOnAxis();

  /// Nós cobertos agora (modo treino): 2º nível em diante, não revelados.
  Set<String> get cobertos => !_treino
      ? const {}
      : {
          for (final id in _nos.keys)
            if (nivelDoId(id) >= 2 && !_revelados.contains(id)) id,
        };

  @visibleForTesting
  bool get treino => _treino;

  @visibleForTesting
  String? get selecionado => _selecionado;

  /// Centro do nó [id] na tela (coordenadas globais), para os testes.
  @visibleForTesting
  Offset? posicaoGlobal(String id) {
    final c = _cache;
    final n = c?.layout.porId(id);
    final caixa = _pilha.currentContext?.findRenderObject() as RenderBox?;
    if (c == null || n == null || caixa == null) return null;
    return caixa.localToGlobal(
      MatrixUtils.transformPoint(_tc.value, n.centro + c.origem),
    );
  }

  void _atualizar(MapaSalvo? m) {
    if (identical(m?.linha, _mapa?.linha) || m?.linha == _mapa?.linha) return;
    _mapa = m;
    _cache?.descartar();
    _cache = null;
    _nos = {};
    if (m == null) return;
    final nos = <String, NoConteudo>{};
    final layout = calcularLayout(
      arvoreDoConteudo(m.titulo, m.nos, nosPorId: nos),
    );
    _nos = nos;
    final origem = -layout.limites.topLeft + const Offset(_margem, _margem);
    _cache = CacheMapa(layout, origem);
    _tamanhoCanvas = layout.limites.size + const Offset(_margem, _margem) * 2;
    _ajustarPendente = true;
    _revelados = {..._revelados.where(nos.containsKey)};
    if (_selecionado != null && !nos.containsKey(_selecionado)) {
      _selecionado = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Câmera
  // ---------------------------------------------------------------------------

  /// Área livre para o mapa: no modo treino, a barra ocupa o alto.
  Rect get _area {
    final r = Offset.zero & _viewport;
    return _treino ? Rect.fromLTRB(r.left, r.top + 72, r.right, r.bottom) : r;
  }

  double get _escalaAjuste {
    final c = _cache;
    if (c == null || _viewport.isEmpty) return 1;
    final l = c.layout.limites;
    return math.min(
          _area.width / (l.width + 48),
          _area.height / (l.height + 48),
        ) *
        0.94;
  }

  double get _escalaMin => math.min(0.3, _escalaAjuste * 0.6);

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

  void _ajustar({bool animado = true}) {
    final c = _cache;
    if (c == null || _viewport.isEmpty) return;
    _irPara(
      _matriz(
        // No celular, um zoom em que o texto ainda aparece (arrasta-se
        // para os lados); no tablet, o mapa inteiro.
        _escalaAjuste.clamp(_viewport.width < 600 ? 0.46 : 0.05, 1.3),
        c.layout.limites.center + c.origem,
        _area.center,
      ),
      animado: animado,
    );
  }

  void _zoom(double fator) {
    final e = (_escala * fator).clamp(_escalaMin, _escalaMax);
    final f = e / _escala;
    final c = _viewport.center(Offset.zero);
    _irPara(
      Matrix4.translationValues(c.dx, c.dy, 0)
        ..multiply(Matrix4.diagonal3Values(f, f, f))
        ..multiply(Matrix4.translationValues(-c.dx, -c.dy, 0))
        ..multiply(_tc.value),
    );
  }

  // ---------------------------------------------------------------------------
  // Toques e ações
  // ---------------------------------------------------------------------------

  void _tocar(Offset canvas) {
    final c = _cache;
    if (c == null) return;
    final n = c.layout.noEm(canvas - c.origem, folga: 6);
    setState(() {
      if (n == null || n.profundidade == 0) {
        _selecionado = null;
        return;
      }
      final id = n.no.id;
      if (cobertos.contains(id)) {
        _revelados = {..._revelados, id};
      }
      _selecionado = id;
    });
  }

  void _alternarTreino() {
    setState(() {
      _treino = !_treino;
      _revelados = {};
      _selecionado = null;
    });
    // Reenquadra: no treino, abaixo da barra.
    _ajustar();
  }

  void _revelarTudo() => setState(() => _revelados = {..._nos.keys});

  void _cobrir() => setState(() {
    _revelados = {};
    _selecionado = null;
  });

  Future<void> _excluir() async {
    final ok = await confirmar(
      context,
      titulo: 'Excluir o mapa?',
      mensagem:
          'O mapa do conteúdo deste tópico sai de todos os aparelhos. '
          'O tópico, as questões e os flashcards continuam.',
    );
    if (!ok || !mounted) return;
    await context.read<AppDatabase>().excluirMapa(widget.topicoId);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _colarNovo() async {
    final db = context.read<AppDatabase>();
    final t = await db.topico(widget.topicoId);
    final m = t == null ? null : await db.watchMateria(t.materiaId).first;
    if (t == null || m == null || !mounted) return;
    final escopo = await escopoAtual(context).first;
    if (!mounted) return;
    await abrirColarMapa(context, materia: m, topico: t, concursoId: escopo);
  }

  // ---------------------------------------------------------------------------
  // Tela
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<MapaSalvo?>(
      chave: ('mapa', widget.topicoId),
      stream: () => db.watchMapa(widget.topicoId),
      builder: (context, m) {
        _atualizar(m);
        final cache = _cache;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 72,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mapa do conteúdo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (m != null)
                  Text(
                    m.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Cores.tintaSuave,
                    ),
                  ),
              ],
            ),
            actions: [
              if (m != null)
                _BotaoTreino(ligado: _treino, aoTocar: _alternarTreino),
              PopupMenuButton<String>(
                tooltip: 'Mais opções',
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (v) => v == 'excluir' ? _excluir() : _colarNovo(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'colar',
                    height: 52,
                    child: Text(m == null ? 'Colar mapa' : 'Colar novo mapa'),
                  ),
                  if (m != null)
                    const PopupMenuItem(
                      key: ValueKey('excluir-mapa'),
                      value: 'excluir',
                      height: 52,
                      child: Text(
                        'Excluir mapa',
                        style: TextStyle(color: Cores.acento),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: m == null || cache == null
              ? _vazio()
              : LayoutBuilder(
                  builder: (context, box) {
                    _viewport = box.biggest;
                    if (_ajustarPendente) {
                      _ajustarPendente = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _ajustar(animado: false);
                      });
                    }
                    final sel = _selecionado == null
                        ? null
                        : _nos[_selecionado];
                    return Stack(
                      key: _pilha,
                      children: [
                        Positioned.fill(
                          child: ColoredBox(
                            color: Cores.fundo,
                            child: InteractiveViewer(
                              transformationController: _tc,
                              constrained: false,
                              boundaryMargin: const EdgeInsets.all(
                                double.infinity,
                              ),
                              minScale: _escalaMin,
                              maxScale: _escalaMax,
                              onInteractionStart: (_) => _anim.stop(),
                              child: GestureDetector(
                                onTapUp: (d) => _tocar(d.localPosition),
                                child: CustomPaint(
                                  size: _tamanhoCanvas,
                                  painter: MapaConteudoPainter(
                                    cache: cache,
                                    limite: _limite,
                                    nos: _nos,
                                    cobertos: cobertos,
                                    selecionado: _selecionado,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_treino)
                          Positioned(
                            left: 16,
                            top: 12,
                            right: 16,
                            child: _BarraTreino(
                              faltam: cobertos.length,
                              aoRevelar: _revelarTudo,
                              aoCobrir: _cobrir,
                            ),
                          ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _BotaoRedondo(
                                  icone: Icons.add_rounded,
                                  dica: 'Aproximar',
                                  aoTocar: () => _zoom(1.5),
                                ),
                                const SizedBox(height: 10),
                                _BotaoRedondo(
                                  icone: Icons.remove_rounded,
                                  dica: 'Afastar',
                                  aoTocar: () => _zoom(1 / 1.5),
                                ),
                                const SizedBox(height: 18),
                                _BotaoRedondo(
                                  icone: Icons.fit_screen_rounded,
                                  dica: 'Ajustar à tela',
                                  aoTocar: _ajustar,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 84,
                          bottom: 16,
                          child: SafeArea(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: sel == null
                                  ? const _Legenda()
                                  : _Detalhe(
                                      no: sel,
                                      aoFechar: () =>
                                          setState(() => _selecionado = null),
                                    ),
                            ),
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

  Widget _vazio() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_tree_outlined,
            size: 48,
            color: Cores.tintaSuave,
          ),
          const SizedBox(height: 12),
          const Text(
            'Este tópico ainda não tem mapa do conteúdo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Cores.tintaSuave),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _colarNovo,
            icon: const Icon(Icons.content_paste_rounded),
            label: const Text('Colar mapa'),
          ),
        ],
      ),
    ),
  );
}

class _BotaoTreino extends StatelessWidget {
  const _BotaoTreino({required this.ligado, required this.aoTocar});
  final bool ligado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final largo = MediaQuery.sizeOf(context).width >= 600;
    final cor = ligado ? Colors.white : Cores.tinta;
    return Tooltip(
      message: ligado ? 'Sair do modo treino' : 'Modo treino',
      child: Material(
        color: ligado ? Cores.tinta : Cores.fundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Cores.tinta, width: 1.5),
        ),
        child: InkWell(
          key: const ValueKey('modo-treino'),
          borderRadius: BorderRadius.circular(14),
          onTap: aoTocar,
          child: Container(
            height: 48,
            constraints: const BoxConstraints(minWidth: 48),
            padding: EdgeInsets.symmetric(horizontal: largo ? 14 : 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology_alt_outlined, size: 20, color: cor),
                if (largo) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Modo treino',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cor,
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

class _BarraTreino extends StatelessWidget {
  const _BarraTreino({
    required this.faltam,
    required this.aoRevelar,
    required this.aoCobrir,
  });
  final int faltam;
  final VoidCallback aoRevelar;
  final VoidCallback aoCobrir;

  @override
  Widget build(BuildContext context) => Center(
    child: Material(
      color: Cores.fundo,
      elevation: 4,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Cores.linha, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              faltam == 0
                  ? 'Tudo revelado'
                  : 'Lembre e toque para revelar · faltam $faltam',
              key: const ValueKey('faltam-treino'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            TextButton.icon(
              key: const ValueKey('revelar-tudo'),
              onPressed: aoRevelar,
              icon: const Icon(Icons.visibility_outlined, size: 20),
              label: const Text('Revelar tudo'),
            ),
            TextButton.icon(
              key: const ValueKey('cobrir-de-novo'),
              onPressed: aoCobrir,
              icon: const Icon(Icons.visibility_off_outlined, size: 20),
              label: const Text('Cobrir de novo'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Detalhe extends StatelessWidget {
  const _Detalhe({required this.no, required this.aoFechar});
  final NoConteudo no;
  final VoidCallback aoFechar;

  @override
  Widget build(BuildContext context) {
    final cor = Color(no.tipo.cor);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Material(
        key: const ValueKey('detalhe-no'),
        color: Cores.fundo,
        elevation: 6,
        shadowColor: const Color(0x33000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: cor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 6, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconeTipo(no.tipo, tamanho: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      no.tipo.rotulo.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: cor,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: aoFechar,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      no.texto,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    if (no.detalhe.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        no.detalhe,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ],
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

class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) => Material(
    color: Cores.fundo.withValues(alpha: 0.94),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Cores.linha, width: 1.5),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          for (final t in TipoNoConteudo.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconeTipo(t, tamanho: 16),
                const SizedBox(width: 4),
                Text(t.rotulo, style: const TextStyle(fontSize: 13)),
              ],
            ),
        ],
      ),
    ),
  );
}

class _BotaoRedondo extends StatelessWidget {
  const _BotaoRedondo({
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

/// Desenho do mapa do conteúdo: título preto no centro; cada nó com a cor
/// e o ícone do tipo (pegadinha em vermelho, com borda mais grossa). No
/// modo treino, os cobertos ficam cinza, com "?".
class MapaConteudoPainter extends CustomPainter {
  MapaConteudoPainter({
    required this.cache,
    required this.limite,
    required this.nos,
    required this.cobertos,
    required this.selecionado,
  }) : super(repaint: limite);

  final CacheMapa cache;
  final ValueListenable<double> limite;
  final Map<String, NoConteudo> nos;
  final Set<String> cobertos;
  final String? selecionado;

  static final _icones = <(IconData, int), TextPainter>{};

  static TextPainter _icone(IconData i, Color cor, double tamanho) =>
      _icones.putIfAbsent(
        (i, cor.toARGB32()),
        () => TextPainter(
          text: TextSpan(
            text: String.fromCharCode(i.codePoint),
            style: TextStyle(
              fontFamily: i.fontFamily,
              package: i.fontPackage,
              fontSize: tamanho,
              color: cor,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
      );

  @override
  void paint(Canvas canvas, Size size) {
    final o = cache.origem;
    final linha = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final l in cache.layout.ligacoes) {
      final coberto = cobertos.contains(l.filho.no.id);
      final path = Path()..addPolygon([for (final p in l.pontos) p + o], false);
      canvas.drawPath(
        path,
        linha
          ..color = coberto
              ? Cores.tintaFraca
              : Color(l.filho.no.cor).withValues(alpha: 0.6)
          ..strokeWidth = l.filho.profundidade <= 1 ? 3 : 2,
      );
    }
    final minFonte = limite.value;
    for (final n in cache.layout.nos) {
      _no(canvas, n, n.retangulo.shift(o), fonteDoNo(n) >= minFonte);
    }
  }

  void _no(Canvas canvas, NoPosicionado n, Rect r, bool comTexto) {
    if (n.profundidade == 0) {
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(26));
      canvas.drawRRect(rr, Paint()..color = Cores.tinta);
      if (comTexto) _texto(canvas, n, r.deflate(14), Colors.white, 3);
      return;
    }
    final id = n.no.id;
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(14));
    if (cobertos.contains(id)) {
      canvas.drawRRect(rr, Paint()..color = const Color(0xFFEDEDED));
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Cores.tintaFraca,
      );
      final q = _icone(Icons.help_outline_rounded, Cores.tintaSuave, 20);
      q.paint(canvas, r.center - Offset(q.width / 2, q.height / 2));
      return;
    }
    final tipo = nos[id]?.tipo ?? TipoNoConteudo.conceito;
    final cor = Color(tipo.cor);
    canvas.drawRRect(
      rr,
      Paint()
        ..color = Color.alphaBlend(cor.withValues(alpha: 0.13), Cores.fundo),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = tipo == TipoNoConteudo.pegadinha ? 3 : 1.8
        ..color = cor,
    );
    if (id == selecionado) {
      canvas.drawRRect(
        rr.inflate(5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = Cores.tinta,
      );
    }
    if (!comTexto) return;
    final ic = _icone(iconeDoTipo(tipo), cor, 13);
    ic.paint(canvas, Offset(r.left + 6, r.top + 5));
    _texto(
      canvas,
      n,
      Rect.fromLTRB(r.left + 20, r.top + 3, r.right - 6, r.bottom - 3),
      Cores.tinta,
      3,
    );
  }

  void _texto(
    Canvas canvas,
    NoPosicionado n,
    Rect area,
    Color cor,
    int linhas,
  ) {
    final tp = cache.texto(n, area.width, cor, linhas);
    tp.paint(
      canvas,
      Offset(area.center.dx - tp.width / 2, area.center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(MapaConteudoPainter old) =>
      old.cache != cache ||
      old.limite != limite ||
      !setEquals(old.cobertos, cobertos) ||
      old.selecionado != selecionado;
}

/// Abre o mapa do conteúdo do tópico.
Future<void> abrirMapaConteudo(BuildContext context, String topicoId) =>
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapaConteudoScreen(topicoId: topicoId)),
    );
