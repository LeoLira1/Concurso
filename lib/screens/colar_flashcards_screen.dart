import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/flashcards_colagem_db.dart';
import '../logic/flashcards_colados.dart';
import 'colar_screen.dart';

/// Exemplo mostrado na tela (e no README).
const exemploFlashcardsJson =
    '''[{"materia":"Língua Portuguesa","topico":"Concordância nominal e verbal","subtopico":"Verbo haver","frente":"Quando o verbo haver fica no singular?","verso":"Quando significa existir ou indica tempo decorrido. Ex.: Havia muitos candidatos."}]''';

final tipoFlashcards = TipoColagem<FlashcardColado>(
  chave: 'flashcards',
  titulo: 'Colar flashcards',
  singular: 'cartão',
  plural: 'cartões',
  feminino: false,
  rotulo: 'Cartão',
  exemplo: exemploFlashcardsJson,
  instrucao:
      'Cole a lista de flashcards em JSON. Antes de importar, você vê a '
      'prévia. Tópicos que não existem no edital são criados, e cartões '
      'com a mesma frente não são duplicados.',
  campos: 'materia, topico, subtopico (opcional), frente e verso',
  ler: lerFlashcards,
  marcar: (db, l) => db.marcarFlashcardsRepetidos(l),
  importar: (db, l, concursoId) =>
      db.importarFlashcards(l, concursoId: concursoId),
  texto: (c) => c.frente,
  detalhes: (c) {
    final v = c.verso.replaceAll(RegExp(r'\s+'), ' ');
    return ['verso: ${v.length > 90 ? '${v.substring(0, 87)}…' : v}'];
  },
);

/// "Colar flashcards" (ver [ColarScreen]).
class ColarFlashcardsScreen extends StatelessWidget {
  const ColarFlashcardsScreen({
    super.key,
    this.materiaPadrao,
    this.topicoPadrao,
    this.subtopicoPadrao,
    this.concursoId,
    this.textoInicial,
  });

  final String? materiaPadrao;
  final String? topicoPadrao;
  final String? subtopicoPadrao;

  /// Edital que recebe os tópicos novos (nulo = "Tudo junto").
  final String? concursoId;
  final String? textoInicial;

  @override
  Widget build(BuildContext context) => ColarScreen<FlashcardColado>(
    tipo: tipoFlashcards,
    materiaPadrao: materiaPadrao,
    topicoPadrao: topicoPadrao,
    subtopicoPadrao: subtopicoPadrao,
    concursoId: concursoId,
    textoInicial: textoInicial,
  );
}

/// Abre "Colar flashcards" a partir de um tópico (o que faltar no JSON vai
/// para ele) ou de uma matéria.
Future<void> abrirColarFlashcards(
  BuildContext context, {
  required Materia materia,
  Topico? topico,
  String? concursoId,
}) async {
  final d = await destinoPadrao(context.read<AppDatabase>(), topico);
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ColarFlashcardsScreen(
        materiaPadrao: materia.nome,
        topicoPadrao: d.topico,
        subtopicoPadrao: d.subtopico,
        concursoId: concursoId,
      ),
    ),
  );
}
