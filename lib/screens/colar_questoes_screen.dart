import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../data/questoes_topico_db.dart';
import '../logic/questoes_topico.dart';
import 'colar_screen.dart';

/// Exemplo mostrado na tela (e no README).
const exemploQuestoesJson =
    '''[{"materia":"Língua Portuguesa","topico":"Conjunções","subtopico":"Adversativas","dificuldade":2,"enunciado":"...","alternativas":{"A":"...","B":"...","C":"...","D":"...","E":"..."},"gabarito":"C","explicacao":"..."}]''';

final tipoQuestoes = TipoColagem<QuestaoColada>(
  chave: 'questoes',
  titulo: 'Colar questões',
  singular: 'questão',
  plural: 'questões',
  feminino: true,
  rotulo: 'Questão',
  exemplo: exemploQuestoesJson,
  instrucao:
      'Cole a lista de questões em JSON. Antes de importar, você vê a '
      'prévia. Tópicos que não existem no edital são criados, e questões '
      'com o mesmo enunciado não são duplicadas.',
  campos:
      'materia, topico, subtopico (opcional), dificuldade (1 a 5), '
      'enunciado, alternativas (A a E), gabarito e explicacao',
  ler: lerQuestoes,
  marcar: (db, l) => db.marcarRepetidas(l),
  importar: (db, l, concursoId) =>
      db.importarQuestoesTopico(l, concursoId: concursoId),
  texto: (q) => q.enunciado,
  detalhes: (q) => [
    '${q.alternativas.length} alternativas',
    'gabarito ${q.gabarito}',
    'dificuldade ${q.dificuldade}',
    if (q.explicacao.isEmpty) 'sem explicação',
  ],
);

/// "Colar questões" (ver [ColarScreen]).
class ColarQuestoesScreen extends StatelessWidget {
  const ColarQuestoesScreen({
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
  Widget build(BuildContext context) => ColarScreen<QuestaoColada>(
    tipo: tipoQuestoes,
    materiaPadrao: materiaPadrao,
    topicoPadrao: topicoPadrao,
    subtopicoPadrao: subtopicoPadrao,
    concursoId: concursoId,
    textoInicial: textoInicial,
  );
}

/// Abre "Colar questões" a partir de um tópico (o que faltar no JSON vai
/// para ele) ou de uma matéria.
Future<void> abrirColarQuestoes(
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
      builder: (_) => ColarQuestoesScreen(
        materiaPadrao: materia.nome,
        topicoPadrao: d.topico,
        subtopicoPadrao: d.subtopico,
        concursoId: concursoId,
      ),
    ),
  );
}
