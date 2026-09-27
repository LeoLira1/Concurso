import 'dart:convert';

import 'package:drift/drift.dart';

import '../logic/flashcards.dart' show responderCartao;
import '../logic/importar_edital.dart' show chaveTexto;
import '../logic/questoes_topico.dart';
import '../theme.dart' show Cores;
import '../util/texto.dart';
import 'database.dart';

/// Questão por tópico com o tópico e a matéria (para a tela de resolver).
class QuestaoTopicoInfo {
  QuestaoTopicoInfo(this.questao, this.topico, this.materia, this.pai);
  QuestaoTopico questao;
  final Topico topico;
  final Materia materia;

  /// Tópico de cima, quando a questão está num subtópico.
  final Topico? pai;

  String get id => questao.id;
  Map<String, String> get alternativas =>
      Map<String, String>.from(jsonDecode(questao.alternativas) as Map);
  bool get nova => questao.acertos + questao.erros == 0;

  /// "Conjunções › Adversativas".
  String get caminho =>
      pai == null ? topico.nome : '${pai!.nome} › ${topico.nome}';
}

/// Onde cada questão colada vai parar (para a prévia).
class DestinoColagem {
  const DestinoColagem({
    required this.materiaNova,
    required this.topicoNovo,
    required this.subtopicoNovo,
    required this.entraNoEdital,
  });

  final bool materiaNova;

  /// O tópico não existe na matéria e será criado.
  final bool topicoNovo;
  final bool subtopicoNovo;

  /// O tópico existe, mas não está no edital do concurso: ganha o vínculo.
  final bool entraNoEdital;
}

/// Resultado de "Colar questões".
class ResultadoColagem {
  const ResultadoColagem({
    required this.novas,
    required this.repetidas,
    required this.topicosCriados,
    required this.materiasCriadas,
  });
  final int novas;
  final int repetidas;
  final List<String> topicosCriados;
  final List<String> materiasCriadas;
}

/// Uma questão respondida no "Resolver questões" (para a sessão de estudo).
typedef RespostaTopico = ({
  String materiaId,
  String topicoId,
  bool acertou,
  int segundos,
});

extension QuestoesTopicoDb on AppDatabase {
  // ---------------------------------------------------------------------------
  // Colar questões
  // ---------------------------------------------------------------------------

  /// Marca as questões cujo enunciado já está no banco.
  Future<void> marcarRepetidas(LeituraQuestoes l) async {
    final chaves = {
      for (final r in await customSelect(
        'SELECT chave FROM questoes_topico',
        readsFrom: {questoesTopico},
      ).get())
        r.read<String>('chave'),
    };
    for (final q in l.questoes) {
      if (q.valida && chaves.contains(q.chave)) q.repetida = true;
    }
  }

  /// Para a prévia: matéria, tópico e subtópico novos de cada questão
  /// (pelo índice). [concursoId] é o edital de destino (nulo = "Tudo junto").
  Future<Map<int, DestinoColagem>> destinosColagem(
    LeituraQuestoes l, {
    String? concursoId,
  }) async {
    final r = <int, DestinoColagem>{};
    final vinculos = concursoId == null
        ? const <String>{}
        : {
            for (final v in await (select(
              topicoConcursos,
            )..where((v) => v.concursoId.equals(concursoId))).get())
              v.topicoId,
          };
    for (final q in l.questoes) {
      if (!q.valida) continue;
      final m = await materiaPorNome(q.materia);
      final t = m == null ? null : await _topicoPorNome(m.id, null, q.topico);
      final s = t == null || q.subtopico.isEmpty
          ? null
          : await _topicoPorNome(m!.id, t.id, q.subtopico);
      r[q.indice] = DestinoColagem(
        materiaNova: m == null,
        topicoNovo: t == null,
        subtopicoNovo: q.subtopico.isNotEmpty && s == null,
        entraNoEdital:
            t != null && concursoId != null && !vinculos.contains(t.id),
      );
    }
    return r;
  }

  /// Importa as questões válidas e não repetidas. Matéria, tópico e
  /// subtópico que não existem são criados; o tópico entra no edital de
  /// [concursoId] (nulo = de todos os concursos que têm a matéria). Uma
  /// matéria nova entra em [concursoId] ou, sem ele, no concurso em foco.
  Future<ResultadoColagem> importarQuestoesTopico(
    LeituraQuestoes l, {
    String? concursoId,
  }) {
    return transaction(() async {
      await marcarRepetidas(l);
      final cores = {for (final m in await select(materias).get()) m.cor};
      final foco = await (select(
        concursos,
      )..where((c) => c.foco.equals(true))).getSingleOrNull();
      final topicosCriados = <String>[];
      final materiasCriadas = <String>[];
      var novas = 0;
      final hoje = soDia(DateTime.now());
      for (final q in l.questoes) {
        if (!q.entra) continue;

        // Matéria (e, com concurso, o vínculo dela com o concurso).
        var m = await materiaPorNome(q.materia);
        final destino = concursoId ?? foco?.id;
        if (m == null) {
          final cor = Cores.proximaCor(cores);
          cores.add(cor);
          if (destino != null) {
            await adicionarMateria(destino, q.materia, cor);
          } else {
            await into(materias).insert(
              MateriasCompanion.insert(
                nome: q.materia.trim(),
                chave: chaveMateria(q.materia),
                cor: cor,
              ),
            );
          }
          m = (await materiaPorNome(q.materia))!;
          materiasCriadas.add(m.nome);
        } else if (concursoId != null) {
          await adicionarMateria(concursoId, m.nome, m.cor);
        }

        // Tópico (criado ou posto no edital).
        var t = await _topicoPorNome(m.id, null, q.topico);
        if (t == null) {
          final id = await adicionarTopico(
            m.id,
            q.topico,
            concursoIds: concursoId == null ? null : [concursoId],
          );
          t = await topico(id);
          topicosCriados.add('${m.nome} · ${q.topico}');
        } else if (concursoId != null) {
          await vincular(t.id, concursoId);
        }

        // Subtópico.
        var alvo = t!;
        if (q.subtopico.isNotEmpty) {
          var s = await _topicoPorNome(m.id, t.id, q.subtopico);
          if (s == null) {
            s = await topico(
              await adicionarTopico(m.id, q.subtopico, paiId: t.id),
            );
            topicosCriados.add('${m.nome} · ${t.nome} › ${q.subtopico}');
          }
          alvo = s!;
        }

        await into(questoesTopico).insert(
          QuestoesTopicoCompanion.insert(
            topicoId: alvo.id,
            chave: q.chave,
            dificuldade: Value(q.dificuldade),
            enunciado: q.enunciado,
            alternativas: jsonEncode(q.alternativas),
            gabarito: q.gabarito,
            explicacao: Value(q.explicacao),
            proximaRevisao: Value(hoje),
          ),
        );
        novas++;
      }
      return ResultadoColagem(
        novas: novas,
        repetidas: l.repetidas,
        topicosCriados: topicosCriados,
        materiasCriadas: materiasCriadas,
      );
    });
  }

  /// Tópico com esse nome (ignorando acento e maiúscula) sob [paiId]
  /// (nulo = primeiro nível) na matéria.
  Future<Topico?> _topicoPorNome(
    String materiaId,
    String? paiId,
    String nome,
  ) async {
    final k = chaveTexto(nome);
    final q = select(topicos)
      ..where(
        (t) =>
            t.materiaId.equals(materiaId) &
            (paiId == null ? t.paiId.isNull() : t.paiId.equals(paiId)),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.ordem)]);
    for (final t in await q.get()) {
      if (chaveTexto(t.nome) == k) return t;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Consultas
  // ---------------------------------------------------------------------------

  /// Questões do tópico e dos subtópicos dele, ou da matéria (no edital de
  /// [concursoId]; nulo = em algum edital). Só as suspeitas com
  /// [soSuspeitas].
  Stream<List<QuestaoTopicoInfo>> watchQuestoesTopico({
    String? topicoId,
    String? materiaId,
    String? concursoId,
    bool soSuspeitas = false,
  }) {
    final onde = <String>[];
    final vars = <Variable>[];
    if (topicoId != null) {
      onde.add(
        '(t.id = ? OR t.pai_id = ? OR t.pai_id IN '
        '(SELECT id FROM topicos WHERE pai_id = ?))',
      );
      vars.addAll(List.filled(3, Variable.withString(topicoId)));
    } else {
      onde.add(
        sqlNoEdital('t', concursoId == null ? null : sqlTexto(concursoId)),
      );
    }
    if (materiaId != null) {
      onde.add('t.materia_id = ?');
      vars.add(Variable.withString(materiaId));
    }
    if (soSuspeitas) onde.add('q.suspeito = 1');
    return customSelect(
      '''
      SELECT q.id FROM questoes_topico q JOIN topicos t ON t.id = q.topico_id
      WHERE ${onde.join(' AND ')}
      ORDER BY t.materia_id, t.ordem, q.criado_em, q.rowid
      ''',
      variables: vars,
      readsFrom: {questoesTopico, topicos, topicoConcursos, materias},
    ).watch().asyncMap(
      (rows) => _infos([for (final r in rows) r.read<String>('id')]),
    );
  }

  Future<List<QuestaoTopicoInfo>> _infos(List<String> ids) async {
    if (ids.isEmpty) return [];
    final qs = {
      for (final q in await (select(
        questoesTopico,
      )..where((q) => q.id.isIn(ids))).get())
        q.id: q,
    };
    final tops = {for (final t in await select(topicos).get()) t.id: t};
    final mats = {for (final m in await select(materias).get()) m.id: m};
    return [
      for (final id in ids)
        if (qs[id] case final q?)
          if (tops[q.topicoId] case final t?)
            if (mats[t.materiaId] case final m?)
              QuestaoTopicoInfo(
                q,
                t,
                m,
                t.paiId == null ? null : tops[t.paiId],
              ),
    ];
  }

  /// Fila do "Resolver questões" (ver [montarFila]).
  Future<List<QuestaoTopicoInfo>> filaQuestoesTopico({
    String? topicoId,
    String? materiaId,
    String? concursoId,
    bool todas = false,
    DateTime? hoje,
  }) async {
    final l = await watchQuestoesTopico(
      topicoId: topicoId,
      materiaId: materiaId,
      concursoId: concursoId,
    ).first;
    return montarFila(
      l,
      proxima: (x) => x.questao.proximaRevisao,
      caixa: (x) => x.questao.caixa,
      dificuldade: (x) => x.questao.dificuldade,
      nova: (x) => x.nova,
      hoje: hoje ?? DateTime.now(),
      todas: todas,
    );
  }

  // ---------------------------------------------------------------------------
  // Resolver
  // ---------------------------------------------------------------------------

  /// Leitner igual aos flashcards: acertou, sobe uma caixa e volta em 1, 3,
  /// 7, 14 ou 30 dias; errou, volta para a caixa 0 (ainda hoje).
  Future<QuestaoTopico> responderQuestaoTopico(
    QuestaoTopico q, {
    required bool acertou,
    DateTime? hoje,
  }) async {
    final r = responderCartao(
      caixaAtual: q.caixa,
      acertou: acertou,
      hoje: hoje ?? DateTime.now(),
    );
    final nova = q.copyWith(
      caixa: r.caixa,
      proximaRevisao: r.proxima,
      acertos: q.acertos + (acertou ? 1 : 0),
      erros: q.erros + (acertou ? 0 : 1),
      atualizadoEm: DateTime.now(),
    );
    await (update(
      questoesTopico,
    )..where((x) => x.id.equals(q.id))).write(nova.toCompanion(false));
    return nova;
  }

  Future<void> marcarSuspeito(String id, bool suspeito) =>
      (update(questoesTopico)..where((q) => q.id.equals(id))).write(
        QuestoesTopicoCompanion(
          suspeito: Value(suspeito),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  /// Corrige o gabarito e tira o "suspeito".
  Future<void> corrigirGabarito(String id, String letra) =>
      (update(questoesTopico)..where((q) => q.id.equals(id))).write(
        QuestoesTopicoCompanion(
          gabarito: Value(letra),
          suspeito: const Value(false),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  Future<void> excluirQuestaoTopico(String id) =>
      (delete(questoesTopico)..where((q) => q.id.equals(id))).go();

  /// Grava a sessão de questões: uma sessão de estudo com método
  /// "Questões" por tópico, com questões feitas, acertos e o tempo gasto.
  /// Assim a % de acerto da matéria e do tópico (estatísticas e mapa
  /// mental) já conta. Cada questão conta uma vez só (a primeira resposta
  /// da sessão). Retorna os ids das matérias estudadas.
  Future<Set<String>> registrarSessaoQuestoesTopico(
    List<RespostaTopico> respostas, {
    DateTime? dia,
  }) {
    return transaction(() async {
      final grupos = <(String, String), List<RespostaTopico>>{};
      for (final r in respostas) {
        (grupos[(r.materiaId, r.topicoId)] ??= []).add(r);
      }
      var total = 0;
      final minutos = <(String, String), int>{};
      for (final e in grupos.entries) {
        final segs = e.value.fold<int>(0, (a, x) => a + x.segundos);
        total += minutos[e.key] = (segs + 30) ~/ 60;
      }
      // Sessão curta: pelo menos 1 minuto, no tópico com mais questões.
      if (total == 0 && grupos.isNotEmpty) {
        final maior = grupos.entries.reduce(
          (a, b) => b.value.length > a.value.length ? b : a,
        );
        minutos[maior.key] = 1;
      }
      for (final e in grupos.entries) {
        await registrarSessao(
          dia: dia ?? DateTime.now(),
          minutos: minutos[e.key]!,
          materiaId: e.key.$1,
          topicoId: e.key.$2,
          metodo: 'questoes',
          questoesFeitas: e.value.length,
          questoesAcertos: e.value.where((x) => x.acertou).length,
          origem: 'questoes_topico',
        );
      }
      return {for (final k in grupos.keys) k.$1};
    });
  }
}
