/// Leitura genérica de listas coladas em JSON (questões e flashcards):
/// recorta o JSON do texto do chat, lê matéria › tópico › subtópico de cada
/// item, completa o que faltar com o tópico aberto e marca repetidos.
library;

import 'dart:convert';

import 'provas.dart' show nomeOficialMateria;

/// Um item lido do JSON, com o destino no edital.
abstract class ItemColado {
  ItemColado({
    required this.indice,
    required this.materia,
    required this.topico,
    required this.subtopico,
    required this.erros,
  });

  /// Posição na lista colada (1, 2, 3...).
  final int indice;
  final String materia;
  final String topico;

  /// Vazio = o item fica no próprio tópico.
  final String subtopico;

  /// Problemas que impedem importar este item.
  final List<String> erros;

  /// Preenchido na prévia: já existe no banco (ou repete outro da lista).
  bool repetida = false;

  bool get valida => erros.isEmpty;
  bool get entra => valida && !repetida;

  /// Texto normalizado que identifica o item (para não duplicar).
  String get chave;
}

/// Resultado da leitura do texto colado.
class LeituraColagem<T extends ItemColado> {
  const LeituraColagem(this.itens, {this.erro});

  final List<T> itens;

  /// Erro geral (JSON inválido, lista vazia...). Nulo = leu.
  final String? erro;

  int get validas => itens.where((q) => q.valida).length;
  int get novas => itens.where((q) => q.entra).length;
  int get repetidas => itens.where((q) => q.valida && q.repetida).length;
  int get comErro => itens.where((q) => !q.valida).length;
}

/// Campos comuns já lidos de um item: o destino (com os padrões da tela
/// aplicados) e os erros dele. Os campos próprios vêm de [campo].
class CamposItem {
  CamposItem._(this._item, this.materia, this.topico, this.subtopico)
    : erros = [
        if (materia.isEmpty) 'falta a matéria',
        if (topico.isEmpty) 'falta o tópico',
      ];

  final Map _item;
  final String materia;
  final String topico;
  final String subtopico;
  final List<String> erros;

  /// Texto do campo, sem espaços nas pontas ('' se não veio).
  String campo(String nome) {
    final v = _item[nome];
    return v == null ? '' : '$v'.trim();
  }

  Object? bruto(String nome) => _item[nome];
}

/// Lê a lista colada. [chaveLista] aceita também `{"<chaveLista>": [...]}`;
/// [plural] vai nas mensagens ("questões", "cartões"). [invalido] monta o
/// item de um elemento que não é objeto, e [lerItem], o dos demais.
/// [materiaPadrao], [topicoPadrao] e [subtopicoPadrao] preenchem o que
/// faltar (a tela do tópico já sabe onde o item fica).
LeituraColagem<T> lerColagem<T extends ItemColado>(
  String texto, {
  required String plural,
  required String chaveLista,
  required T Function(int indice, List<String> erros) invalido,
  required T Function(int indice, CamposItem c) lerItem,
  String? materiaPadrao,
  String? topicoPadrao,
  String? subtopicoPadrao,
}) {
  final fonte = recortarJson(texto);
  if (fonte == null) {
    return LeituraColagem(
      [],
      erro: 'Cole uma lista de $plural em JSON, começando com "[".',
    );
  }
  final Object? dados;
  try {
    dados = jsonDecode(fonte);
  } on FormatException catch (e) {
    return LeituraColagem([], erro: 'JSON inválido: ${_explicar(e, fonte)}');
  }
  final lista = dados is List
      ? dados
      : dados is Map && dados[chaveLista] is List
      ? dados[chaveLista] as List
      : dados is Map
      ? [dados]
      : null;
  if (lista == null || lista.isEmpty) {
    return LeituraColagem([], erro: 'A lista de $plural está vazia.');
  }

  final itens = <T>[];
  for (final (i, item) in lista.indexed) {
    if (item is! Map) {
      itens.add(invalido(i + 1, ['não é um objeto { ... }']));
      continue;
    }
    String campo(String nome) {
      final v = item[nome];
      return v == null ? '' : '$v'.trim();
    }

    var materia = campo('materia');
    if (materia.isEmpty) materia = materiaPadrao ?? '';
    var topico = campo('topico');
    var subtopico = campo('subtopico');
    if (topico.isEmpty && topicoPadrao != null) {
      topico = topicoPadrao;
      if (subtopico.isEmpty) subtopico = subtopicoPadrao ?? '';
    }
    materia = materia.isEmpty ? '' : nomeOficialMateria(materia);
    itens.add(lerItem(i + 1, CamposItem._(item, materia, topico, subtopico)));
  }

  // Repetidos dentro da própria lista: vale o primeiro.
  final vistas = <String>{};
  for (final q in itens) {
    if (!q.valida) continue;
    if (!vistas.add(q.chave)) q.repetida = true;
  }
  return LeituraColagem(itens);
}

/// Tira cercas de código e texto em volta: do primeiro "[" (ou "{") ao
/// último "]" (ou "}").
String? recortarJson(String texto) {
  final t = texto.trim();
  if (t.isEmpty) return null;
  final ic = t.indexOf('['), ichave = t.indexOf('{');
  final usaLista = ic >= 0 && (ichave < 0 || ic < ichave);
  final ini = usaLista ? ic : ichave;
  if (ini < 0) return null;
  final fim = t.lastIndexOf(usaLista ? ']' : '}');
  if (fim <= ini) return t.substring(ini);
  return t.substring(ini, fim + 1);
}

String _explicar(FormatException e, String fonte) {
  final off = e.offset;
  if (off == null || off > fonte.length) return 'confira vírgulas e aspas.';
  final linha = '\n'.allMatches(fonte.substring(0, off)).length + 1;
  return 'perto da linha $linha (falta vírgula, aspas ou chave?).';
}
