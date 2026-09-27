/// Mapa do conteúdo por tópico (etapa 12): leitura do JSON colado
/// ("edital-mapa-v1"), validação dos limites e a árvore para o layout em
/// balões do mapa mental.
///
/// Formato (aceita cercado de ``` ou de texto do chat):
/// ```json
/// {"formato":"edital-mapa-v1","materia":"...","topico":"...",
///  "subtopico":"","titulo":"Peculato","nos":[{"texto":"...",
///  "detalhe":"...","tipo":"conceito","filhos":[...]}]}
/// ```
library;

import 'dart:convert';

import 'colagem.dart';
import 'importar_edital.dart' show chaveTexto;
import 'mapa_mental.dart';

export 'colagem.dart' show ItemColado, LeituraColagem;

const formatoMapa = 'edital-mapa-v1';

/// Limites (com o aviso na prévia).
const limiteTextoNo = 70;
const limiteNiveis = 4;
const limiteNos = 80;

/// Tipo de cada nó, com a cor dele no mapa.
enum TipoNoConteudo {
  conceito('conceito', 'Conceito', 0xFF2F7CF6),
  artigo('artigo', 'Artigo de lei', 0xFF8E5CF7),
  exemplo('exemplo', 'Exemplo', 0xFF1E9E4A),
  pegadinha('pegadinha', 'Pegadinha', 0xFFE5322D),
  dica('dica', 'Dica', 0xFFE08A00);

  const TipoNoConteudo(this.chave, this.rotulo, this.cor);
  final String chave;
  final String rotulo;
  final int cor;

  static TipoNoConteudo? porChave(String s) {
    final k = chaveTexto(s);
    for (final t in values) {
      if (t.chave == k) return t;
    }
    return null;
  }
}

/// Um nó do mapa.
class NoConteudo {
  NoConteudo({
    required this.texto,
    this.detalhe = '',
    this.tipo = TipoNoConteudo.conceito,
    List<NoConteudo>? filhos,
  }) : filhos = filhos ?? [];

  final String texto;
  final String detalhe;
  final TipoNoConteudo tipo;
  final List<NoConteudo> filhos;

  Map<String, Object?> toJson() => {
    'texto': texto,
    if (detalhe.isNotEmpty) 'detalhe': detalhe,
    'tipo': tipo.chave,
    'filhos': [for (final f in filhos) f.toJson()],
  };

  static NoConteudo fromJson(Map j) => NoConteudo(
    texto: '${j['texto'] ?? ''}',
    detalhe: '${j['detalhe'] ?? ''}',
    tipo:
        TipoNoConteudo.porChave('${j['tipo'] ?? ''}') ??
        TipoNoConteudo.conceito,
    filhos: [
      for (final f in (j['filhos'] as List? ?? const []))
        if (f is Map) fromJson(f),
    ],
  );
}

/// Os nós em JSON (como ficam na tabela) e de volta.
String nosParaJson(List<NoConteudo> nos) =>
    jsonEncode([for (final n in nos) n.toJson()]);

List<NoConteudo> nosDeJson(String s) {
  final d = jsonDecode(s);
  return [
    if (d is List)
      for (final n in d)
        if (n is Map) NoConteudo.fromJson(n),
  ];
}

/// Todos os nós, em pré-ordem, com o nível (1 = abaixo do título).
Iterable<(NoConteudo, int)> percorrer(
  List<NoConteudo> nos, [
  int nivel = 1,
]) sync* {
  for (final n in nos) {
    yield (n, nivel);
    yield* percorrer(n.filhos, nivel + 1);
  }
}

/// Quantos nós de cada tipo.
Map<TipoNoConteudo, int> contarPorTipo(List<NoConteudo> nos) {
  final r = <TipoNoConteudo, int>{};
  for (final (n, _) in percorrer(nos)) {
    r[n.tipo] = (r[n.tipo] ?? 0) + 1;
  }
  return r;
}

/// Um mapa lido do JSON colado.
class MapaColado extends ItemColado {
  MapaColado({
    required super.indice,
    required super.materia,
    required super.topico,
    required super.subtopico,
    required this.titulo,
    required this.nos,
    required super.erros,
  });

  final String titulo;
  final List<NoConteudo> nos;

  int get totalNos => percorrer(nos).length;

  /// Um mapa por tópico/subtópico: a chave é o destino.
  @override
  String get chave => chaveTexto('$materia|$topico|$subtopico');
}

typedef LeituraMapas = LeituraColagem<MapaColado>;

extension LeituraMapasX on LeituraMapas {
  List<MapaColado> get mapas => itens;
}

/// Lê o JSON colado (um mapa ou uma lista deles). [materiaPadrao],
/// [topicoPadrao] e [subtopicoPadrao] preenchem o que faltar.
LeituraMapas lerMapas(
  String texto, {
  String? materiaPadrao,
  String? topicoPadrao,
  String? subtopicoPadrao,
}) => lerColagem(
  texto,
  plural: 'mapas',
  chaveLista: 'mapas',
  materiaPadrao: materiaPadrao,
  topicoPadrao: topicoPadrao,
  subtopicoPadrao: subtopicoPadrao,
  invalido: (i, erros) => MapaColado(
    indice: i,
    materia: '',
    topico: '',
    subtopico: '',
    titulo: '',
    nos: const [],
    erros: erros,
  ),
  lerItem: _lerMapa,
);

MapaColado _lerMapa(int indice, CamposItem c) {
  final erros = [...c.erros];
  final formato = c.campo('formato');
  if (formato.isNotEmpty && formato != formatoMapa) {
    erros.add('formato "$formato" (esperado "$formatoMapa")');
  }
  final titulo = c.campo('titulo').isEmpty
      ? (c.subtopico.isEmpty ? c.topico : c.subtopico)
      : c.campo('titulo');

  var total = 0;
  var fundoAvisado = false;
  List<NoConteudo> lerNos(Object? bruto, int nivel, String onde) {
    if (bruto == null) return [];
    if (bruto is! List) {
      erros.add('"filhos" de $onde não é uma lista');
      return [];
    }
    final r = <NoConteudo>[];
    for (final (i, b) in bruto.indexed) {
      if (b is! Map) {
        erros.add('item ${i + 1} de $onde não é um objeto { ... }');
        continue;
      }
      total++;
      final texto = b['texto'] == null ? '' : '${b['texto']}'.trim();
      final nome = texto.isEmpty ? 'sem texto' : "'$texto'";
      if (texto.isEmpty) erros.add('nó ${i + 1} de $onde sem texto');
      if (texto.length > limiteTextoNo) {
        erros.add(
          'Nó $nome: texto com ${texto.length} caracteres '
          '(máximo $limiteTextoNo)',
        );
      }
      if (nivel > limiteNiveis && !fundoAvisado) {
        fundoAvisado = true;
        erros.add(
          'Nó $nome: está no nível $nivel (máximo $limiteNiveis níveis)',
        );
      }
      final t = b['tipo'] == null ? '' : '${b['tipo']}'.trim();
      final tipo = t.isEmpty
          ? TipoNoConteudo.conceito
          : TipoNoConteudo.porChave(t);
      if (tipo == null) {
        erros.add(
          'Nó $nome: tipo "$t" não existe (use conceito, artigo, exemplo, '
          'pegadinha ou dica)',
        );
      }
      r.add(
        NoConteudo(
          texto: texto,
          detalhe: b['detalhe'] == null ? '' : '${b['detalhe']}'.trim(),
          tipo: tipo ?? TipoNoConteudo.conceito,
          filhos: lerNos(
            b['filhos'],
            nivel + 1,
            nome == 'sem texto' ? 'nó' : 'Nó $nome',
          ),
        ),
      );
    }
    return r;
  }

  final nos = lerNos(c.bruto('nos'), 1, 'nos');
  if (c.bruto('nos') is! List) {
    erros.add('falta a lista "nos"');
  } else if (nos.isEmpty) {
    erros.add('o mapa não tem nenhum nó');
  }
  if (total > limiteNos) {
    erros.add('o mapa tem $total nós (máximo $limiteNos)');
  }
  return MapaColado(
    indice: indice,
    materia: c.materia,
    topico: c.topico,
    subtopico: c.subtopico,
    titulo: titulo,
    nos: nos,
    erros: erros,
  );
}

// -----------------------------------------------------------------------------
// Árvore para o layout em balões
// -----------------------------------------------------------------------------

/// Monta a árvore do mapa mental: o título no centro, o 1º nível em volta
/// e os demais para fora. O id de cada nó é o caminho ("0", "0.1", ...),
/// e a cor é a do tipo. [nosPorId] recebe cada nó pelo id.
NoMapa arvoreDoConteudo(
  String titulo,
  List<NoConteudo> nos, {
  Map<String, NoConteudo>? nosPorId,
}) {
  NoMapa no(NoConteudo n, String id, int nivel) {
    nosPorId?[id] = n;
    return NoMapa(
      id: id,
      tipo: nivel == 1 ? TipoNo.topico : TipoNo.subtopico,
      rotulo: n.texto,
      cor: n.tipo.cor,
      filhos: [
        for (final (i, f) in n.filhos.indexed) no(f, '$id.$i', nivel + 1),
      ],
    );
  }

  return NoMapa(
    id: 'titulo',
    tipo: TipoNo.materia,
    rotulo: titulo,
    cor: 0xFF111111,
    filhos: [for (final (i, n) in nos.indexed) no(n, '$i', 1)],
  );
}

/// Nível de um id de nó ("0" = 1, "0.2" = 2; o título = 0).
int nivelDoId(String id) => id == 'titulo' ? 0 : '.'.allMatches(id).length + 1;
