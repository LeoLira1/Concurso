/// Banco de questões por tópico (etapa 7): leitura do JSON colado e a fila
/// do "Resolver questões".
///
/// Formato aceito (uma lista; um objeto só também serve):
/// ```json
/// [{"materia":"Língua Portuguesa","topico":"Conjunções",
///   "subtopico":"Adversativas","dificuldade":2,"enunciado":"...",
///   "alternativas":{"A":"...","B":"...","C":"...","D":"...","E":"..."},
///   "gabarito":"C","explicacao":"..."}]
/// ```
library;

import 'dart:convert';

import 'importar_edital.dart' show chaveTexto;
import 'provas.dart' show nomeOficialMateria;

/// Enunciado normalizado: a mesma questão colada de novo (com outra
/// pontuação, acento ou quebra de linha) não é duplicada.
String chaveEnunciado(String enunciado) => chaveTexto(enunciado);

/// Uma questão lida do JSON.
class QuestaoColada {
  QuestaoColada({
    required this.indice,
    required this.materia,
    required this.topico,
    required this.subtopico,
    required this.dificuldade,
    required this.enunciado,
    required this.alternativas,
    required this.gabarito,
    required this.explicacao,
    required this.erros,
  });

  /// Posição na lista colada (1, 2, 3...).
  final int indice;
  final String materia;
  final String topico;

  /// Vazio = a questão fica no próprio tópico.
  final String subtopico;
  final int dificuldade;
  final String enunciado;
  final Map<String, String> alternativas;
  final String gabarito;
  final String explicacao;

  /// Problemas que impedem importar esta questão.
  final List<String> erros;

  /// Preenchido na prévia: já existe no banco (ou repete outra da lista).
  bool repetida = false;

  bool get valida => erros.isEmpty;
  bool get entra => valida && !repetida;
  String get chave => chaveEnunciado(enunciado);
}

/// Resultado da leitura do texto colado.
class LeituraQuestoes {
  const LeituraQuestoes(this.questoes, {this.erro});

  final List<QuestaoColada> questoes;

  /// Erro geral (JSON inválido, lista vazia...). Nulo = leu.
  final String? erro;

  int get validas => questoes.where((q) => q.valida).length;
  int get novas => questoes.where((q) => q.entra).length;
  int get repetidas => questoes.where((q) => q.valida && q.repetida).length;
  int get comErro => questoes.where((q) => !q.valida).length;
}

/// Lê o JSON colado. [materiaPadrao], [topicoPadrao] e [subtopicoPadrao]
/// preenchem o que faltar (a tela do tópico já sabe onde a questão fica).
/// Aceita o JSON cercado de ``` ou de texto (copiado de um chat).
LeituraQuestoes lerQuestoes(
  String texto, {
  String? materiaPadrao,
  String? topicoPadrao,
  String? subtopicoPadrao,
}) {
  final fonte = _recortarJson(texto);
  if (fonte == null) {
    return const LeituraQuestoes(
      [],
      erro: 'Cole uma lista de questões em JSON, começando com "[".',
    );
  }
  final Object? dados;
  try {
    dados = jsonDecode(fonte);
  } on FormatException catch (e) {
    return LeituraQuestoes([], erro: 'JSON inválido: ${_explicar(e, fonte)}');
  }
  final lista = dados is List
      ? dados
      : dados is Map && dados['questoes'] is List
      ? dados['questoes'] as List
      : dados is Map
      ? [dados]
      : null;
  if (lista == null || lista.isEmpty) {
    return const LeituraQuestoes([], erro: 'Nenhuma questão no texto colado.');
  }

  final questoes = <QuestaoColada>[];
  for (final (i, item) in lista.indexed) {
    if (item is! Map) {
      questoes.add(
        QuestaoColada(
          indice: i + 1,
          materia: '',
          topico: '',
          subtopico: '',
          dificuldade: 3,
          enunciado: '',
          alternativas: const {},
          gabarito: '',
          explicacao: '',
          erros: ['não é um objeto { ... }'],
        ),
      );
      continue;
    }
    questoes.add(
      _lerItem(
        i + 1,
        item,
        materiaPadrao: materiaPadrao,
        topicoPadrao: topicoPadrao,
        subtopicoPadrao: subtopicoPadrao,
      ),
    );
  }

  // Repetidas dentro da própria lista: vale a primeira.
  final vistas = <String>{};
  for (final q in questoes) {
    if (!q.valida) continue;
    if (!vistas.add(q.chave)) q.repetida = true;
  }
  return LeituraQuestoes(questoes);
}

QuestaoColada _lerItem(
  int indice,
  Map item, {
  String? materiaPadrao,
  String? topicoPadrao,
  String? subtopicoPadrao,
}) {
  String campo(String nome) {
    final v = item[nome];
    return v == null ? '' : '$v'.trim();
  }

  final erros = <String>[];
  var materia = campo('materia');
  if (materia.isEmpty) materia = materiaPadrao ?? '';
  var topico = campo('topico');
  var subtopico = campo('subtopico');
  if (topico.isEmpty && topicoPadrao != null) {
    topico = topicoPadrao;
    if (subtopico.isEmpty) subtopico = subtopicoPadrao ?? '';
  }
  materia = materia.isEmpty ? '' : nomeOficialMateria(materia);
  if (materia.isEmpty) erros.add('falta a matéria');
  if (topico.isEmpty) erros.add('falta o tópico');

  final enunciado = campo('enunciado');
  if (enunciado.isEmpty) erros.add('falta o enunciado');

  final alternativas = <String, String>{};
  final alts = item['alternativas'];
  if (alts is Map) {
    for (final e in alts.entries) {
      final letra = '${e.key}'.trim().toUpperCase();
      final texto = e.value == null ? '' : '${e.value}'.trim();
      if (letra.isNotEmpty) alternativas[letra] = texto;
    }
  } else if (alts is List) {
    // ["...", "..."] vira A, B, C...
    for (final (i, a) in alts.indexed) {
      alternativas[String.fromCharCode(65 + i)] = '$a'.trim();
    }
  }
  final ordenadas = Map.fromEntries(
    alternativas.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
  if (ordenadas.length < 2) {
    erros.add('precisa de pelo menos 2 alternativas');
  } else if (ordenadas.values.any((t) => t.isEmpty)) {
    final vazias = [
      for (final e in ordenadas.entries)
        if (e.value.isEmpty) e.key,
    ];
    erros.add('alternativa ${vazias.join(', ')} sem texto');
  }

  final gabarito = campo('gabarito').toUpperCase();
  if (gabarito.isEmpty) {
    erros.add('falta o gabarito');
  } else if (ordenadas.length >= 2 && !ordenadas.containsKey(gabarito)) {
    erros.add('gabarito "$gabarito" não está entre as alternativas');
  }

  final difBruta = item['dificuldade'];
  final dif = difBruta is num
      ? difBruta.round()
      : int.tryParse('${difBruta ?? ''}'.trim()) ?? 3;

  return QuestaoColada(
    indice: indice,
    materia: materia,
    topico: topico,
    subtopico: subtopico,
    dificuldade: dif.clamp(1, 5),
    enunciado: enunciado,
    alternativas: ordenadas,
    gabarito: gabarito,
    explicacao: campo('explicacao'),
    erros: erros,
  );
}

/// Tira cercas de código e texto em volta: do primeiro "[" (ou "{") ao
/// último "]" (ou "}").
String? _recortarJson(String texto) {
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

// -----------------------------------------------------------------------------
// Fila do "Resolver questões"
// -----------------------------------------------------------------------------

/// Ordem da sessão: primeiro as que venceram (as mais atrasadas e de caixa
/// mais baixa, ou seja, as que você mais erra), depois as novas, das mais
/// fáceis para as mais difíceis. Com [todas], entram também as que ainda
/// não venceram, no fim.
List<T> montarFila<T>(
  List<T> itens, {
  required DateTime Function(T) proxima,
  required int Function(T) caixa,
  required int Function(T) dificuldade,
  required bool Function(T) nova,
  required DateTime hoje,
  bool todas = false,
}) {
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  bool vence(T x) => !proxima(x).isAfter(dia);
  final vencidas =
      [
        for (final x in itens)
          if (vence(x) && !nova(x)) x,
      ]..sort((a, b) {
        final c = caixa(a).compareTo(caixa(b));
        return c != 0 ? c : proxima(a).compareTo(proxima(b));
      });
  final novas = [
    for (final x in itens)
      if (nova(x) && (todas || vence(x))) x,
  ]..sort((a, b) => dificuldade(a).compareTo(dificuldade(b)));
  final futuras = !todas
      ? <T>[]
      : ([
          for (final x in itens)
            if (!vence(x) && !nova(x)) x,
        ]..sort((a, b) => proxima(a).compareTo(proxima(b))));
  return [...vencidas, ...novas, ...futuras];
}
