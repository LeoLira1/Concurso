import '../logic/pedido_questoes.dart';
import 'database.dart';
import 'questoes_topico_db.dart';

extension PedidoDb on AppDatabase {
  /// Junta o que o "Pedir mais questões" precisa: o concurso [concursoId]
  /// (nulo = "Tudo junto"), os nomes exatos e o que já existe. Com
  /// [topico], o pedido é do tópico (um subtópico aberto vale pelo tópico
  /// de cima); sem ele, da matéria inteira, com os tópicos do edital.
  Future<ContextoPedido> contextoPedido({
    required Materia materia,
    Topico? topico,
    String? concursoId,
  }) async {
    final concurso = concursoId == null
        ? null
        : await watchConcurso(concursoId).first;
    // No tópico, todos os subtópicos dele; na matéria, o edital.
    final noEdital = await watchTopicos(
      materia.id,
      concursoId: concursoId,
      semFiltro: topico != null,
    ).first;

    Topico? pai;
    if (topico?.paiId case final id?) pai = await this.topico(id);
    final raizAberta = pai ?? topico;

    // Tópicos do pedido e, de cada tópico/subtópico, a raiz dele.
    final todos = {for (final t in noEdital) t.id: t};
    if (raizAberta != null) todos[raizAberta.id] = raizAberta;
    if (topico != null) todos[topico.id] = topico;
    Topico raizDe(Topico t) {
      var r = t;
      while (r.paiId != null && todos[r.paiId] != null) {
        r = todos[r.paiId]!;
      }
      return r;
    }

    final raizes = raizAberta != null
        ? [raizAberta]
        : [
            for (final t in noEdital)
              if (t.paiId == null) t,
          ];
    final idsRaiz = {for (final r in raizes) r.id};
    final subtopicos = <String, List<String>>{};
    for (final t in noEdital) {
      if (t.paiId == null) continue;
      final r = raizDe(t);
      if (idsRaiz.contains(r.id) && r.id != t.id) {
        (subtopicos[r.id] ??= []).add(t.nome);
      }
    }

    final questoes = raizAberta != null
        ? await watchQuestoesTopico(topicoId: raizAberta.id).first
        : await watchQuestoesTopico(
            materiaId: materia.id,
            concursoId: concursoId,
          ).first;
    final porRaiz = <String, List<QuestaoExistente>>{};
    for (final q in questoes) {
      final r = raizDe(q.topico);
      if (!idsRaiz.contains(r.id)) continue;
      final alt = q.alternativas;
      (porRaiz[r.id] ??= []).add(
        QuestaoExistente(
          enunciado: q.questao.enunciado,
          gabarito: q.questao.gabarito,
          respostaCerta: alt[q.questao.gabarito] ?? '',
          acertos: q.questao.acertos,
          erros: q.questao.erros,
          criadoEm: q.questao.criadoEm,
          subtopico: q.topico.id == r.id ? null : q.topico.nome,
          suspeito: q.questao.suspeito,
        ),
      );
    }

    final idsTopicos = {
      for (final t in todos.values)
        if (idsRaiz.contains(raizDe(t).id)) t.id,
    };
    final cartoes = await (select(
      flashcards,
    )..where((f) => f.topicoId.isIn(idsTopicos))).get();
    final flashPorRaiz = <String, List<FlashcardExistente>>{};
    for (final f in cartoes) {
      final t = todos[f.topicoId];
      if (t == null) continue;
      (flashPorRaiz[raizDe(t).id] ??= []).add(
        FlashcardExistente(frente: f.frente, criadoEm: f.criadoEm),
      );
    }

    return ContextoPedido(
      concurso: concurso?.nome,
      banca: concurso?.banca,
      materia: materia.nome,
      materiaInteira: raizAberta == null,
      subtopicoAberto: pai == null ? null : topico!.nome,
      topicos: [
        for (final r in raizes)
          TopicoPedido(
            nome: r.nome,
            subtopicos: subtopicos[r.id] ?? const [],
            questoes: porRaiz[r.id] ?? const [],
            flashcards: flashPorRaiz[r.id] ?? const [],
          ),
      ],
    );
  }
}
