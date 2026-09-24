/// Provas (banco de questões): leitura e validação do JSON
/// "edital-prova-v1", junção de blocos da mesma prova, ligação de tópicos
/// por semelhança e regras do sorteio. Tudo puro (sem banco), para testar.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'importar_edital.dart' show chaveTexto;

const formatoProva = 'edital-prova-v1';

/// Matérias que as provas usam (nomes oficiais, na ordem do pedido).
const materiasDeProva = [
  'Língua Portuguesa',
  'Matemática e Raciocínio Lógico',
  'Noções de Informática',
  'Direitos e Deveres Individuais e Coletivos',
  'Cidadania e Segurança Pública',
  'Ética no Serviço Público',
  'Legislação de Trânsito',
  'Crimes contra a Administração Pública',
  'Leis Penais Especiais',
  'Direito Constitucional',
  'Direito Administrativo',
  'Direito Penal',
  'Noções de Segurança e Vigilância',
];

/// Status possíveis de uma questão.
abstract final class StatusQuestao {
  static const anulada = 'anulada';
  static const imagem = 'imagem';
  static const revisar = 'revisar';
  static const desatualizada = 'desatualizada';
  static const todos = [anulada, imagem, revisar, desatualizada];

  /// Guardado no banco como texto separado por vírgula.
  static String juntar(Iterable<String> s) => [
    for (final x in todos)
      if (s.contains(x)) x,
  ].join(',');
  static Set<String> separar(String s) => {
    for (final x in s.split(','))
      if (x.trim().isNotEmpty) x.trim(),
  };
}

// -----------------------------------------------------------------------------
// Modelo lido do JSON
// -----------------------------------------------------------------------------

class TextoImportado {
  TextoImportado(this.id, this.titulo, this.conteudo);
  final String id;
  final String titulo;
  final String conteudo;
}

class Descartada {
  const Descartada(this.numero, this.motivo);
  final int numero;
  final String motivo;
}

class QuestaoImportada {
  QuestaoImportada({
    required this.numero,
    required this.textoId,
    required this.materia,
    required this.topico,
    required this.enunciado,
    required this.alternativas,
    required this.resposta,
    required this.status,
    required this.obs,
  }) : topicoOriginal = topico;

  final int numero;
  final String? textoId;
  String materia;

  /// Texto do tópico como veio do JSON (sempre guardado).
  final String topicoOriginal;
  String topico;
  final String enunciado;

  /// Letra → texto, na ordem das letras.
  final Map<String, String> alternativas;
  String resposta;
  Set<String> status;
  final String obs;

  bool get anulada => status.contains(StatusQuestao.anulada);

  // Decisão sobre o tópico, tomada na prévia.
  /// Id do tópico escolhido (ou achado automaticamente).
  String? topicoId;

  /// Criar um tópico novo com [topico] como nome.
  bool criarTopico = false;

  /// Escolhido pelo usuário na prévia (não mexer mais automaticamente).
  bool topicoDecidido = false;
}

class ProvaImportada {
  ProvaImportada({
    required this.banca,
    required this.orgao,
    required this.cargo,
    required this.ano,
    required this.gabarito,
    required this.numAlternativas,
    required this.totalQuestoes,
    required this.gabaritoLido,
    required this.descartadas,
    required this.textos,
    required this.questoes,
  });

  final String banca;
  final String orgao;
  final String cargo;
  final int ano;

  /// "preliminar" ou "definitivo".
  final String gabarito;
  final int numAlternativas;
  final int totalQuestoes;
  final Map<int, String> gabaritoLido;
  final List<Descartada> descartadas;
  final List<TextoImportado> textos;
  final List<QuestaoImportada> questoes;

  bool get definitivo => gabarito == 'definitivo';

  /// Banca + órgão + cargo + ano: identifica a mesma prova.
  String get chave => chaveProva(banca, orgao, cargo, ano);

  List<String> get letras => letrasDe(numAlternativas);

  String get titulo => '$orgao · $cargo · $ano';
}

String chaveProva(String banca, String orgao, String cargo, int ano) =>
    [chaveTexto(banca), chaveTexto(orgao), chaveTexto(cargo), '$ano'].join('|');

List<String> letrasDe(int n) => [
  for (var i = 0; i < n; i++) String.fromCharCode(65 + i),
];

// -----------------------------------------------------------------------------
// Leitura
// -----------------------------------------------------------------------------

/// Problema encontrado ao ler. [numero] nulo = problema geral.
class Problema {
  const Problema(this.mensagem, {this.numero, this.grave = true});
  final String mensagem;
  final int? numero;

  /// Grave impede a importação; não grave é só aviso.
  final bool grave;

  @override
  String toString() => mensagem;
}

/// Resposta diferente do gabarito lido: o usuário escolhe qual vale.
class Divergencia {
  Divergencia(this.numero, this.resposta, this.gabarito);
  final int numero;
  final String resposta;
  final String gabarito;

  /// Letra escolhida pelo usuário (nula = ainda não escolheu).
  String? escolhida;

  String get mensagem =>
      'Resposta $resposta, mas o gabarito lido diz $gabarito';
}

class LeituraProva {
  LeituraProva(this.prova, this.problemas, this.divergencias);
  final ProvaImportada? prova;
  final List<Problema> problemas;
  final List<Divergencia> divergencias;

  List<Problema> get erros => [
    for (final p in problemas)
      if (p.grave) p,
  ];
  List<Problema> get avisos => [
    for (final p in problemas)
      if (!p.grave) p,
  ];

  bool get pendentes => divergencias.any((d) => d.escolhida == null);

  /// Pode importar: sem erro grave e todas as divergências decididas.
  bool get podeImportar => prova != null && erros.isEmpty && !pendentes;

  /// Aplica as escolhas das divergências nas questões.
  void aplicarEscolhas() {
    final p = prova;
    if (p == null) return;
    for (final d in divergencias) {
      if (d.escolhida == null) continue;
      for (final q in p.questoes) {
        if (q.numero == d.numero) q.resposta = d.escolhida!;
      }
    }
  }
}

/// Separa blocos JSON colados em sequência ("{...}{...}" ou um por vez).
/// Texto fora de chaves (comentários, "continua") é ignorado.
List<String> separarBlocosJson(String texto) {
  final blocos = <String>[];
  var nivel = 0, inicio = -1;
  var emTexto = false, escape = false;
  for (var i = 0; i < texto.length; i++) {
    final c = texto[i];
    if (emTexto) {
      if (escape) {
        escape = false;
      } else if (c == r'\') {
        escape = true;
      } else if (c == '"') {
        emTexto = false;
      }
      continue;
    }
    if (c == '"') {
      if (nivel > 0) emTexto = true;
    } else if (c == '{') {
      if (nivel == 0) inicio = i;
      nivel++;
    } else if (c == '}' && nivel > 0) {
      nivel--;
      if (nivel == 0) blocos.add(texto.substring(inicio, i + 1));
    }
  }
  if (nivel > 0 && inicio >= 0) blocos.add(texto.substring(inicio));
  return blocos;
}

String _txt(Object? v) => v == null ? '' : '$v'.trim();

int? _int(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(_txt(v));
}

/// Lê um ou mais blocos "edital-prova-v1" da mesma prova e valida tudo.
LeituraProva lerProva(String texto) {
  final problemas = <Problema>[];
  final blocos = separarBlocosJson(texto);
  if (blocos.isEmpty) {
    return LeituraProva(null, [
      const Problema(
        'Não encontrei nenhum JSON. Cole o texto que começa com "{" e termina com "}".',
      ),
    ], []);
  }

  final mapas = <Map<String, dynamic>>[];
  for (final (i, b) in blocos.indexed) {
    final nome = blocos.length == 1 ? 'O JSON' : 'O bloco ${i + 1}';
    try {
      final v = jsonDecode(b);
      if (v is! Map<String, dynamic>) {
        problemas.add(Problema('$nome não é um objeto { ... }.'));
        continue;
      }
      if (v['formato'] != formatoProva) {
        problemas.add(
          Problema(
            '$nome não está no formato "$formatoProva" '
            '(o campo "formato" veio ${v['formato'] == null ? 'vazio' : '"${v['formato']}"'}).',
          ),
        );
        continue;
      }
      mapas.add(v);
    } on FormatException catch (e) {
      problemas.add(
        Problema('$nome tem erro de digitação: ${_explicar(e, b)}'),
      );
    }
  }
  if (mapas.isEmpty) return LeituraProva(null, problemas, []);

  // Cabeçalho: todos os blocos precisam ser da mesma prova.
  Map<String, dynamic> cab(Map<String, dynamic> m) =>
      (m['prova'] as Map?)?.cast<String, dynamic>() ?? {};
  final c0 = cab(mapas.first);
  String chaveDe(Map<String, dynamic> c) => chaveProva(
    _txt(c['banca']),
    _txt(c['orgao']),
    _txt(c['cargo']),
    _int(c['ano']) ?? 0,
  );
  for (final (i, m) in mapas.indexed.skip(1)) {
    if (chaveDe(cab(m)) != chaveDe(c0)) {
      problemas.add(
        Problema(
          'O bloco ${i + 1} é de outra prova (banca, órgão, cargo ou ano '
          'diferentes). Cole uma prova por vez.',
        ),
      );
    }
  }
  if (problemas.any((p) => p.grave)) return LeituraProva(null, problemas, []);

  for (final campo in ['banca', 'orgao', 'cargo']) {
    if (_txt(c0[campo]).isEmpty) {
      problemas.add(Problema('Falta "$campo" no cabeçalho da prova.'));
    }
  }
  final ano = _int(c0['ano']);
  if (ano == null) problemas.add(const Problema('Falta o "ano" da prova.'));
  final lidoAlt = _int(c0['num_alternativas']);
  if (lidoAlt != 4 && lidoAlt != 5) {
    problemas.add(const Problema('"num_alternativas" precisa ser 4 ou 5.'));
  }
  final numAlt = lidoAlt == 4 ? 4 : 5;
  final gabarito = _txt(c0['gabarito']).toLowerCase();
  if (gabarito != 'preliminar' && gabarito != 'definitivo') {
    problemas.add(
      const Problema('"gabarito" precisa ser "preliminar" ou "definitivo".'),
    );
  }
  final letras = letrasDe(numAlt);

  // Junta os blocos (continuação).
  final gabaritoLido = <int, String>{};
  final descartadas = <int, Descartada>{};
  final textos = <String, TextoImportado>{};
  final brutas = <Map<String, dynamic>>[];
  var total = 0;
  for (final m in mapas) {
    final c = cab(m);
    total = math.max(total, _int(c['total_questoes']) ?? 0);
    final g = c['gabarito_lido'];
    if (g is Map) {
      g.forEach((k, v) {
        final n = _int(k);
        if (n != null) gabaritoLido[n] = _txt(v).toUpperCase();
      });
    }
    for (final d in (c['descartadas'] as List?) ?? const []) {
      if (d is! Map) continue;
      final n = _int(d['numero']);
      if (n != null) descartadas[n] = Descartada(n, _txt(d['motivo']));
    }
    for (final t in (m['textos'] as List?) ?? const []) {
      if (t is! Map) continue;
      final id = _txt(t['id']);
      if (id.isEmpty) continue;
      textos[id] = TextoImportado(id, _txt(t['titulo']), _txt(t['conteudo']));
    }
    for (final q in (m['questoes'] as List?) ?? const []) {
      if (q is Map) brutas.add(q.cast<String, dynamic>());
    }
  }
  if (total <= 0) {
    problemas.add(const Problema('Falta "total_questoes" no cabeçalho.'));
  }

  final questoes = <QuestaoImportada>[];
  final vistos = <int>{};
  for (final (i, q) in brutas.indexed) {
    final n = _int(q['numero']);
    final rotulo = n == null ? 'A ${i + 1}ª questão da lista' : 'Questão $n';
    if (n == null) {
      problemas.add(Problema('$rotulo está sem "numero".'));
      continue;
    }
    if (!vistos.add(n)) {
      problemas.add(Problema('$rotulo aparece repetida.', numero: n));
      continue;
    }
    if (descartadas.containsKey(n)) {
      problemas.add(
        Problema('$rotulo está nas descartadas e também na lista.', numero: n),
      );
    }
    final alts = <String, String>{};
    final brutasAlt = q['alternativas'];
    if (brutasAlt is Map) {
      brutasAlt.forEach((k, v) => alts[_txt(k).toUpperCase()] = _txt(v));
    }
    final faltam = [
      for (final l in letras)
        if ((alts[l] ?? '').isEmpty) l,
    ];
    final sobram = [
      for (final l in alts.keys)
        if (!letras.contains(l)) l,
    ];
    if (faltam.isNotEmpty) {
      problemas.add(
        Problema(
          '$rotulo: falta a alternativa ${faltam.join(', ')} '
          '(a prova tem $numAlt alternativas).',
          numero: n,
        ),
      );
    }
    if (sobram.isNotEmpty) {
      problemas.add(
        Problema(
          '$rotulo: alternativa ${sobram.join(', ')} a mais '
          '(a prova tem $numAlt alternativas).',
          numero: n,
        ),
      );
    }
    final status = <String>{};
    for (final s in (q['status'] as List?) ?? const []) {
      final k = chaveTexto(_txt(s));
      if (StatusQuestao.todos.contains(k)) {
        status.add(k);
      } else if (k.isNotEmpty) {
        problemas.add(
          Problema(
            '$rotulo: status "$s" desconhecido (use anulada, imagem, '
            'revisar ou desatualizada).',
            numero: n,
            grave: false,
          ),
        );
      }
    }
    final resposta = _txt(q['resposta']).toUpperCase();
    if (resposta == 'X') {
      if (!status.contains(StatusQuestao.anulada)) {
        problemas.add(
          Problema(
            '$rotulo: resposta "X" só vale para questão anulada '
            '(ponha "anulada" no status).',
            numero: n,
          ),
        );
      }
    } else if (!letras.contains(resposta)) {
      problemas.add(
        Problema(
          '$rotulo: resposta "$resposta" inválida (use ${letras.join(', ')}'
          '${status.contains(StatusQuestao.anulada) ? ' ou X' : ''}).',
          numero: n,
        ),
      );
    }
    final textoId = _txt(q['texto_id']);
    if (textoId.isNotEmpty && !textos.containsKey(textoId)) {
      problemas.add(
        Problema(
          '$rotulo: usa o texto "$textoId", que não está em "textos".',
          numero: n,
        ),
      );
    }
    final materia = _txt(q['materia']);
    if (materia.isEmpty) {
      problemas.add(Problema('$rotulo está sem matéria.', numero: n));
    }
    if (_txt(q['enunciado']).isEmpty) {
      problemas.add(Problema('$rotulo está sem enunciado.', numero: n));
    }
    questoes.add(
      QuestaoImportada(
        numero: n,
        textoId: textoId.isEmpty ? null : textoId,
        materia: materia,
        topico: _txt(q['topico']),
        enunciado: _txt(q['enunciado']),
        alternativas: {for (final l in letras) l: alts[l] ?? ''},
        resposta: resposta,
        status: status,
        obs: _txt(q['obs']),
      ),
    );
  }
  questoes.sort((a, b) => a.numero.compareTo(b.numero));

  if (total > 0 && questoes.length + descartadas.length != total) {
    problemas.add(
      Problema(
        '${questoes.length} questões + ${descartadas.length} descartadas = '
        '${questoes.length + descartadas.length}, mas a prova tem $total. '
        'Se faltar um bloco, cole a continuação depois.',
        grave: false,
      ),
    );
  }

  final divergencias = <Divergencia>[];
  for (final q in questoes) {
    final g = gabaritoLido[q.numero];
    if (g != null && g.isNotEmpty && g != q.resposta) {
      divergencias.add(Divergencia(q.numero, q.resposta, g));
    }
  }

  final prova = ProvaImportada(
    banca: _txt(c0['banca']),
    orgao: _txt(c0['orgao']),
    cargo: _txt(c0['cargo']),
    ano: ano ?? 0,
    gabarito: gabarito,
    numAlternativas: numAlt,
    totalQuestoes: total,
    gabaritoLido: gabaritoLido,
    descartadas: descartadas.values.toList()
      ..sort((a, b) => a.numero.compareTo(b.numero)),
    textos: textos.values.toList(),
    questoes: questoes,
  );
  return LeituraProva(prova, problemas, divergencias);
}

/// Mensagem simples para erro de sintaxe, com a linha do problema.
String _explicar(FormatException e, String fonte) {
  final off = e.offset;
  if (off == null || off > fonte.length) return 'o texto não é um JSON válido.';
  final linha = '\n'.allMatches(fonte.substring(0, off)).length + 1;
  return 'perto da linha $linha (falta vírgula, aspas ou chave?).';
}

// -----------------------------------------------------------------------------
// Contagens da prévia
// -----------------------------------------------------------------------------

Map<String, int> contarPorMateria(Iterable<QuestaoImportada> qs) {
  final r = <String, int>{};
  for (final q in qs) {
    r[q.materia] = (r[q.materia] ?? 0) + 1;
  }
  return r;
}

Map<String, List<int>> contarPorStatus(Iterable<QuestaoImportada> qs) {
  final r = {for (final s in StatusQuestao.todos) s: <int>[]};
  for (final q in qs) {
    for (final s in q.status) {
      r[s]?.add(q.numero);
    }
  }
  return r;
}

/// Nome oficial da matéria (lista de provas) com a mesma chave, ou o
/// próprio nome.
String nomeOficialMateria(String nome) {
  final k = chaveTexto(nome);
  for (final m in materiasDeProva) {
    if (chaveTexto(m) == k) return m;
  }
  return nome.trim();
}

// -----------------------------------------------------------------------------
// Tópicos por semelhança
// -----------------------------------------------------------------------------

const _vazias = {
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
  'na',
  'no',
  'nas',
  'nos',
  'para',
  'com',
  'por',
  'um',
  'uma',
  'lei',
  'leis',
  'art',
  'arts',
  'artigo',
  'sobre',
  'entre',
  'ou',
  'que',
  'se',
  'n',
  'nocoes',
  'nocao',
  'conceito',
  'conceitos',
  'aspectos',
  'geral',
  'gerais',
};

String _singular(String p) {
  if (p.length <= 3) return p;
  if (p.endsWith('oes') || p.endsWith('aes')) {
    return '${p.substring(0, p.length - 3)}ao';
  }
  if (p.endsWith('ais')) return '${p.substring(0, p.length - 3)}al';
  if (p.endsWith('eis')) return '${p.substring(0, p.length - 3)}el';
  if (p.endsWith('ns')) return '${p.substring(0, p.length - 2)}m';
  if (p.endsWith('s')) return p.substring(0, p.length - 1);
  return p;
}

/// Palavras-chave de um tópico: sem acento, sem palavras vazias, no
/// singular; números como "13.022/2014" viram "13022" e "2014".
Set<String> palavrasChave(String s) {
  final k = chaveTexto(
    s.replaceAllMapped(RegExp(r'(\d)\.(\d)'), (m) => '${m[1]}${m[2]}'),
  );
  return {
    for (final p in k.split(' '))
      if (p.isNotEmpty &&
          !_vazias.contains(p) &&
          !(RegExp(r'^\d$').hasMatch(p)) &&
          !(p.length == 1))
        _singular(p),
  };
}

/// Semelhança de 0 a 1 entre dois nomes de tópico: palavras em comum
/// sobre o menor dos dois. Nome igual (ignorando acento) = 1.
({double nota, int comuns}) semelhanca(String a, String b) {
  if (chaveTexto(a) == chaveTexto(b)) return (nota: 1.0, comuns: 99);
  final pa = palavrasChave(a), pb = palavrasChave(b);
  if (pa.isEmpty || pb.isEmpty) return (nota: 0.0, comuns: 0);
  final comuns = pa.intersection(pb).length;
  return (nota: comuns / math.min(pa.length, pb.length), comuns: comuns);
}

class CandidatoTopico {
  const CandidatoTopico(this.id, this.nome, this.nota, this.comuns);
  final String id;
  final String nome;
  final double nota;
  final int comuns;
}

/// Tópicos da matéria parecidos com [nome], do mais para o menos parecido.
List<CandidatoTopico> candidatosTopico(
  String nome,
  Iterable<({String id, String nome})> topicos,
) {
  final r = [
    for (final t in topicos)
      () {
        final s = semelhanca(nome, t.nome);
        return CandidatoTopico(t.id, t.nome, s.nota, s.comuns);
      }(),
  ]..removeWhere((c) => c.comuns == 0);
  r.sort((a, b) {
    final c = b.nota.compareTo(a.nota);
    return c != 0 ? c : b.comuns.compareTo(a.comuns);
  });
  return r;
}

/// Semelhança boa o bastante para ligar sem perguntar: nome igual, uma
/// palavra-chave só e igual, ou 2+ palavras em comum cobrindo 40% do menor.
/// E o melhor precisa ganhar com folga do segundo (senão é ambíguo).
CandidatoTopico? melhorTopico(List<CandidatoTopico> candidatos) {
  if (candidatos.isEmpty) return null;
  final m = candidatos.first;
  if (m.comuns == 99) return m; // nome igual
  final bom = m.nota >= 1 || (m.comuns >= 2 && m.nota >= 0.4);
  if (!bom) return null;
  if (candidatos.length > 1 && m.nota - candidatos[1].nota < 0.1) return null;
  return m;
}

// -----------------------------------------------------------------------------
// Selos e sorteio
// -----------------------------------------------------------------------------

const _palavrasLegislacao = [
  'direito',
  'lei',
  'legislacao',
  'crime',
  'penal',
  'etica',
  'cidadania',
  'estatuto',
  'constitucional',
  'administrativ',
  'transito',
];

/// Questão de legislação (lei pode ter mudado desde a prova).
bool ehLegislacao(String materia, String topico) {
  final k = '${chaveTexto(materia)} ${chaveTexto(topico)}';
  return _palavrasLegislacao.any(k.contains);
}

/// "Prova de AAAA: confira a lei atual" quando passou de 4 anos.
bool provaAntiga(int ano, DateTime hoje) => ano > 0 && hoje.year - ano > 4;

/// Tempo sugerido para o simulado: 4 minutos por questão.
const minutosPorQuestao = 4;

/// Resumo de uma questão para o sorteio.
class ItemSorteio {
  const ItemSorteio(this.id, {required this.feitas, required this.errouUltima});
  final String id;
  final int feitas;
  final bool errouUltima;
}

/// Sorteia [n] questões: primeiro as nunca feitas, depois as que errei
/// (na última vez), depois as demais. Dentro de cada grupo, ao acaso.
List<String> sortearPriorizando(
  List<ItemSorteio> itens,
  int n, {
  math.Random? rnd,
}) {
  final r = rnd ?? math.Random();
  final nunca = [
    for (final i in itens)
      if (i.feitas == 0) i.id,
  ]..shuffle(r);
  final errei = [
    for (final i in itens)
      if (i.feitas > 0 && i.errouUltima) i.id,
  ]..shuffle(r);
  final outras = [
    for (final i in itens)
      if (i.feitas > 0 && !i.errouUltima) i.id,
  ]..shuffle(r);
  return [...nunca, ...errei, ...outras].take(n).toList();
}

/// Motivos do erro (perguntados ao errar).
const motivosErro = {
  'nao_sabia': 'Não sabia',
  'desatencao': 'Desatenção',
  'pegadinha': 'Pegadinha',
};
