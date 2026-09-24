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
    final visto = t.visto || (folhas > 0 && vistas == folhas)
        ? Visto.sim
        : vistas > 0
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

  /// Ângulo do centro do setor (radianos) e raio do anel.
  double angulo = 0;
  double raio = 0;
  Offset centro = Offset.zero;
  Size get tamanho => tamanhoDoNo(no.tipo, centro: profundidade == 0);
  Rect get retangulo => Rect.fromCenter(
    center: centro,
    width: tamanho.width,
    height: tamanho.height,
  );

  // Uso interno do layout.
  double _peso = 1;
  double _inicio = 0;
  double _fatia = 0;
}

class LayoutMapa {
  LayoutMapa(this.nos, this.limites, this.raios);

  /// Em ordem de profundidade (raiz primeiro).
  final List<NoPosicionado> nos;
  final Rect limites;

  /// Raios de cada anel (e sub-anel escalonado) por profundidade.
  final Map<int, List<double>> raios;

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

/// Espaço mínimo entre caixas vizinhas.
const _folga = 10.0;
const _folgaRadial = 26.0;

/// Máximo de sub-anéis escalonados num mesmo nível (quando há muitos nós,
/// eles alternam entre raios diferentes, como tijolos).
const _maxEscalonamento = 8;

/// Metade da projeção de uma caixa [s] na direção tangente ao ângulo [phi].
double _meiaTangente(Size s, double phi) =>
    s.width / 2 * math.sin(phi).abs() + s.height / 2 * math.cos(phi).abs();

double _meiaDiagonal(Size s) =>
    math.sqrt(s.width * s.width + s.height * s.height) / 2;

/// Layout radial: raiz no centro, cada nível num anel. O ângulo de cada ramo
/// é proporcional ao número de folhas (descendentes) dele. Os raios crescem
/// o quanto for preciso para as caixas não se sobreporem: entre anéis, as
/// faixas não se tocam; dentro do anel, vizinhos são separados pela
/// projeção na tangente (teorema do eixo separador).
LayoutMapa calcularLayout(NoMapa arvore) {
  final raiz = NoPosicionado(arvore, 0, null);
  final porNivel = <List<NoPosicionado>>[
    [raiz],
  ];
  final todos = <NoPosicionado>[raiz];
  // Montagem em pré-ordem, preservando a ordem angular em cada nível.
  void descer(NoPosicionado p) {
    for (final f in p.no.filhos) {
      final n = NoPosicionado(f, p.profundidade + 1, p);
      p.filhos.add(n);
      if (porNivel.length <= n.profundidade) porNivel.add([]);
      porNivel[n.profundidade].add(n);
      todos.add(n);
      descer(n);
    }
  }

  descer(raiz);

  // Peso = folhas do ramo.
  double pesar(NoPosicionado n) {
    if (n.filhos.isEmpty) return n._peso = 1;
    var s = 0.0;
    for (final f in n.filhos) {
      s += pesar(f);
    }
    return n._peso = s;
  }

  pesar(raiz);
  // Matéria recolhida (ou vazia) ao lado de matérias enormes ficaria com um
  // setor minúsculo e empurraria o anel para longe: piso de 30% da média.
  if (raiz.filhos.length > 1) {
    final media = raiz._peso / raiz.filhos.length;
    for (final f in raiz.filhos) {
      f._peso = math.max(f._peso, media * 0.3);
    }
  }

  // Setores angulares, começando no topo e em sentido horário.
  raiz._fatia = 2 * math.pi;
  final primeiro = raiz.filhos.isEmpty
      ? 0.0
      : raiz.filhos.first._peso /
            raiz.filhos.fold<double>(0, (s, f) => s + f._peso) *
            2 *
            math.pi;
  raiz._inicio = -math.pi / 2 - primeiro / 2;
  for (final nivel in porNivel) {
    for (final n in nivel) {
      final total = n.filhos.fold<double>(0, (s, f) => s + f._peso);
      var a = n._inicio;
      for (final f in n.filhos) {
        f._fatia = n._fatia * f._peso / total;
        f._inicio = a;
        f.angulo = a + f._fatia / 2;
        a += f._fatia;
      }
    }
  }

  // Raios por nível, com escalonamento opcional.
  final raios = <int, List<double>>{
    0: [0],
  };
  var externo = 0.0; // raio do sub-anel mais externo do nível anterior
  for (var d = 1; d < porNivel.length; d++) {
    final nivel = porNivel[d];
    // Cada anel tem um só tipo de nó; usa a maior caixa por segurança.
    final tam = _maiorCaixa(nivel);
    final meiaDiag = _meiaDiagonal(tam);
    final sepAnel =
        _meiaDiagonal(_maiorCaixa(porNivel[d - 1])) + meiaDiag + _folgaRadial;
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
    var r = melhorR!;
    // Garantia final: se ainda houver sobreposição no anel (casos extremos
    // com setores muito largos), afasta até resolver.
    for (var tentativa = 0; tentativa < 40; tentativa++) {
      _posicionar(nivel, r, melhorK, sepSub);
      if (!temSobreposicao(nivel)) break;
      r *= 1.08;
    }
    raios[d] = [for (var s = 0; s < melhorK; s++) r + s * sepSub];
    externo = r + (melhorK - 1) * sepSub;
  }

  var limites = raiz.retangulo;
  for (final n in todos) {
    limites = limites.expandToInclude(n.retangulo);
  }
  return LayoutMapa(todos, limites, raios);
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
    n.centro = Offset(n.raio * math.cos(n.angulo), n.raio * math.sin(n.angulo));
  }
}

/// Menor raio em que nós do mesmo sub-anel (a cada [k] nós) não se tocam.
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
      // Sub-anéis externos têm raio maior: desconta o deslocamento.
      final rr = precisa / (2 * math.sin(delta / 2)) - s * sepSub;
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
