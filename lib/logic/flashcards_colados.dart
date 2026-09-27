/// "Colar flashcards" (etapa 9): leitura do JSON colado.
///
/// Formato aceito (uma lista; um objeto só também serve):
/// ```json
/// [{"materia":"Língua Portuguesa","topico":"Concordância nominal e verbal",
///   "subtopico":"Verbo haver","frente":"Quando o verbo haver fica no
///   singular?","verso":"Quando significa existir..."}]
/// ```
library;

import 'colagem.dart';
import 'importar_edital.dart' show chaveTexto;

export 'colagem.dart' show ItemColado, LeituraColagem;

/// Frente normalizada: o mesmo cartão colado de novo (com outra pontuação,
/// acento ou maiúscula) não é duplicado.
String chaveFrente(String frente) => chaveTexto(frente);

/// Um flashcard lido do JSON.
class FlashcardColado extends ItemColado {
  FlashcardColado({
    required super.indice,
    required super.materia,
    required super.topico,
    required super.subtopico,
    required this.frente,
    required this.verso,
    required super.erros,
  });

  final String frente;
  final String verso;

  @override
  String get chave => chaveFrente(frente);
}

typedef LeituraFlashcards = LeituraColagem<FlashcardColado>;

/// Lê o JSON colado. [materiaPadrao], [topicoPadrao] e [subtopicoPadrao]
/// preenchem o que faltar (na tela do tópico, o cartão vai para ele).
LeituraFlashcards lerFlashcards(
  String texto, {
  String? materiaPadrao,
  String? topicoPadrao,
  String? subtopicoPadrao,
}) => lerColagem(
  texto,
  plural: 'flashcards',
  chaveLista: 'flashcards',
  materiaPadrao: materiaPadrao,
  topicoPadrao: topicoPadrao,
  subtopicoPadrao: subtopicoPadrao,
  invalido: (i, erros) => FlashcardColado(
    indice: i,
    materia: '',
    topico: '',
    subtopico: '',
    frente: '',
    verso: '',
    erros: erros,
  ),
  lerItem: (i, c) {
    final frente = c.campo('frente');
    final verso = c.campo('verso');
    return FlashcardColado(
      indice: i,
      materia: c.materia,
      topico: c.topico,
      subtopico: c.subtopico,
      frente: frente,
      verso: verso,
      erros: [
        ...c.erros,
        if (frente.isEmpty) 'falta a frente',
        if (verso.isEmpty) 'falta o verso',
      ],
    );
  },
);
