/// Separa o texto do conteúdo programático de um edital em matérias e
/// tópicos, sem internet: regras que cobrem os formatos mais comuns.
///
/// Matérias: linhas em MAIÚSCULAS ("LÍNGUA PORTUGUESA:"), cabeçalhos
/// "Nome: conteúdo" ou uma linha curta com nome de disciplina. Cabeçalhos
/// sem conteúdo logo antes de outro (ex.: "CONHECIMENTOS BÁSICOS") são
/// tratados como grupo e ignorados.
///
/// Tópicos: numeração decimal (1, 1.1, 1.1.1), algarismos romanos
/// (I, II...), marcadores (•, -) ou, sem numeração, frases separadas por
/// ponto ou ponto e vírgula.
///
/// Modo estruturado: se alguma linha for um cabeçalho em MAIÚSCULAS
/// terminando com ":" ("LÍNGUA PORTUGUESA:"), o texto já vem organizado.
/// Aí só essas linhas viram matéria, cada linha comum é um tópico e as
/// que começam com "-" são subtópicos do tópico anterior. Nenhuma das
/// regras acima (nome de disciplina, grupos, numeração, frases) é usada.
library;

class TopicoImportado {
  TopicoImportado(this.nome, [List<TopicoImportado>? filhos])
    : filhos = filhos ?? [];
  String nome;
  final List<TopicoImportado> filhos;

  int get folhas => filhos.isEmpty ? 1 : filhos.fold(0, (a, f) => a + f.folhas);
  int get total => 1 + filhos.fold(0, (a, f) => a + f.total);

  @override
  String toString() => filhos.isEmpty ? nome : '$nome $filhos';
}

class MateriaImportada {
  MateriaImportada(this.nome, this.topicos);
  String nome;
  final List<TopicoImportado> topicos;
  bool incluir = true;

  int get totalTopicos => topicos.fold(0, (a, t) => a + t.total);

  @override
  String toString() => '$nome: $topicos';
}

// -----------------------------------------------------------------------------
// Utilidades de texto
// -----------------------------------------------------------------------------

const _maiusculas = 'A-ZÁÀÂÃÉÊÍÓÔÕÚÜÇ';
final _letra = RegExp('[a-zA-ZáàâãéêíóôõúüçÁÀÂÃÉÊÍÓÔÕÚÜÇ]');
final _letraMaiuscula = RegExp('[$_maiusculas]');

/// Palavras que quase sempre indicam nome de disciplina.
const _palavrasDisciplina = [
  'portugues',
  'lingua',
  'matematica',
  'raciocinio',
  'logic',
  'direito',
  'nocoes',
  'legislacao',
  'informatica',
  'conhecimentos',
  'atualidades',
  'historia',
  'geografia',
  'etica',
  'administracao',
  'administrativo',
  'contabilidade',
  'economia',
  'estatistica',
  'arquivologia',
  'ingles',
  'espanhol',
  'redacao',
  'constitucional',
  'penal',
  'processual',
  'civil',
  'tributario',
  'financeira',
  'orcamento',
  'auditoria',
  'criminologia',
  'medicina',
  'fisica',
  'quimica',
  'biologia',
  'pedagogia',
  'saude',
  'seguranca',
  'humanos',
  'realidade',
  'tecnologia',
  'gestao',
  'politicas',
  'publica',
  'atendimento',
];

String _semAcento(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const para = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
  final b = StringBuffer();
  for (final r in s.runes) {
    final c = String.fromCharCode(r);
    final i = de.indexOf(c);
    b.write(i < 0 ? c : para[i]);
  }
  return b.toString();
}

String chaveTexto(String s) =>
    _semAcento(s.toLowerCase()).replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

bool _pareceDisciplina(String s) {
  final k = chaveTexto(s);
  return _palavrasDisciplina.any(k.contains);
}

/// Texto "todo em maiúsculas" (tolerando números, pontuação e conectivos).
bool _emMaiusculas(String s) {
  final letras = _letra.allMatches(s).map((m) => m.group(0)!).toList();
  if (letras.length < 4) return false;
  final mai = letras.where((c) => _letraMaiuscula.hasMatch(c)).length;
  return mai / letras.length >= 0.85;
}

const _conectivos = {
  'de',
  'da',
  'do',
  'das',
  'dos',
  'e',
  'em',
  'a',
  'o',
  'as',
  'os',
  'ao',
  'aos',
  'à',
  'às',
  'na',
  'no',
  'nas',
  'nos',
  'para',
  'com',
  'por',
  'ou',
  'um',
  'uma',
  'contra',
  'sobre',
  'entre',
  'sem',
};

/// "NOÇÕES DE DIREITO CONSTITUCIONAL" -> "Noções de Direito Constitucional".
/// Siglas curtas ou sem vogais (SUS, STF, LGPD) continuam em maiúsculas.
String nomeDeMateria(String bruto) {
  var s = bruto
      .replaceFirst(RegExp(r'^\s*(\d+|[IVXLC]+)\s*[\.\)\-–—:]\s*'), '')
      .replaceFirst(RegExp(r'[\s:;\.\-–—]+$'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (!_emMaiusculas(s)) return s;
  final palavras = s.split(' ');
  return [
    for (final (i, p) in palavras.indexed)
      () {
        final min = p.toLowerCase();
        final soLetras = min.replaceAll(RegExp(r'[^a-záàâãéêíóôõúüç]'), '');
        if (i > 0 && _conectivos.contains(soLetras)) return min;
        final semVogal = !RegExp('[aeiouáàâãéêíóôõúü]').hasMatch(soLetras);
        if (soLetras.length >= 2 &&
            (semVogal || (soLetras.length <= 3 && i > 0))) {
          return p;
        }
        return min.isEmpty ? p : min[0].toUpperCase() + min.substring(1);
      }(),
  ].join(' ');
}

String _limparTopico(String s) {
  var t = s
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceFirst(RegExp(r'^[\s•·▪●◦\-–—*,;:.]+'), '')
      .replaceFirst(RegExp(r'[\s,;:.–—\-]+$'), '')
      .trim();
  if (t.length > 500) t = '${t.substring(0, 497)}...';
  if (t.isEmpty) return t;
  return t[0].toUpperCase() + t.substring(1);
}

// -----------------------------------------------------------------------------
// Matérias
// -----------------------------------------------------------------------------

class _Bloco {
  _Bloco(this.titulo);
  final String? titulo;
  final linhas = <String>[];
}

final _cabecalhoMaiusculo = RegExp(
  '^([$_maiusculas][${_maiusculas}0-9 ,/()ºª\\-–]{2,100}?)\\s*(?::|\\s[–—-]\\s)\\s*(.*)\$',
);
final _cabecalhoTitulo = RegExp(r'^([^\d:]{3,70}?)\s*:\s+(.+)$');
final _comecaNumerado = RegExp(
  r'^(\d{1,2}(\.\d{1,2})*|[IVX]{1,5})\s*[\.\)\-–—]?\s+\S',
);

/// Quebra cabeçalhos em maiúsculas que vieram no meio de um parágrafo
/// ("... texto. RACIOCÍNIO LÓGICO: 1 ...") para o começo de uma linha.
String _separarCabecalhosEmLinha(String texto) {
  final re = RegExp(
    '(?<=[.;:]\\s{1,3})([$_maiusculas][$_maiusculas ,/()\\-–]{3,90}?)\\s*:(?=\\s)',
  );
  return texto.replaceAllMapped(re, (m) {
    final h = m.group(1)!;
    final palavras = h
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .toList();
    final ok =
        _emMaiusculas(h) && (palavras.length >= 2 || h.trim().length >= 7);
    return ok ? '\n$h:' : m.group(0)!;
  });
}

List<_Bloco> _blocos(String texto) {
  final linhas = _separarCabecalhosEmLinha(texto.replaceAll('\r', ''))
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty);
  final blocos = <_Bloco>[_Bloco(null)];

  for (final l in linhas) {
    // Linha inteira em maiúsculas (com ou sem ":" no fim).
    final semDoisPontos = l.replaceFirst(RegExp(r'[:\s]+$'), '');
    final semNumero = semDoisPontos.replaceFirst(
      RegExp(r'^(\d+|[IVXLC]+)\s*[\.\)\-–—]\s*'),
      '',
    );
    if (_emMaiusculas(semNumero) &&
        semNumero.length <= 110 &&
        !_comecaNumerado.hasMatch(semDoisPontos)) {
      blocos.add(_Bloco(semNumero));
      continue;
    }
    // "LÍNGUA PORTUGUESA: 1 Compreensão..."
    final m = _cabecalhoMaiusculo.firstMatch(l);
    if (m != null &&
        _emMaiusculas(m.group(1)!) &&
        m.group(1)!.trim().length >= 4) {
      blocos.add(_Bloco(m.group(1)!)..linhas.add(m.group(2)!));
      continue;
    }
    // "Língua Portuguesa: 1 Compreensão..." ou "Direito Penal: conteúdo".
    final t = _cabecalhoTitulo.firstMatch(l);
    if (t != null) {
      final nome = t.group(1)!;
      final resto = t.group(2)!;
      final palavras = nome.trim().split(RegExp(r'\s+')).length;
      if (palavras <= 8 &&
          (_pareceDisciplina(nome) || _comecaNumerado.hasMatch(resto))) {
        blocos.add(_Bloco(nome)..linhas.add(resto));
        continue;
      }
    }
    // Linha curta que é só o nome de uma disciplina ("Língua Portuguesa").
    if (l.length <= 70 &&
        !RegExp(r'[.;]$').hasMatch(l) &&
        !_comecaNumerado.hasMatch(l) &&
        _pareceDisciplina(l) &&
        l.split(RegExp(r'\s+')).length <= 8 &&
        RegExp('^[$_maiusculas]').hasMatch(l)) {
      blocos.add(_Bloco(l));
      continue;
    }
    blocos.last.linhas.add(l);
  }
  return blocos;
}

/// Junta as linhas de um bloco (desfaz quebras de linha do PDF).
String _juntar(List<String> linhas) {
  final b = StringBuffer();
  for (final l in linhas) {
    final marcador = RegExp(r'^[•·▪●◦]\s*|^[-–—*]\s+').hasMatch(l);
    final atual = b.toString();
    if (atual.isEmpty) {
      b.write(
        marcador ? '• ${l.replaceFirst(RegExp(r'^[•·▪●◦\-–—*]\s*'), '')}' : l,
      );
    } else if (marcador) {
      b.write(' • ${l.replaceFirst(RegExp(r'^[•·▪●◦\-–—*]\s*'), '')}');
    } else if (atual.endsWith('-') &&
        RegExp(r'^[a-záàâãéêíóôõúüç]').hasMatch(l)) {
      // Palavra quebrada no fim da linha: "situa-\nções".
      b
        ..clear()
        ..write(atual.substring(0, atual.length - 1))
        ..write(l);
    } else {
      b.write(' $l');
    }
  }
  return b.toString();
}

// -----------------------------------------------------------------------------
// Tópicos
// -----------------------------------------------------------------------------

class _Marcador {
  _Marcador(this.inicio, this.fim, this.caminho);
  final int inicio;
  final int fim;
  final List<int> caminho;
}

final _palavrasAntesDeNumero = RegExp(
  r'(art|arts|artigo|artigos|n|nº|n°|no|lei|leis|decreto|inciso|incisos|inc|§|par|parágrafo|súmula|resolução|portaria|emenda|capítulo|título|anexo|item|itens|cap)\.?\s*$',
  caseSensitive: false,
);

bool _proximo(List<int> atual, List<int> novo) {
  if (atual.isEmpty) return novo.length == 1;
  // Irmão ou tio: incrementa um nível existente.
  for (var n = atual.length; n >= 1; n--) {
    if (novo.length == n) {
      var igual = true;
      for (var i = 0; i < n - 1; i++) {
        if (novo[i] != atual[i]) igual = false;
      }
      if (igual && novo[n - 1] == atual[n - 1] + 1) return true;
    }
  }
  // Filho: desce um nível começando em 1.
  if (novo.length == atual.length + 1 && novo.last == 1) {
    for (var i = 0; i < atual.length; i++) {
      if (novo[i] != atual[i]) return false;
    }
    return true;
  }
  return false;
}

List<_Marcador> _marcadoresDecimais(String s) {
  final re = RegExp(
    r'(?<=^|[\s.;:,(])(\d{1,2}(?:\.\d{1,2}){0,3})(?:\.|\)|\s?[-–—])?\s+(?=[a-zA-Z' +
        _maiusculas +
        r'"“(])',
  );
  final aceitos = <_Marcador>[];
  var atual = <int>[];
  for (final m in re.allMatches(s)) {
    final antes = s.substring(0, m.start);
    if (_palavrasAntesDeNumero.hasMatch(antes)) continue;
    final caminho = m.group(1)!.split('.').map(int.parse).toList();
    if (caminho.any((n) => n == 0)) continue;
    if (!_proximo(atual, caminho)) continue;
    aceitos.add(_Marcador(m.start, m.end, caminho));
    atual = caminho;
  }
  return aceitos;
}

int? _romano(String r) {
  const v = {'I': 1, 'V': 5, 'X': 10, 'L': 50};
  var total = 0;
  for (var i = 0; i < r.length; i++) {
    final a = v[r[i]];
    if (a == null) return null;
    final b = i + 1 < r.length ? v[r[i + 1]]! : 0;
    total += a < b ? -a : a;
  }
  return total;
}

List<_Marcador> _marcadoresRomanos(String s) {
  final re = RegExp(
    r'(?<=^|[\s.;:])([IVXL]{1,6})\s*[\.\)\-–—]\s*(?=[' + _maiusculas + r'a-z])',
  );
  final aceitos = <_Marcador>[];
  var esperado = 1;
  for (final m in re.allMatches(s)) {
    final n = _romano(m.group(1)!);
    if (n != esperado) continue;
    aceitos.add(_Marcador(m.start, m.end, [n!]));
    esperado++;
  }
  return aceitos;
}

List<TopicoImportado> _arvore(String s, List<_Marcador> marcadores) {
  final raiz = <TopicoImportado>[];
  final pilha = <(List<int>, TopicoImportado)>[];
  final introducao = _limparTopico(s.substring(0, marcadores.first.inicio));
  if (introducao.length >= 3) raiz.add(TopicoImportado(introducao));

  for (var i = 0; i < marcadores.length; i++) {
    final m = marcadores[i];
    final fim = i + 1 < marcadores.length ? marcadores[i + 1].inicio : s.length;
    final nome = _limparTopico(s.substring(m.fim, fim));
    if (nome.isEmpty) continue;
    final t = TopicoImportado(nome);
    // Até 3 níveis (tópico > subtópico > subsubtópico).
    final nivel = m.caminho.length.clamp(1, 3);
    while (pilha.isNotEmpty && pilha.last.$1.length >= nivel) {
      pilha.removeLast();
    }
    if (pilha.isEmpty) {
      raiz.add(t);
    } else {
      pilha.last.$2.filhos.add(t);
    }
    pilha.add((m.caminho.take(nivel).toList(), t));
  }
  return raiz;
}

final _abreviacoes = RegExp(
  r'(?:^|\s)(art|arts|inc|dec|n|nº|no|ex|pág|p|cf|al|sr|sra|dr|prof|obs|fls|ref|séc|vol|cap)$',
  caseSensitive: false,
);

List<TopicoImportado> _frases(String s) {
  final itens = <String>[];
  var inicio = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    var corta = false;
    if (c == ';' || c == '•') {
      corta = true;
    } else if (c == '.' && i + 1 < s.length && s[i + 1] == ' ') {
      // Ponto seguido de maiúscula, fora de abreviações e números (8.112).
      final resto = s.substring(i + 1).trimLeft();
      final antes = s.substring(inicio, i);
      if (resto.isNotEmpty &&
          _letraMaiuscula.hasMatch(resto[0]) &&
          !_abreviacoes.hasMatch(antes)) {
        corta = true;
      }
    }
    if (corta) {
      itens.add(s.substring(inicio, i));
      inicio = i + 1;
    }
  }
  itens.add(s.substring(inicio));
  return [
    for (final it in itens)
      if (_limparTopico(it).length >= 2) TopicoImportado(_limparTopico(it)),
  ];
}

List<TopicoImportado> separarTopicos(String conteudo) {
  final s = conteudo.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (s.isEmpty) return [];
  final decimais = _marcadoresDecimais(s);
  if (decimais.length >= 2) return _arvore(s, decimais);
  final romanos = _marcadoresRomanos(s);
  if (romanos.length >= 2) return _arvore(s, romanos);
  return _frases(s);
}

// -----------------------------------------------------------------------------
// Modo estruturado
// -----------------------------------------------------------------------------

final _terminaEmDoisPontos = RegExp(r'^(.+?)\s*:$');
final _subtopico = RegExp(r'^[-–—]');

/// "LÍNGUA PORTUGUESA:" sozinha na linha.
bool _cabecalhoEstruturado(String linha) {
  final m = _terminaEmDoisPontos.firstMatch(linha.trim());
  return m != null && _emMaiusculas(m.group(1)!);
}

/// Verdadeiro se o texto tem ao menos um cabeçalho em MAIÚSCULAS
/// terminando com ":" numa linha própria (ver [separarEdital]).
bool modoEstruturado(String texto) =>
    texto.replaceAll('\r', '').split('\n').any(_cabecalhoEstruturado);

List<MateriaImportada> _separarEstruturado(String texto) {
  final resultado = <MateriaImportada>[];
  final porChave = <String, MateriaImportada>{};
  MateriaImportada? atual;
  TopicoImportado? ultimo;

  MateriaImportada materia(String nome) =>
      porChave.putIfAbsent(chaveTexto(nome), () {
        final m = MateriaImportada(nome, []);
        resultado.add(m);
        return m;
      });

  for (final bruta in texto.replaceAll('\r', '').split('\n')) {
    final l = bruta.trim();
    if (l.isEmpty) continue; // linha em branco só separa blocos
    if (_cabecalhoEstruturado(l)) {
      final nome = nomeDeMateria(l);
      if (nome.isEmpty) continue;
      atual = materia(nome);
      ultimo = null;
      continue;
    }
    final nome = _limparTopico(l);
    if (nome.isEmpty) continue;
    atual ??= materia('Nova matéria');
    final t = TopicoImportado(nome);
    if (_subtopico.hasMatch(l) && ultimo != null) {
      ultimo.filhos.add(t);
    } else {
      atual.topicos.add(t);
      ultimo = t;
    }
  }
  return resultado;
}

// -----------------------------------------------------------------------------
// Entrada principal
// -----------------------------------------------------------------------------

/// Separa o texto colado em matérias com seus tópicos. Com cabeçalhos
/// "MATÉRIA:" em linha própria usa o modo estruturado; senão, as regras
/// para texto bruto copiado de PDF.
List<MateriaImportada> separarEdital(String texto) {
  if (modoEstruturado(texto)) return _separarEstruturado(texto);
  final blocos = _blocos(texto);
  final resultado = <MateriaImportada>[];
  final porChave = <String, MateriaImportada>{};

  for (var i = 0; i < blocos.length; i++) {
    final b = blocos[i];
    final topicos = separarTopicos(_juntar(b.linhas));
    if (topicos.isEmpty) continue; // grupo ("CONHECIMENTOS BÁSICOS") ou vazio
    final nome = b.titulo == null ? 'Nova matéria' : nomeDeMateria(b.titulo!);
    if (nome.isEmpty) continue;
    final chave = chaveTexto(nome);
    final existente = porChave[chave];
    if (existente != null) {
      existente.topicos.addAll(topicos);
    } else {
      final m = MateriaImportada(nome, topicos);
      porChave[chave] = m;
      resultado.add(m);
    }
  }
  return resultado;
}
