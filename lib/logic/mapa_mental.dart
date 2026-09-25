/// Mapa mental do edital: montagem da árvore (matéria → tópico → subtópico)
/// e cálculo do layout radial. Tudo puro, sem banco e sem widgets, para
/// poder testar.
library;

import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

enum TipoNo { raiz, materia, topico, subtopico }

/// Situação de estudo de um tópico, para o "mapa de calor".
enum Visto { nao, parte, sim }

/// Números de um tópico usados pela situação e pelo resumo rápido.
class InfoTopico {
  InfoTopico({
    this.minutos = 0,
    this.feitas = 0,
    this.acertos = 0,
    this.proximaRevisao,
    this.flashcards = 0,
  });

  int minutos;
  int feitas;
  int acertos;

  /// Revisão pendente mais antiga (pode estar no passado = atrasada).
  DateTime? proximaRevisao;
  int flashcards;

  double? get acerto => feitas == 0 ? null : acertos / feitas;

  /// Abaixo de 60% com pelo menos 10 questões.
  bool get acertoBaixo => feitas >= 10 && acertos / feitas < 0.6;

  void somar(InfoTopico o) {
    minutos += o.minutos;
    feitas += o.feitas;
    acertos += o.acertos;
    flashcards += o.flashcards;
    final r = o.proximaRevisao;
    if (r != null && (proximaRevisao == null || r.isBefore(proximaRevisao!))) {
      proximaRevisao = r;
    }
  }
}

class NoMapa {
  NoMapa({
    required this.id,
    required this.tipo,
    required this.rotulo,
    required this.cor,
    this.materiaId,
    List<NoMapa>? filhos,
    this.visto = Visto.nao,
    this.atrasada = false,
    this.acertoBaixo = false,
    this.progresso = 0,
    this.folhasVistas = 0,
    this.folhas = 0,
    this.ocultos = 0,
    InfoTopico? info,
  }) : filhos = filhos ?? [],
       info = info ?? InfoTopico();

  /// Id do tópico ou da matéria ('raiz' no centro do edital inteiro).
  final String id;
  final TipoNo tipo;
  final String rotulo;
  final int cor;
  final String? materiaId;
  final List<NoMapa> filhos;

  final Visto visto;

  /// Revisão do próprio tópico vencida antes de hoje.
  final bool atrasada;
  final bool acertoBaixo;

  /// Matéria: fração de tópicos-folha vistos.
  final double progresso;
  final int folhasVistas;
  final int folhas;

  /// Matéria recolhida: quantos tópicos ficaram escondidos.
  final int ocultos;

  /// Soma do tópico com os subtópicos (ou da matéria inteira).
  final InfoTopico info;
}

class MateriaMapa {
  const MateriaMapa(this.id, this.nome, this.cor);
  final String id;
  final String nome;
  final int cor;
}

class TopicoMapa {
  const TopicoMapa({
    required this.id,
    required this.materiaId,
    required this.paiId,
    required this.nome,
    required this.visto,
    this.ordem = 0,
  });
  final String id;
  final String materiaId;
  final String? paiId;
  final String nome;
  final bool visto;
  final int ordem;
}

/// Monta a árvore visível. [info] traz os números de cada tópico (só dele,
/// sem os filhos). Com [materiaCentral], a matéria vai para o centro.
NoMapa montarArvore({
  required String rotuloRaiz,
  required List<MateriaMapa> materias,
  required List<TopicoMapa> topicos,
  Map<String, InfoTopico> info = const {},
  Set<String> recolhidas = const {},
  String? materiaCentral,
  required DateTime hoje,
}) {
  final hojeDia = DateTime(hoje.year, hoje.month, hoje.day);
  final filhosDe = <String?, List<TopicoMapa>>{};
  final raizesDe = <String, List<TopicoMapa>>{};
  for (final t in topicos) {
    if (t.paiId == null) {
      (raizesDe[t.materiaId] ??= []).add(t);
    } else {
      (filhosDe[t.paiId] ??= []).add(t);
    }
  }
  int porOrdem(TopicoMapa a, TopicoMapa b) => a.ordem.compareTo(b.ordem);
  for (final l in filhosDe.values) {
    l.sort(porOrdem);
  }
  for (final l in raizesDe.values) {
    l.sort(porOrdem);
  }

  // Devolve (nó, folhas, folhas vistas).
  (NoMapa, int, int) topico(TopicoMapa t, int cor, int prof, Set<String> vis) {
    if (!vis.add(t.id)) {
      // Ciclo nos dados (não deveria acontecer): corta aqui.
      return (
        NoMapa(id: t.id, tipo: TipoNo.subtopico, rotulo: t.nome, cor: cor),
        0,
        0,
      );
    }
    final filhos = <NoMapa>[];
    final soma = InfoTopico()..somar(info[t.id] ?? InfoTopico());
    var folhas = 0, vistas = 0;
    for (final f in filhosDe[t.id] ?? const <TopicoMapa>[]) {
      final (n, fo, vi) = topico(f, cor, prof + 1, vis);
      filhos.add(n);
      soma.somar(n.info);
      folhas += fo;
      vistas += vi;
    }
    if (filhos.isEmpty) {
      folhas = 1;
      vistas = t.visto ? 1 : 0;
    }
    // Estudado (tempo registrado) mas ainda não marcado conta como "em parte".
    final visto = t.visto || (folhas > 0 && vistas == folhas)
        ? Visto.sim
        : vistas > 0 || soma.minutos > 0
        ? Visto.parte
        : Visto.nao;
    final propria = info[t.id]?.proximaRevisao;
    return (
      NoMapa(
        id: t.id,
        tipo: prof == 0 ? TipoNo.topico : TipoNo.subtopico,
        rotulo: t.nome,
        cor: cor,
        materiaId: t.materiaId,
        filhos: filhos,
        visto: visto,
        atrasada: propria != null && propria.isBefore(hojeDia),
        acertoBaixo: soma.acertoBaixo,
        folhas: folhas,
        folhasVistas: vistas,
        info: soma,
      ),
      folhas,
      vistas,
    );
  }

  NoMapa materia(MateriaMapa m, {required bool central}) {
    final nos = <NoMapa>[];
    final soma = InfoTopico();
    var folhas = 0, vistas = 0;
    final vis = <String>{};
    for (final t in raizesDe[m.id] ?? const <TopicoMapa>[]) {
      final (n, fo, vi) = topico(t, m.cor, 0, vis);
      nos.add(n);
      soma.somar(n.info);
      folhas += fo;
      vistas += vi;
    }
    final recolhida = !central && recolhidas.contains(m.id);
    return NoMapa(
      id: m.id,
      tipo: TipoNo.materia,
      rotulo: m.nome,
      cor: m.cor,
      materiaId: m.id,
      filhos: recolhida ? [] : nos,
      progresso: folhas == 0 ? 0 : vistas / folhas,
      folhas: folhas,
      folhasVistas: vistas,
      ocultos: recolhida ? nos.length : 0,
      acertoBaixo: soma.acertoBaixo,
      info: soma,
    );
  }

  if (materiaCentral != null) {
    for (final m in materias) {
      if (m.id == materiaCentral) return materia(m, central: true);
    }
  }
  final filhos = [for (final m in materias) materia(m, central: false)];
  final soma = InfoTopico();
  var folhas = 0, vistas = 0;
  for (final f in filhos) {
    soma.somar(f.info);
    folhas += f.folhas;
    vistas += f.folhasVistas;
  }
  return NoMapa(
    id: 'raiz',
    tipo: TipoNo.raiz,
    rotulo: rotuloRaiz,
    cor: 0xFF111111,
    filhos: filhos,
    progresso: folhas == 0 ? 0 : vistas / folhas,
    folhas: folhas,
    folhasVistas: vistas,
    info: soma,
  );
}

// -----------------------------------------------------------------------------
// Layout radial
// -----------------------------------------------------------------------------

/// Tamanho da caixa de cada tipo de nó (o texto quebra/abrevia para caber).
/// O nó do centro é sempre do tamanho da raiz.
Size tamanhoDoNo(TipoNo tipo, {bool centro = false}) {
  if (centro) return const Size(188, 80);
  return switch (tipo) {
    TipoNo.raiz => const Size(188, 80),
    TipoNo.materia => const Size(176, 70),
    TipoNo.topico => const Size(152, 52),
    TipoNo.subtopico => const Size(128, 44),
  };
}

class NoPosicionado {
  NoPosicionado(this.no, this.profundidade, this.pai);
  final NoMapa no;
  final int profundidade;
  final NoPosicionado? pai;
  final filhos = <NoPosicionado>[];

  /// Centro do "balão" em volta do qual o nó foi posto: a matéria, para
  /// tópicos e subtópicos; o centro do mapa, para as matérias.
  NoPosicionado? polo;

  /// Ângulo (radianos) e distância em relação ao [polo].
  double angulo = 0;
  double raio = 0;
  Offset centro = Offset.zero;
  Size get tamanho =>
      _tamanhoVao ?? tamanhoDoNo(no.tipo, centro: profundidade == 0);
  Rect get retangulo => Rect.fromCenter(
    center: centro,
    width: tamanho.width,
    height: tamanho.height,
  );

  /// Largura (radianos) do setor do ramo, proporcional às folhas dele.
  double get setor => _fatia;

  // Uso interno do layout.
  double _peso = 1;
  double _inicio = 0;
  double _fatia = 0;

  /// Vão livre por onde passa a linha que chega ao balão (não é desenhado).
  Size? _tamanhoVao;
}

/// Linha de um nó ao pai, como polilinha: a mesma usada para desenhar e
/// para conferir que ela não atravessa outros nós.
class Ligacao {
  Ligacao(this.pai, this.filho, this.pontos);
  final NoPosicionado pai;
  final NoPosicionado filho;
  final List<Offset> pontos;
}

class LayoutMapa {
  LayoutMapa(this.nos, this.ligacoes, this.limites);

  /// Em pré-ordem (raiz primeiro).
  final List<NoPosicionado> nos;
  final List<Ligacao> ligacoes;
  final Rect limites;

  NoPosicionado get raiz => nos.first;

  NoPosicionado? noEm(Offset p, {double folga = 4}) {
    for (var i = nos.length - 1; i >= 0; i--) {
      if (nos[i].retangulo.inflate(folga).contains(p)) return nos[i];
    }
    return null;
  }

  NoPosicionado? porId(String id) {
    for (final n in nos) {
      if (n.no.id == id) return n;
    }
    return null;
  }
}

/// Espaço mínimo entre caixas vizinhas no mesmo anel: cabe uma linha
/// passando entre elas, com folga.
const _folga = 22.0;
const _folgaRadial = 26.0;

/// Máximo de anéis concêntricos num mesmo nível (quando os nós não cabem
/// num anel só, eles se alternam entre raios diferentes, como tijolos).
const _maxEscalonamento = 8;

/// Folga entre uma linha e as caixas que ela não liga.
const margemLinha = 3.0;

/// Metade da projeção de uma caixa [s] na direção tangente ao ângulo [phi].
double _meiaTangente(Size s, double phi) =>
    s.width / 2 * math.sin(phi).abs() + s.height / 2 * math.cos(phi).abs();

double _meiaDiagonal(Size s) =>
    math.sqrt(s.width * s.width + s.height * s.height) / 2;

Offset _dir(double a) => Offset(math.cos(a), math.sin(a));

/// Layout em "balões". Cada matéria é o centro de um balão: os tópicos
/// ficam em volta dela, no círculo inteiro (360°), com ângulo proporcional
/// ao número de subtópicos de cada ramo; os subtópicos ficam para fora do
/// tópico, no mesmo setor. Quando os nós não cabem num anel, eles se
/// alternam entre anéis concêntricos. No edital inteiro, os balões das
/// matérias ficam em volta do centro, sem se tocar, e cada balão deixa um
/// vão livre na direção do centro para a linha que chega nele.
///
/// Garantias (conferidas no fim de cada balão, que cresce até cumpri-las):
/// nenhum nó se sobrepõe a outro e nenhuma linha atravessa um nó que não
/// seja a origem ou o destino dela.
LayoutMapa calcularLayout(NoMapa arvore) {
  final raiz = NoPosicionado(arvore, 0, null);
  final todos = <NoPosicionado>[raiz];
  void montar(NoPosicionado p) {
    for (final f in p.no.filhos) {
      final n = NoPosicionado(f, p.profundidade + 1, p);
      p.filhos.add(n);
      todos.add(n);
      montar(n);
    }
  }

  montar(raiz);

  if (arvore.tipo != TipoNo.raiz || raiz.filhos.isEmpty) {
    // Uma matéria no centro (ou só a raiz): um balão só.
    _balao(raiz, null);
  } else {
    _balaoDeBaloes(raiz);
  }

  final ligacoes = [
    for (final n in todos)
      if (n.pai != null) _ligacao(n.pai!, n),
  ];
  var limites = raiz.retangulo;
  for (final n in todos) {
    limites = limites.expandToInclude(n.retangulo);
  }
  return LayoutMapa(todos, ligacoes, limites);
}

/// Matérias em volta da raiz, cada uma com o seu balão.
void _balaoDeBaloes(NoPosicionado raiz) {
  final ms = raiz.filhos;
  for (final m in ms) {
    m.polo = raiz;
  }
  // 1) Tamanho aproximado de cada balão para repartir o círculo.
  final estimado = [for (final m in ms) _balao(m, math.pi / 2)];
  final soma = estimado.fold<double>(0, (a, b) => a + b);
  var a = -math.pi / 2 - estimado.first / soma * math.pi;
  for (var i = 0; i < ms.length; i++) {
    ms[i]._fatia = estimado[i] / soma * 2 * math.pi;
    ms[i].angulo = a + ms[i]._fatia / 2;
    a += ms[i]._fatia;
  }
  // 2) Balões de verdade, com o vão virado para o centro.
  final r = [for (final m in ms) _balao(m, m.angulo + math.pi)];

  // 3) Distância ao centro: balões sem se tocar, longe da raiz, e a linha
  // do centro até uma matéria sem passar por outro balão.
  final meiaRaiz = _meiaDiagonal(raiz.tamanho);
  var dist = 0.0;
  for (final ri in r) {
    dist = math.max(dist, meiaRaiz + ri + _folgaRadial);
  }
  bool cabe(double d) {
    for (var i = 0; i < ms.length; i++) {
      for (var j = i + 1; j < ms.length; j++) {
        var delta = (ms[i].angulo - ms[j].angulo).abs() % (2 * math.pi);
        if (delta > math.pi) delta = 2 * math.pi - delta;
        if (2 * d * math.sin(delta / 2) < r[i] + r[j] + _folgaRadial) {
          return false;
        }
        if (delta < math.pi / 2 &&
            d * math.sin(delta) < math.max(r[i], r[j]) + _folgaRadial) {
          return false;
        }
      }
    }
    return true;
  }

  for (var t = 0; t < 400 && !cabe(dist); t++) {
    dist *= 1.03;
  }
  // 4) Leva cada balão para o lugar.
  for (final m in ms) {
    m.raio = dist;
    final c = _dir(m.angulo) * dist;
    void mover(NoPosicionado n) {
      n.centro += c;
      for (final f in n.filhos) {
        mover(f);
      }
    }

    mover(m);
  }
}

/// Posiciona os descendentes de [polo] em anéis em volta dele, com o polo
/// na origem. [entrada] é a direção (radianos) por onde chega a linha do
/// nível de cima: ali fica um vão livre. Devolve o raio do balão.
double _balao(NoPosicionado polo, double? entrada) {
  polo.centro = Offset.zero;
  final niveis = <List<NoPosicionado>>[];
  void descer(NoPosicionado p, int d) {
    for (final f in p.filhos) {
      f.polo = polo;
      while (niveis.length < d) {
        niveis.add([]);
      }
      niveis[d - 1].add(f);
      descer(f, d + 1);
    }
  }

  descer(polo, 1);
  if (niveis.isEmpty) return _raioDoBalao([polo]);

  // Peso = folhas do ramo.
  double pesar(NoPosicionado n) {
    if (n.filhos.isEmpty) return n._peso = 1;
    var s = 0.0;
    for (final f in n.filhos) {
      s += pesar(f);
    }
    return n._peso = s;
  }

  var total = 0.0;
  for (final f in polo.filhos) {
    total += pesar(f);
  }

  // Setores angulares no círculo inteiro.
  NoPosicionado? vao;
  if (entrada != null) {
    vao = NoPosicionado(polo.no, 1, polo)
      .._tamanhoVao = const Size(30, 30)
      .._peso = math.max(1.0, total * 0.03);
  }
  final pesoTotal = total + (vao?._peso ?? 0);
  double a;
  if (vao != null) {
    vao._fatia = vao._peso / pesoTotal * 2 * math.pi;
    vao.angulo = entrada!;
    a = entrada + vao._fatia / 2;
  } else {
    a = -math.pi / 2 - polo.filhos.first._peso / pesoTotal * math.pi;
  }
  for (final f in polo.filhos) {
    f._fatia = f._peso / pesoTotal * 2 * math.pi;
    f._inicio = a;
    f.angulo = a + f._fatia / 2;
    a += f._fatia;
  }
  for (final nivel in niveis) {
    for (final n in nivel) {
      var b = n._inicio;
      final soma = n.filhos.fold<double>(0, (a, c) => a + c._peso);
      for (final c in n.filhos) {
        c._fatia = n._fatia * c._peso / soma;
        c._inicio = b;
        c.angulo = b + c._fatia / 2;
        b += c._fatia;
      }
    }
  }

  // Raios: anéis que não se tocam; dentro do anel, vizinhos separados.
  final aneis = [
    [?vao, ...niveis.first],
    ...niveis.skip(1),
  ];
  var externo = 0.0;
  var anterior = polo.tamanho;
  for (final nivel in aneis) {
    final tam = _maiorCaixa(nivel);
    final meiaDiag = _meiaDiagonal(tam);
    final sepAnel = _meiaDiagonal(anterior) + meiaDiag + _folgaRadial;
    final sepSub = 2 * meiaDiag + _folgaRadial;
    final minimo = externo + sepAnel;
    double? melhorR;
    var melhorK = 1;
    double? melhorExterno;
    final kMax = math.min(_maxEscalonamento, nivel.length);
    for (var k = 1; k <= kMax; k++) {
      final r = math.max(minimo, _raioTangencial(nivel, tam, k, sepSub));
      final ext = r + (k - 1) * sepSub;
      if (melhorExterno == null || ext < melhorExterno - 0.5) {
        melhorExterno = ext;
        melhorR = r;
        melhorK = k;
      }
    }
    _posicionar(nivel, melhorR!, melhorK, sepSub);
    externo = melhorExterno!;
    anterior = tam;
  }

  // Conferência: se algum nó encosta em outro ou alguma linha atravessa um
  // nó, os anéis a partir do nível do problema se afastam (os ângulos
  // ficam; só as distâncias aumentam, o que abre espaço até resolver).
  final reais = [polo, for (final l in niveis) ...l];
  int nivelDe(NoPosicionado n) => n.profundidade - polo.profundidade;
  for (var t = 0; t < 120; t++) {
    final ligs = [
      for (final n in reais)
        if (n != polo) _ligacao(n.pai!, n),
      if (entrada != null)
        Ligacao(polo, polo, [
          Offset.zero,
          _dir(entrada) * (_raioDoBalao(reais) + 40),
        ]),
    ];
    var desde = 1 << 30;
    for (final (a, b) in paresSobrepostos(reais)) {
      desde = math.min(desde, math.min(nivelDe(a), nivelDe(b)));
    }
    for (final (lig, no) in cruzamentosDe(ligs, reais)) {
      final f = lig.filho == polo ? no : lig.filho;
      desde = math.min(desde, math.min(nivelDe(no), nivelDe(f)));
    }
    if (desde == 1 << 30) break;
    desde = math.max(desde, 1);
    for (final n in reais) {
      if (nivelDe(n) < desde) continue;
      n.raio *= 1.06;
      n.centro = _dir(n.angulo) * n.raio;
    }
  }
  return _raioDoBalao(reais);
}

/// Distância do centro do balão ao canto mais longe de todas as caixas.
double _raioDoBalao(List<NoPosicionado> nos) {
  var r = 0.0;
  for (final n in nos) {
    final q = n.retangulo;
    for (final c in [q.topLeft, q.topRight, q.bottomLeft, q.bottomRight]) {
      r = math.max(r, (c - (n.polo?.centro ?? Offset.zero)).distance);
    }
  }
  return r;
}

/// Linha reta do pai até o nó (a mesma que é desenhada).
Ligacao _ligacao(NoPosicionado pai, NoPosicionado filho) =>
    Ligacao(pai, filho, [pai.centro, filho.centro]);

/// Pares (linha, nó) em que a linha atravessa um nó que não é nem a origem
/// nem o destino dela.
List<(Ligacao, NoPosicionado)> cruzamentos(LayoutMapa l) =>
    cruzamentosDe(l.ligacoes, l.nos);

List<(Ligacao, NoPosicionado)> cruzamentosDe(
  List<Ligacao> ligacoes,
  List<NoPosicionado> nos, {
  bool parar = false,
}) {
  final r = <(Ligacao, NoPosicionado)>[];
  for (final lig in ligacoes) {
    var caixa = Rect.fromPoints(lig.pontos.first, lig.pontos.first);
    for (final p in lig.pontos) {
      caixa = caixa.expandToInclude(Rect.fromPoints(p, p));
    }
    for (final n in nos) {
      if (identical(n, lig.pai) || identical(n, lig.filho)) continue;
      final q = n.retangulo.inflate(margemLinha);
      if (!q.overlaps(caixa.inflate(1))) continue;
      for (var i = 0; i + 1 < lig.pontos.length; i++) {
        if (_segmentoCruza(lig.pontos[i], lig.pontos[i + 1], q)) {
          r.add((lig, n));
          if (parar) return r;
          break;
        }
      }
    }
  }
  return r;
}

/// Liang–Barsky: o segmento [p]–[q] passa por dentro do retângulo [r]?
bool _segmentoCruza(Offset p, Offset q, Rect r) {
  var t0 = 0.0, t1 = 1.0;
  final dx = q.dx - p.dx, dy = q.dy - p.dy;
  bool corta(double pp, double qq) {
    if (pp == 0) return qq >= 0;
    final t = qq / pp;
    if (pp < 0) {
      if (t > t1) return false;
      if (t > t0) t0 = t;
    } else {
      if (t < t0) return false;
      if (t < t1) t1 = t;
    }
    return true;
  }

  return corta(-dx, p.dx - r.left) &&
      corta(dx, r.right - p.dx) &&
      corta(-dy, p.dy - r.top) &&
      corta(dy, r.bottom - p.dy) &&
      t0 <= t1;
}

Size _maiorCaixa(List<NoPosicionado> nivel) {
  var w = 0.0, h = 0.0;
  for (final n in nivel) {
    w = math.max(w, n.tamanho.width);
    h = math.max(h, n.tamanho.height);
  }
  return Size(w, h);
}

void _posicionar(List<NoPosicionado> nivel, double r, int k, double sepSub) {
  for (var i = 0; i < nivel.length; i++) {
    final n = nivel[i];
    n.raio = r + (i % k) * sepSub;
    n.centro = _dir(n.angulo) * n.raio;
  }
}

/// Menor raio em que nós do mesmo anel (a cada [k] nós) não se tocam.
double _raioTangencial(
  List<NoPosicionado> nivel,
  Size tam,
  int k,
  double sepSub,
) {
  var r = 0.0;
  for (var s = 0; s < k; s++) {
    final grupo = [for (var i = s; i < nivel.length; i += k) nivel[i]];
    if (grupo.length < 2) continue;
    for (var i = 0; i < grupo.length; i++) {
      final a = grupo[i];
      final b = grupo[(i + 1) % grupo.length];
      var delta = b.angulo - a.angulo;
      if (delta <= 0) delta += 2 * math.pi;
      if (delta >= 2 * math.pi - 1e-9) continue;
      final phi = a.angulo + delta / 2;
      final precisa = 2 * _meiaTangente(tam, phi) + _folga;
      // Anéis de fora têm raio maior: desconta o deslocamento.
      final rr = precisa / (2 * math.sin(delta / 2)) - s * sepSub;
      if (rr > r) r = rr;
    }
  }
  if (k == 1) return r;
  // Linhas entre anéis: a linha que chega num nó de um anel de fora passa
  // pelos anéis de dentro; a que sai de um nó com filhos (ou o vão da
  // entrada) passa pelos anéis de fora. O vizinho de outro anel precisa
  // ficar longe o bastante dessa direção.
  final n = nivel.length;
  for (var i = 0; i < n; i++) {
    final a = nivel[i];
    final si = i % k;
    final saiParaFora = a.filhos.isNotEmpty || a._tamanhoVao != null;
    for (var off = -(k - 1); off <= k - 1; off++) {
      if (off == 0) continue;
      final j = (i + off) % n < 0 ? (i + off) % n + n : (i + off) % n;
      if (j == i) continue;
      final sj = j % k;
      if (sj == si) continue;
      if (!(sj < si || saiParaFora)) continue;
      final b = nivel[j];
      var delta = (a.angulo - b.angulo).abs() % (2 * math.pi);
      if (delta > math.pi) delta = 2 * math.pi - delta;
      if (delta >= math.pi / 2 || delta < 1e-9) continue;
      final precisa = _meiaTangente(tam, a.angulo) + margemLinha + 6;
      final rr = precisa / math.sin(delta) - sj * sepSub;
      if (rr > r) r = rr;
    }
  }
  return r;
}

/// Verdadeiro se alguma caixa de [nos] cruza outra (varredura em x).
bool temSobreposicao(List<NoPosicionado> nos) =>
    paresSobrepostos(nos, parar: true).isNotEmpty;

/// Pares de nós cujas caixas se cruzam (em O(n log n) no caso comum).
List<(NoPosicionado, NoPosicionado)> paresSobrepostos(
  List<NoPosicionado> nos, {
  bool parar = false,
}) {
  final ordem = [...nos]
    ..sort((a, b) => a.retangulo.left.compareTo(b.retangulo.left));
  final r = <(NoPosicionado, NoPosicionado)>[];
  for (var i = 0; i < ordem.length; i++) {
    final a = ordem[i].retangulo;
    for (var j = i + 1; j < ordem.length; j++) {
      final b = ordem[j].retangulo;
      if (b.left >= a.right) break;
      if (b.top < a.bottom && a.top < b.bottom) {
        r.add((ordem[i], ordem[j]));
        if (parar) return r;
      }
    }
  }
  return r;
}
