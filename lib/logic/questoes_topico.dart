/// Banco de questões por tópico (etapa 8): leitura do JSON colado e a fila
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

import 'colagem.dart';
import 'importar_edital.dart' show chaveTexto;

export 'colagem.dart' show ItemColado, LeituraColagem;

/// Chave que identifica a questão: enunciado E alternativas normalizados
/// (sem maiúsculas, acentos, espaços extras e pontuação).
/// Duas questões com o mesmo enunciado genérico ("Assinale a alternativa
/// correta") e alternativas diferentes não são repetidas; a mesma questão
/// colada de novo (mudando só maiúscula, acento ou espaço) é.
String chaveQuestao(String enunciado, Map<String, String> alternativas) {
  final letras = alternativas.keys.toList()..sort();
  return [
    chaveTexto(enunciado),
    for (final l in letras)
      '${l.trim().toUpperCase()}) ${chaveTexto(alternativas[l]!)}',
  ].join('\n');
}

/// Uma questão lida do JSON.
class QuestaoColada extends ItemColado {
  QuestaoColada({
    required super.indice,
    required super.materia,
    required super.topico,
    required super.subtopico,
    required this.dificuldade,
    required this.enunciado,
    required this.alternativas,
    required this.gabarito,
    required this.explicacao,
    required super.erros,
  });

  final int dificuldade;
  final String enunciado;
  final Map<String, String> alternativas;
  final String gabarito;
  final String explicacao;

  @override
  String get chave => chaveQuestao(enunciado, alternativas);
}

/// Resultado da leitura das questões coladas.
typedef LeituraQuestoes = LeituraColagem<QuestaoColada>;

extension LeituraQuestoesX on LeituraQuestoes {
  List<QuestaoColada> get questoes => itens;
}

/// Lê o JSON colado. [materiaPadrao], [topicoPadrao] e [subtopicoPadrao]
/// preenchem o que faltar (a tela do tópico já sabe onde a questão fica).
/// Aceita o JSON cercado de ``` ou de texto (copiado de um chat).
LeituraQuestoes lerQuestoes(
  String texto, {
  String? materiaPadrao,
  String? topicoPadrao,
  String? subtopicoPadrao,
}) => lerColagem(
  texto,
  plural: 'questões',
  chaveLista: 'questoes',
  materiaPadrao: materiaPadrao,
  topicoPadrao: topicoPadrao,
  subtopicoPadrao: subtopicoPadrao,
  invalido: (i, erros) => QuestaoColada(
    indice: i,
    materia: '',
    topico: '',
    subtopico: '',
    dificuldade: 3,
    enunciado: '',
    alternativas: const {},
    gabarito: '',
    explicacao: '',
    erros: erros,
  ),
  lerItem: _lerItem,
);

QuestaoColada _lerItem(int indice, CamposItem c) {
  final erros = [...c.erros];
  final enunciado = c.campo('enunciado');
  if (enunciado.isEmpty) erros.add('falta o enunciado');

  final alternativas = <String, String>{};
  final alts = c.bruto('alternativas');
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

  final gabarito = c.campo('gabarito').toUpperCase();
  if (gabarito.isEmpty) {
    erros.add('falta o gabarito');
  } else if (ordenadas.length >= 2 && !ordenadas.containsKey(gabarito)) {
    erros.add('gabarito "$gabarito" não está entre as alternativas');
  }

  final difBruta = c.bruto('dificuldade');
  final dif = difBruta is num
      ? difBruta.round()
      : int.tryParse('${difBruta ?? ''}'.trim()) ?? 3;

  return QuestaoColada(
    indice: indice,
    materia: c.materia,
    topico: c.topico,
    subtopico: c.subtopico,
    dificuldade: dif.clamp(1, 5),
    enunciado: enunciado,
    alternativas: ordenadas,
    gabarito: gabarito,
    explicacao: c.campo('explicacao'),
    erros: erros,
  );
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
