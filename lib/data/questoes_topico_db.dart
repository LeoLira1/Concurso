import 'dart:convert';

import 'package:drift/drift.dart';

import '../logic/flashcards.dart' show responderCartao;
import '../logic/questoes_topico.dart';
import '../util/texto.dart';
import 'colagem_db.dart';
import 'database.dart';

export 'colagem_db.dart' show DestinoColagem, ResultadoColagem, ColagemDb;

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

/// Uma questão respondida no "Resolver questões" (para a sessão de estudo).
typedef RespostaTopico = ({
  String materiaId,
  String topicoId,
  bool acertou,
  int segundos,
});

extension QuestoesTopicoDb on AppDatabase {
  // ---------------------------------------------------------------------------
  // Colar questões (a parte comum fica em colagem_db.dart)
  // ---------------------------------------------------------------------------

  /// Marca as questões que já estão no banco (mesmo enunciado E mesmas
  /// alternativas). A chave é recalculada aqui, e não lida da coluna
  /// `chave`, porque as questões antigas foram gravadas só com o enunciado.
  Future<void> marcarRepetidas(LeituraQuestoes l) async {
    final chaves = <String, String>{};
    for (final r in await customSelect(
      'SELECT q.enunciado, q.alternativas, t.nome, p.nome AS pai '
      'FROM questoes_topico q JOIN topicos t ON t.id = q.topico_id '
      'LEFT JOIN topicos p ON p.id = t.pai_id ORDER BY q.criado_em, q.rowid',
      readsFrom: {questoesTopico, topicos},
    ).get()) {
      final enunciado = r.read<String>('enunciado');
      final alts = Map<String, String>.from(
        jsonDecode(r.read<String>('alternativas')) as Map,
      );
      final pai = r.read<String?>('pai');
      final nome = r.read<String>('nome');
      chaves.putIfAbsent(
        chaveQuestao(enunciado, alts),
        () => descreverRepetido(pai == null ? nome : '$pai › $nome', enunciado),
      );
    }
    marcarRepetidos(l, chaves);
  }

  /// Importa as questões válidas e não repetidas (ver [importarColagem]).
  Future<ResultadoColagem> importarQuestoesTopico(
    LeituraQuestoes l, {
    String? concursoId,
  }) {
    final hoje = soDia(DateTime.now());
    return importarColagem(
      l,
      concursoId: concursoId,
      marcar: () => marcarRepetidas(l),
      inserir: (q, topicoId) => into(questoesTopico).insert(
        QuestoesTopicoCompanion.insert(
          topicoId: topicoId,
          chave: q.chave,
          dificuldade: Value(q.dificuldade),
          enunciado: q.enunciado,
          alternativas: jsonEncode(q.alternativas),
          gabarito: q.gabarito,
          explicacao: Value(q.explicacao),
          proximaRevisao: Value(hoje),
        ),
      ),
    );
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

  /// Total de questões do banco por tópico (só as do próprio tópico, sem
  /// os subtópicos), para o indicador do mapa mental.
  Stream<Map<String, int>> watchQuestoesPorTopico() =>
      customSelect(
        'SELECT topico_id AS id, COUNT(*) AS n FROM questoes_topico '
        'GROUP BY topico_id',
        readsFrom: {questoesTopico},
      ).watch().map(
        (rows) => {
          for (final r in rows) r.read<String>('id'): r.read<int>('n'),
        },
      );

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
