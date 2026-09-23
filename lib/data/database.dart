import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../logic/ciclo.dart';
import '../logic/flashcards.dart';
import '../logic/importar_edital.dart';
import '../theme.dart' show Cores;
import '../util/texto.dart';
import 'exemplo_guarda_municipal.dart';
import 'streams.dart';
import 'sync/infra.dart';
import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

/// Matéria com o progresso agregado (tópicos-folha vistos / total).
class MateriaInfo {
  MateriaInfo(
    this.materia,
    this.total,
    this.vistos,
    this.ordem, {
    this.peso = 3,
    this.dificuldade = 3,
    this.noCiclo = true,
  });
  final Materia materia;
  final int total;
  final int vistos;
  final int ordem;

  /// Peso e dificuldade (1–5) no ciclo do concurso consultado.
  final int peso;
  final int dificuldade;
  final bool noCiclo;

  double get progresso => total == 0 ? 0 : vistos / total;
}

class ProgressoConcurso {
  const ProgressoConcurso(this.materias, this.total, this.vistos);
  final int materias;
  final int total;
  final int vistos;
  double get progresso => total == 0 ? 0 : vistos / total;
}

@DriftDatabase(
  tables: [
    Concursos,
    Materias,
    ConcursoMaterias,
    Topicos,
    Revisoes,
    Questoes,
    Sessoes,
    Anexos,
    Flashcards,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'edital'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, de, para) async {
      if (de < 2) {
        await m.addColumn(concursos, concursos.cicloMinutos);
        await m.addColumn(concursos, concursos.cicloBlocoMin);
        await m.addColumn(concursos, concursos.cicloPosicao);
        await m.addColumn(concursos, concursos.cicloVoltas);
        await m.addColumn(concursoMaterias, concursoMaterias.peso);
        await m.addColumn(concursoMaterias, concursoMaterias.dificuldade);
        await m.addColumn(concursoMaterias, concursoMaterias.noCiclo);
      }
      if (de < 3) {
        await m.addColumn(sessoes, sessoes.metodo);
        await m.addColumn(sessoes, sessoes.questoesFeitas);
        await m.addColumn(sessoes, sessoes.questoesAcertos);
        await m.addColumn(sessoes, sessoes.paginas);
        await m.addColumn(sessoes, sessoes.pontoParada);
      }
      if (de < 4) {
        await m.createTable(anexos);
        await m.createTable(flashcards);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      for (final c in comandosInfraSync()) {
        await customStatement(c);
      }
    },
  );

  // ---------------------------------------------------------------------------
  // Concursos
  // ---------------------------------------------------------------------------

  Stream<List<Concurso>> watchConcursos() =>
      (select(concursos)..orderBy([
            (c) => OrderingTerm.desc(c.foco),
            (c) => OrderingTerm.asc(c.ordem),
            (c) => OrderingTerm.asc(c.criadoEm),
          ]))
          .watch();

  Stream<Concurso?> watchConcurso(String id) =>
      (select(concursos)..where((c) => c.id.equals(id))).watchSingleOrNull();

  Stream<Concurso?> watchFoco() =>
      (select(concursos)..where((c) => c.foco.equals(true))).watch().map(
        (l) => l.isEmpty ? null : l.first,
      );

  /// Progresso por concurso: considera só tópicos-folha (sem subtópicos).
  Stream<Map<String, ProgressoConcurso>> watchProgressoConcursos() {
    return customSelect(
      '''
      SELECT cm.concurso_id AS cid,
             COUNT(DISTINCT cm.materia_id) AS mats,
             COUNT(t.id) AS total,
             COALESCE(SUM(t.visto), 0) AS vistos
      FROM concurso_materias cm
      LEFT JOIN topicos t ON t.materia_id = cm.materia_id
        AND NOT EXISTS (SELECT 1 FROM topicos f WHERE f.pai_id = t.id)
      GROUP BY cm.concurso_id
      ''',
      readsFrom: {concursoMaterias, topicos},
    ).watch().map(
      (rows) => {
        for (final r in rows)
          r.read<String>('cid'): ProgressoConcurso(
            r.read<int>('mats'),
            r.read<int>('total'),
            r.read<int>('vistos'),
          ),
      },
    );
  }

  Future<String> criarConcurso({
    required String nome,
    String banca = '',
    DateTime? dataProva,
    required int cor,
    bool exemplo = false,
  }) async {
    return transaction(() async {
      final temFoco = await (select(
        concursos,
      )..where((c) => c.foco.equals(true))).get();
      final row = await into(concursos).insertReturning(
        ConcursosCompanion.insert(
          nome: nome.trim(),
          banca: Value(banca.trim()),
          dataProva: Value(dataProva),
          cor: cor,
          foco: Value(temFoco.isEmpty),
          exemplo: Value(exemplo),
        ),
      );
      return row.id;
    });
  }

  Future<void> atualizarConcurso(
    String id, {
    required String nome,
    required String banca,
    required DateTime? dataProva,
    required int cor,
  }) {
    return (update(concursos)..where((c) => c.id.equals(id))).write(
      ConcursosCompanion(
        nome: Value(nome.trim()),
        banca: Value(banca.trim()),
        dataProva: Value(dataProva),
        cor: Value(cor),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  Future<void> definirFoco(String id) {
    return transaction(() async {
      await update(concursos)
          .write(const ConcursosCompanion(foco: Value(false)));
      await (update(concursos)..where((c) => c.id.equals(id))).write(
        ConcursosCompanion(
          foco: const Value(true),
          atualizadoEm: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> excluirConcurso(String id) {
    return transaction(() async {
      final eraFoco =
          (await (select(
            concursos,
          )..where((c) => c.id.equals(id))).getSingleOrNull())?.foco ??
          false;
      await (delete(concursos)..where((c) => c.id.equals(id))).go();
      await _limparMateriasOrfas();
      if (eraFoco) {
        final outro =
            await (select(concursos)
                  ..orderBy([(c) => OrderingTerm.asc(c.criadoEm)])
                  ..limit(1))
                .getSingleOrNull();
        if (outro != null) {
          await (update(concursos)..where((c) => c.id.equals(outro.id))).write(
            const ConcursosCompanion(foco: Value(true)),
          );
        }
      }
    });
  }

  /// Matérias que não pertencem a nenhum concurso são apagadas
  /// (junto com tópicos, revisões e questões, via cascade).
  Future<void> _limparMateriasOrfas() => customStatement(
    'DELETE FROM materias WHERE id NOT IN '
    '(SELECT materia_id FROM concurso_materias)',
  );

  // ---------------------------------------------------------------------------
  // Matérias
  // ---------------------------------------------------------------------------

  /// Matérias de um concurso (na ordem do edital) ou, com [concursoId] nulo,
  /// todas as matérias de todos os concursos (ordem alfabética).
  Stream<List<MateriaInfo>> watchMaterias(String? concursoId) {
    const progresso = '''
      (SELECT COUNT(*) FROM topicos t WHERE t.materia_id = m.id
         AND NOT EXISTS (SELECT 1 FROM topicos f WHERE f.pai_id = t.id)) AS total,
      (SELECT COUNT(*) FROM topicos t WHERE t.materia_id = m.id AND t.visto = 1
         AND NOT EXISTS (SELECT 1 FROM topicos f WHERE f.pai_id = t.id)) AS vistos
    ''';
    final query = concursoId == null
        ? customSelect(
            '''
            SELECT m.*, 0 AS ordem_cm, 3 AS peso_cm, 3 AS dif_cm, 1 AS ciclo_cm,
              $progresso
            FROM materias m
            WHERE m.id IN (SELECT materia_id FROM concurso_materias)
            ORDER BY m.nome COLLATE NOCASE
            ''',
            readsFrom: {materias, topicos, concursoMaterias},
          )
        : customSelect(
            '''
            SELECT m.*, cm.ordem AS ordem_cm, cm.peso AS peso_cm,
              cm.dificuldade AS dif_cm, cm.no_ciclo AS ciclo_cm, $progresso
            FROM materias m
            JOIN concurso_materias cm ON cm.materia_id = m.id
            WHERE cm.concurso_id = ?
            ORDER BY cm.ordem, m.nome COLLATE NOCASE
            ''',
            variables: [Variable.withString(concursoId)],
            readsFrom: {materias, topicos, concursoMaterias},
          );
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          MateriaInfo(
            materias.map(r.data),
            r.read<int>('total'),
            r.read<int>('vistos'),
            r.read<int>('ordem_cm'),
            peso: r.read<int>('peso_cm'),
            dificuldade: r.read<int>('dif_cm'),
            noCiclo: r.read<int>('ciclo_cm') == 1,
          ),
      ],
    );
  }

  Stream<Materia?> watchMateria(String id) =>
      (select(materias)..where((m) => m.id.equals(id))).watchSingleOrNull();

  Stream<List<Materia>> watchTodasMaterias() =>
      (select(materias)..orderBy([(m) => OrderingTerm.asc(m.nome)])).watch();

  Future<List<Materia>> todasMaterias() =>
      (select(materias)..orderBy([(m) => OrderingTerm.asc(m.nome)])).get();

  /// Concursos que usam a matéria (para mostrar que o progresso é compartilhado).
  Stream<List<Concurso>> watchConcursosDaMateria(String materiaId) {
    final q = select(concursos).join([
      innerJoin(
        concursoMaterias,
        concursoMaterias.concursoId.equalsExp(concursos.id),
      ),
    ])..where(concursoMaterias.materiaId.equals(materiaId));
    return q.watch().map(
      (rows) => rows.map((r) => r.readTable(concursos)).toList(),
    );
  }

  Future<Materia?> materiaPorNome(String nome) => (select(
    materias,
  )..where((m) => m.chave.equals(chaveMateria(nome)))).getSingleOrNull();

  /// Adiciona a matéria ao concurso. Se já existir uma matéria com o mesmo
  /// nome (em qualquer concurso), ela é reaproveitada.
  Future<String> adicionarMateria(String concursoId, String nome, int cor) {
    return transaction(() async {
      var materia = await materiaPorNome(nome);
      materia ??= await into(materias).insertReturning(
        MateriasCompanion.insert(
          nome: nome.trim(),
          chave: chaveMateria(nome),
          cor: cor,
        ),
      );
      final maxOrdem = await _maxOrdemMateria(concursoId);
      await into(concursoMaterias).insert(
        ConcursoMateriasCompanion.insert(
          concursoId: concursoId,
          materiaId: materia.id,
          ordem: Value(maxOrdem + 1),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      return materia.id;
    });
  }

  Future<int> _maxOrdemMateria(String concursoId) async {
    final r = await customSelect(
      'SELECT COALESCE(MAX(ordem), -1) AS m FROM concurso_materias WHERE concurso_id = ?',
      variables: [Variable.withString(concursoId)],
    ).getSingle();
    return r.read<int>('m');
  }

  /// Renomeia. Retorna `false` se já existe outra matéria com esse nome.
  Future<bool> renomearMateria(String id, String nome) async {
    final existente = await materiaPorNome(nome);
    if (existente != null && existente.id != id) return false;
    await (update(materias)..where((m) => m.id.equals(id))).write(
      MateriasCompanion(
        nome: Value(nome.trim()),
        chave: Value(chaveMateria(nome)),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
    return true;
  }

  Future<void> corMateria(String id, int cor) =>
      (update(materias)..where((m) => m.id.equals(id))).write(
        MateriasCompanion(cor: Value(cor), atualizadoEm: Value(DateTime.now())),
      );

  Future<void> removerMateriaDoConcurso(String concursoId, String materiaId) {
    return transaction(() async {
      await (delete(concursoMaterias)..where(
            (cm) =>
                cm.concursoId.equals(concursoId) &
                cm.materiaId.equals(materiaId),
          ))
          .go();
      await _limparMateriasOrfas();
    });
  }

  Future<void> reordenarMaterias(String concursoId, List<String> idsNaOrdem) {
    return batch((b) {
      for (var i = 0; i < idsNaOrdem.length; i++) {
        b.update(
          concursoMaterias,
          ConcursoMateriasCompanion(
            ordem: Value(i),
            atualizadoEm: Value(DateTime.now()),
          ),
          where: (cm) =>
              cm.concursoId.equals(concursoId) &
              cm.materiaId.equals(idsNaOrdem[i]),
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Ciclo de estudos
  // ---------------------------------------------------------------------------

  Future<void> definirPesoDificuldade(
    String concursoId,
    String materiaId, {
    int? peso,
    int? dificuldade,
    bool? noCiclo,
  }) {
    return (update(concursoMaterias)..where(
          (cm) =>
              cm.concursoId.equals(concursoId) & cm.materiaId.equals(materiaId),
        ))
        .write(
          ConcursoMateriasCompanion(
            peso: peso == null ? const Value.absent() : Value(peso.clamp(1, 5)),
            dificuldade: dificuldade == null
                ? const Value.absent()
                : Value(dificuldade.clamp(1, 5)),
            noCiclo: noCiclo == null ? const Value.absent() : Value(noCiclo),
            atualizadoEm: Value(DateTime.now()),
          ),
        );
  }

  Future<void> configurarCiclo(
    String concursoId, {
    int? minutosTotais,
    int? blocoMin,
  }) {
    return (update(concursos)..where((c) => c.id.equals(concursoId))).write(
      ConcursosCompanion(
        cicloMinutos: minutosTotais == null
            ? const Value.absent()
            : Value(minutosTotais.clamp(60, 6000)),
        cicloBlocoMin: blocoMin == null
            ? const Value.absent()
            : Value(blocoMin.clamp(15, 240)),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  /// Vai para a próxima etapa do ciclo (fila circular de [tamanho] etapas).
  Future<void> avancarCiclo(String concursoId, int tamanho) {
    return transaction(() async {
      final c = await (select(
        concursos,
      )..where((c) => c.id.equals(concursoId))).getSingle();
      if (tamanho <= 0) return;
      final atual = c.cicloPosicao % tamanho;
      final virou = atual + 1 >= tamanho;
      await (update(concursos)..where((x) => x.id.equals(concursoId))).write(
        ConcursosCompanion(
          cicloPosicao: Value(virou ? 0 : atual + 1),
          cicloVoltas: Value(c.cicloVoltas + (virou ? 1 : 0)),
          atualizadoEm: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> irParaEtapa(String concursoId, int posicao) =>
      (update(concursos)..where((c) => c.id.equals(concursoId))).write(
        ConcursosCompanion(
          cicloPosicao: Value(posicao),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  Future<void> reiniciarCiclo(String concursoId) =>
      (update(concursos)..where((c) => c.id.equals(concursoId))).write(
        ConcursosCompanion(
          cicloPosicao: const Value(0),
          cicloVoltas: const Value(0),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  /// Fila do ciclo de um concurso, recalculada sempre que o concurso ou as
  /// matérias mudam.
  Stream<EstadoCiclo> watchCiclo(String concursoId) {
    return combinarUltimos(
      watchConcurso(concursoId),
      watchMaterias(concursoId),
      EstadoCiclo.calcular,
    );
  }

  // ---------------------------------------------------------------------------
  // Tópicos
  // ---------------------------------------------------------------------------

  Stream<List<Topico>> watchTopicos(String materiaId) =>
      (select(topicos)
            ..where((t) => t.materiaId.equals(materiaId))
            ..orderBy([(t) => OrderingTerm.asc(t.ordem)]))
          .watch();

  Stream<List<Topico>> watchTodosTopicos() =>
      (select(topicos)..orderBy([(t) => OrderingTerm.asc(t.ordem)])).watch();

  Future<String> adicionarTopico(
    String materiaId,
    String nome, {
    String? paiId,
  }) async {
    final r = await customSelect(
      'SELECT COALESCE(MAX(ordem), -1) AS m FROM topicos WHERE materia_id = ? AND '
      '${paiId == null ? 'pai_id IS NULL' : 'pai_id = ?'}',
      variables: [
        Variable.withString(materiaId),
        if (paiId != null) Variable.withString(paiId),
      ],
    ).getSingle();
    final row = await into(topicos).insertReturning(
      TopicosCompanion.insert(
        materiaId: materiaId,
        nome: nome.trim(),
        paiId: Value(paiId),
        ordem: Value(r.read<int>('m') + 1),
      ),
    );
    return row.id;
  }

  /// Adiciona vários tópicos de uma vez: uma linha por tópico; linhas
  /// iniciadas por "-", "•", "*" ou recuo viram subtópicos do anterior.
  Future<void> adicionarTopicosEmLote(String materiaId, String texto) {
    return transaction(() async {
      String? ultimoPai;
      for (final linha in texto.split('\n')) {
        if (linha.trim().isEmpty) continue;
        final sub =
            RegExp(r'^(\s+|\s*[-•*–]\s*)').hasMatch(linha) && ultimoPai != null;
        final nome = linha.replaceFirst(RegExp(r'^\s*[-•*–]?\s*'), '').trim();
        if (nome.isEmpty) continue;
        if (sub) {
          await adicionarTopico(materiaId, nome, paiId: ultimoPai);
        } else {
          ultimoPai = await adicionarTopico(materiaId, nome);
        }
      }
    });
  }

  Future<void> renomearTopico(String id, String nome) =>
      (update(topicos)..where((t) => t.id.equals(id))).write(
        TopicosCompanion(
          nome: Value(nome.trim()),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  Future<void> excluirTopico(String id) =>
      (delete(topicos)..where((t) => t.id.equals(id))).go();

  Future<void> reordenarTopicos(List<String> idsNaOrdem) {
    return batch((b) {
      for (var i = 0; i < idsNaOrdem.length; i++) {
        b.update(
          topicos,
          TopicosCompanion(
            ordem: Value(i),
            atualizadoEm: Value(DateTime.now()),
          ),
          where: (t) => t.id.equals(idsNaOrdem[i]),
        );
      }
    });
  }

  static const intervalosRevisao = [1, 7, 30];

  /// Marca/desmarca "visto". Ao marcar, agenda revisões em 1, 7 e 30 dias.
  /// Ao desmarcar, remove as revisões ainda não feitas.
  Future<void> marcarVisto(String id, bool visto) {
    return transaction(() async {
      final agora = DateTime.now();
      await (update(topicos)..where((t) => t.id.equals(id))).write(
        TopicosCompanion(
          visto: Value(visto),
          vistoEm: Value(visto ? agora : null),
          atualizadoEm: Value(agora),
        ),
      );
      await (delete(
        revisoes,
      )..where((r) => r.topicoId.equals(id) & r.feitaEm.isNull())).go();
      if (visto) {
        final hoje = soDia(agora);
        for (final d in intervalosRevisao) {
          await into(revisoes).insert(
            RevisoesCompanion.insert(
              topicoId: id,
              dataPrevista: hoje.add(Duration(days: d)),
              intervaloDias: d,
            ),
          );
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Revisões
  // ---------------------------------------------------------------------------

  JoinedSelectStatement<HasResultSet, dynamic> _consultaRevisoes(DateTime ate) {
    return select(revisoes).join([
        innerJoin(topicos, topicos.id.equalsExp(revisoes.topicoId)),
        innerJoin(materias, materias.id.equalsExp(topicos.materiaId)),
      ])
      ..where(
        revisoes.feitaEm.isNull() &
            revisoes.dataPrevista.isSmallerOrEqualValue(ate),
      )
      ..orderBy([
        OrderingTerm.asc(revisoes.dataPrevista),
        OrderingTerm.asc(materias.nome),
      ]);
  }

  List<RevisaoInfo> _lerRevisoes(List<TypedResult> rows) => [
    for (final r in rows)
      RevisaoInfo(
        r.readTable(revisoes),
        r.readTable(topicos),
        r.readTable(materias),
      ),
  ];

  /// Revisões ainda não feitas com data até [ate] (inclui as atrasadas).
  Stream<List<RevisaoInfo>> watchRevisoesPendentes(DateTime ate) =>
      _consultaRevisoes(ate).watch().map(_lerRevisoes);

  Future<List<RevisaoInfo>> revisoesPendentes(DateTime ate) async =>
      _lerRevisoes(await _consultaRevisoes(ate).get());

  Future<void> concluirRevisao(String id) =>
      (update(revisoes)..where((r) => r.id.equals(id))).write(
        RevisoesCompanion(
          feitaEm: Value(DateTime.now()),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  /// Marca como feitas as revisões do tópico vencidas até [ate].
  Future<void> concluirRevisoesDoTopico(String topicoId, DateTime ate) =>
      (update(revisoes)..where(
            (r) =>
                r.topicoId.equals(topicoId) &
                r.feitaEm.isNull() &
                r.dataPrevista.isSmallerOrEqualValue(ate),
          ))
          .write(
            RevisoesCompanion(
              feitaEm: Value(DateTime.now()),
              atualizadoEm: Value(DateTime.now()),
            ),
          );

  Future<bool> estudouNoDia(DateTime dia) async {
    final d = soDia(dia);
    final l =
        await (select(sessoes)
              ..where((s) => s.dia.equals(d))
              ..limit(1))
            .get();
    return l.isNotEmpty;
  }

  /// Dispara sempre que algo que afeta os lembretes muda.
  Stream<void> watchMudancasLembretes() => customSelect(
    'SELECT 1',
    readsFrom: {
      revisoes,
      sessoes,
      concursos,
      concursoMaterias,
      materias,
      topicos,
    },
  ).watch().map((_) {});

  // ---------------------------------------------------------------------------
  // Anexos
  // ---------------------------------------------------------------------------

  Stream<List<Anexo>> watchAnexos(String topicoId) =>
      (select(anexos)
            ..where((a) => a.topicoId.equals(topicoId))
            ..orderBy([(a) => OrderingTerm.desc(a.criadoEm)]))
          .watch();

  Future<void> adicionarAnexo({
    required String topicoId,
    required String tipo,
    required String nome,
    required String arquivo,
    int bytes = 0,
  }) => into(anexos).insert(
    AnexosCompanion.insert(
      topicoId: topicoId,
      tipo: tipo,
      nome: nome,
      arquivo: arquivo,
      bytes: Value(bytes),
    ),
  );

  Future<void> renomearAnexo(String id, String nome) =>
      (update(anexos)..where((a) => a.id.equals(id))).write(
        AnexosCompanion(
          nome: Value(nome.trim()),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  Future<void> excluirAnexo(String id) =>
      (delete(anexos)..where((a) => a.id.equals(id))).go();

  /// Nomes de arquivo ainda referenciados (para limpar órfãos no disco).
  Future<Set<String>> arquivosDeAnexos() async => {
    for (final a in await select(anexos).get()) a.arquivo,
  };

  // ---------------------------------------------------------------------------
  // Flashcards
  // ---------------------------------------------------------------------------

  Stream<List<Flashcard>> watchFlashcards(String topicoId) =>
      (select(flashcards)
            ..where((f) => f.topicoId.equals(topicoId))
            ..orderBy([
              (f) => OrderingTerm.asc(f.ordem),
              (f) => OrderingTerm.asc(f.criadoEm),
            ]))
          .watch();

  Future<void> salvarFlashcard({
    String? id,
    required String topicoId,
    required String frente,
    required String verso,
  }) async {
    if (id != null) {
      await (update(flashcards)..where((f) => f.id.equals(id))).write(
        FlashcardsCompanion(
          frente: Value(frente.trim()),
          verso: Value(verso.trim()),
          atualizadoEm: Value(DateTime.now()),
        ),
      );
      return;
    }
    final r = await customSelect(
      'SELECT COALESCE(MAX(ordem), -1) AS m FROM flashcards WHERE topico_id = ?',
      variables: [Variable.withString(topicoId)],
    ).getSingle();
    await into(flashcards).insert(
      FlashcardsCompanion.insert(
        topicoId: topicoId,
        frente: frente.trim(),
        verso: verso.trim(),
        ordem: Value(r.read<int>('m') + 1),
        proximaRevisao: Value(soDia(DateTime.now())),
      ),
    );
  }

  Future<void> excluirFlashcard(String id) =>
      (delete(flashcards)..where((f) => f.id.equals(id))).go();

  Future<void> responderFlashcard(Flashcard f, {required bool acertou}) {
    final r = responderCartao(
      caixaAtual: f.caixa,
      acertou: acertou,
      hoje: DateTime.now(),
    );
    return (update(flashcards)..where((x) => x.id.equals(f.id))).write(
      FlashcardsCompanion(
        caixa: Value(r.caixa),
        proximaRevisao: Value(r.proxima),
        acertos: Value(f.acertos + (acertou ? 1 : 0)),
        erros: Value(f.erros + (acertou ? 0 : 1)),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  /// Cartões para revisar até [ate] (hoje, por padrão), com tópico e matéria.
  /// Filtra por tópico ou matéria quando informados.
  Stream<List<CartaoInfo>> watchCartoesParaRevisar({
    String? topicoId,
    String? materiaId,
    DateTime? ate,
  }) {
    final limite = soDia(ate ?? DateTime.now());
    final q =
        select(flashcards).join([
            innerJoin(topicos, topicos.id.equalsExp(flashcards.topicoId)),
            innerJoin(materias, materias.id.equalsExp(topicos.materiaId)),
          ])
          ..where(flashcards.proximaRevisao.isSmallerOrEqualValue(limite))
          ..orderBy([
            OrderingTerm.asc(flashcards.proximaRevisao),
            OrderingTerm.asc(flashcards.caixa),
            OrderingTerm.asc(flashcards.ordem),
          ]);
    if (topicoId != null) q.where(flashcards.topicoId.equals(topicoId));
    if (materiaId != null) q.where(topicos.materiaId.equals(materiaId));
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          CartaoInfo(
            r.readTable(flashcards),
            r.readTable(topicos),
            r.readTable(materias),
          ),
      ],
    );
  }

  /// Quantidade de anexos e cartões por tópico (para os ícones da lista).
  Stream<Map<String, (int, int)>> watchContagemExtras(String materiaId) {
    return customSelect(
      '''
      SELECT t.id AS id,
        (SELECT COUNT(*) FROM anexos a WHERE a.topico_id = t.id) AS anexos,
        (SELECT COUNT(*) FROM flashcards f WHERE f.topico_id = t.id) AS cartoes
      FROM topicos t WHERE t.materia_id = ?
      ''',
      variables: [Variable.withString(materiaId)],
      readsFrom: {topicos, anexos, flashcards},
    ).watch().map(
      (rows) => {
        for (final r in rows)
          r.read<String>('id'): (r.read<int>('anexos'), r.read<int>('cartoes')),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Sessões
  // ---------------------------------------------------------------------------

  Stream<List<Sessao>> watchSessoes(DateTime de, DateTime ate) =>
      (select(sessoes)
            ..where((s) => s.dia.isBetweenValues(de, ate))
            ..orderBy([(s) => OrderingTerm.asc(s.inicio)]))
          .watch();

  Stream<List<Sessao>> watchTodasSessoes() => select(sessoes).watch();

  /// Sessões de um tópico, da mais recente para a mais antiga.
  Stream<List<Sessao>> watchSessoesDoTopico(String topicoId) =>
      (select(sessoes)
            ..where((s) => s.topicoId.equals(topicoId))
            ..orderBy([
              (s) => OrderingTerm.desc(s.dia),
              (s) => OrderingTerm.desc(s.inicio),
            ]))
          .watch();

  Stream<List<Revisao>> watchRevisoesDoTopico(String topicoId) =>
      (select(revisoes)
            ..where((r) => r.topicoId.equals(topicoId))
            ..orderBy([(r) => OrderingTerm.asc(r.dataPrevista)]))
          .watch();

  Future<void> registrarSessao({
    required DateTime dia,
    required int minutos,
    String? materiaId,
    String? topicoId,
    String? metodo,
    int questoesFeitas = 0,
    int questoesAcertos = 0,
    int paginas = 0,
    String? pontoParada,
  }) {
    final parada = pontoParada?.trim();
    return into(sessoes).insert(
      SessoesCompanion.insert(
        dia: soDia(dia),
        minutos: minutos,
        materiaId: Value(materiaId),
        topicoId: Value(topicoId),
        metodo: Value(metodo),
        questoesFeitas: Value(questoesFeitas < 0 ? 0 : questoesFeitas),
        questoesAcertos: Value(
          questoesAcertos.clamp(0, questoesFeitas < 0 ? 0 : questoesFeitas),
        ),
        paginas: Value(paginas < 0 ? 0 : paginas),
        pontoParada: Value(parada == null || parada.isEmpty ? null : parada),
      ),
    );
  }

  /// Última sessão da matéria que deixou um ponto de parada.
  Stream<Sessao?> watchUltimaParada(String materiaId) =>
      (select(sessoes)
            ..where(
              (s) => s.materiaId.equals(materiaId) & s.pontoParada.isNotNull(),
            )
            ..orderBy([
              (s) => OrderingTerm.desc(s.inicio),
              // Desempate: datas têm precisão de segundos.
              (_) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
            ])
            ..limit(1))
          .watchSingleOrNull();

  /// Última sessão registrada da matéria (para sugerir o tópico).
  Future<Sessao?> ultimaSessao(String materiaId) =>
      (select(sessoes)
            ..where((s) => s.materiaId.equals(materiaId))
            ..orderBy([
              (s) => OrderingTerm.desc(s.inicio),
              // Desempate: datas têm precisão de segundos.
              (_) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<Topico?> topico(String id) =>
      (select(topicos)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> excluirSessao(String id) =>
      (delete(sessoes)..where((s) => s.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Importar conteúdo programático
  // ---------------------------------------------------------------------------

  /// Adiciona as matérias e tópicos separados do edital ao concurso.
  /// Matérias que já existem (mesmo nome) são reaproveitadas e tópicos com o
  /// mesmo nome no mesmo nível não são duplicados.
  /// Retorna (matérias, tópicos novos).
  Future<(int, int)> importarConteudo(
    String concursoId,
    List<MateriaImportada> itens,
  ) {
    return transaction(() async {
      final cores = {for (final m in await select(materias).get()) m.cor};
      var nMaterias = 0, nTopicos = 0;

      Future<void> inserir(
        String materiaId,
        String? paiId,
        List<TopicoImportado> lista,
      ) async {
        final existentes =
            await (select(topicos)..where(
                  (t) =>
                      t.materiaId.equals(materiaId) &
                      (paiId == null
                          ? t.paiId.isNull()
                          : t.paiId.equals(paiId)),
                ))
                .get();
        final porNome = {for (final t in existentes) chaveTexto(t.nome): t.id};
        for (final t in lista) {
          var id = porNome[chaveTexto(t.nome)];
          if (id == null) {
            id = await adicionarTopico(materiaId, t.nome, paiId: paiId);
            porNome[chaveTexto(t.nome)] = id;
            nTopicos++;
          }
          if (t.filhos.isNotEmpty) await inserir(materiaId, id, t.filhos);
        }
      }

      for (final m in itens) {
        if (!m.incluir || m.nome.trim().isEmpty) continue;
        final existente = await materiaPorNome(m.nome);
        final cor = existente?.cor ?? Cores.proximaCor(cores);
        cores.add(cor);
        final id = await adicionarMateria(concursoId, m.nome, cor);
        nMaterias++;
        await inserir(id, null, m.topicos);
      }
      return (nMaterias, nTopicos);
    });
  }

  // ---------------------------------------------------------------------------
  // Exemplo
  // ---------------------------------------------------------------------------

  Future<bool> temExemplo() async => (await (select(
    concursos,
  )..where((c) => c.exemplo.equals(true))).get()).isNotEmpty;

  Future<void> carregarExemplo() => transaction(() async {
    final id = await criarConcurso(
      nome: exemploGuardaMunicipal.nome,
      banca: exemploGuardaMunicipal.banca,
      cor: exemploGuardaMunicipal.cor,
      exemplo: true,
    );
    for (final m in exemploGuardaMunicipal.materias) {
      final existente = await materiaPorNome(m.nome);
      final mid = await adicionarMateria(id, m.nome, m.cor);
      if (existente != null) continue; // já tem tópicos próprios
      await adicionarTopicosEmLote(mid, m.topicos);
    }
  });
}

/// Fila do ciclo + onde o concurso está nela.
class EstadoCiclo {
  EstadoCiclo._(this.concurso, this.fila, this.materias);

  factory EstadoCiclo.calcular(Concurso? c, List<MateriaInfo> materias) {
    if (c == null) return EstadoCiclo._(null, const [], const {});
    final entradas = [
      for (final m in materias)
        if (m.noCiclo)
          EntradaCiclo(
            materiaId: m.materia.id,
            peso: m.peso,
            dificuldade: m.dificuldade,
          ),
    ];
    final fila = gerarCiclo(
      entradas,
      minutosTotais: c.cicloMinutos,
      blocoMin: c.cicloBlocoMin,
    );
    return EstadoCiclo._(c, fila, {for (final m in materias) m.materia.id: m});
  }

  final Concurso? concurso;
  final List<ItemCiclo> fila;
  final Map<String, MateriaInfo> materias;

  bool get vazio => fila.isEmpty;
  int get posicao =>
      fila.isEmpty ? 0 : (concurso?.cicloPosicao ?? 0) % fila.length;
  ItemCiclo? get atual => fila.isEmpty ? null : fila[posicao];

  /// As próximas [n] etapas depois da atual (dando a volta na fila).
  List<ItemCiclo> proximas(int n) => [
    for (var i = 1; i <= n && i < fila.length; i++)
      fila[(posicao + i) % fila.length],
  ];

  Materia? materiaDe(ItemCiclo it) => materias[it.materiaId]?.materia;
}

class RevisaoInfo {
  const RevisaoInfo(this.revisao, this.topico, this.materia);
  final Revisao revisao;
  final Topico topico;
  final Materia materia;
}

class CartaoInfo {
  const CartaoInfo(this.cartao, this.topico, this.materia);
  final Flashcard cartao;
  final Topico topico;
  final Materia materia;
}
