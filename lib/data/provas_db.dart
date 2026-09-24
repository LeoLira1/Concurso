import 'dart:convert';

import 'package:drift/drift.dart';

import '../logic/importar_edital.dart' show chaveTexto;
import '../logic/provas.dart';
import '../theme.dart' show Cores;
import '../util/texto.dart';
import 'database.dart';
import 'streams.dart';

/// Resultado de colar uma prova.
class ResultadoImportacao {
  ResultadoImportacao({
    required this.provaId,
    required this.provaNova,
    required this.novas,
    required this.repetidas,
    required this.mudancas,
    required this.materiasCriadas,
    required this.viraDefinitivo,
  });
  final String provaId;

  /// A prova não existia (senão, é continuação ou atualização).
  final bool provaNova;

  /// Questões inseridas agora.
  final int novas;

  /// Questões que já existiam e ficaram como estavam.
  final int repetidas;

  /// O que mudou na passagem de preliminar para definitivo.
  final List<String> mudancas;
  final List<String> materiasCriadas;
  final bool viraDefinitivo;
}

/// Questão com tudo o que a tela precisa.
class QuestaoCompleta {
  QuestaoCompleta({
    required this.questao,
    required this.prova,
    required this.materia,
    required this.topico,
    required this.texto,
    required this.feitas,
    required this.ultimaAcertou,
  });
  QuestaoProva questao;
  final Prova prova;
  final Materia materia;
  final Topico? topico;
  final TextoBase? texto;

  /// Respostas já dadas e se a última foi certa (nulo = nunca feita).
  final int feitas;
  final bool? ultimaAcertou;

  Set<String> get status => StatusQuestao.separar(questao.status);
  bool get anulada => status.contains(StatusQuestao.anulada);
  Map<String, String> get alternativas =>
      Map<String, String>.from(jsonDecode(questao.alternativas) as Map);
  String get id => questao.id;
}

/// Filtros do "Resolver".
class FiltroQuestoes {
  const FiltroQuestoes({
    this.concursoId,
    this.materiaId,
    this.topicoId,
    this.banca,
    this.ano,
    this.soErradas = false,
    this.soNuncaFeitas = false,
    this.incluirAnuladas = false,
    this.incluirDesatualizadas = false,
    this.incluirRevisar = false,
  });

  /// Nulo = "Tudo junto".
  final String? concursoId;
  final String? materiaId;
  final String? topicoId;
  final String? banca;
  final int? ano;
  final bool soErradas;
  final bool soNuncaFeitas;
  final bool incluirAnuladas;
  final bool incluirDesatualizadas;

  /// "revisar" ainda não conferidas.
  final bool incluirRevisar;

  bool aceita(QuestaoCompleta q) {
    final s = q.status;
    if (!incluirAnuladas && s.contains(StatusQuestao.anulada)) return false;
    if (!incluirDesatualizadas && s.contains(StatusQuestao.desatualizada)) {
      return false;
    }
    if (!incluirRevisar && s.contains(StatusQuestao.revisar)) return false;
    if (soNuncaFeitas && q.feitas > 0) return false;
    if (soErradas && q.ultimaAcertou != false) return false;
    return true;
  }
}

/// Uma resposta com o que as estatísticas precisam.
class RespostaInfo {
  const RespostaInfo({
    required this.resposta,
    required this.questaoId,
    required this.numero,
    required this.provaId,
    required this.materiaId,
    required this.topicoId,
    required this.banca,
    required this.ano,
    required this.anulada,
  });
  final Resposta resposta;
  final String questaoId;
  final int numero;
  final String provaId;
  final String materiaId;
  final String? topicoId;
  final String banca;
  final int ano;

  /// Anuladas nunca contam como acerto nem erro.
  final bool anulada;
}

/// Prova com contagens (tela de gerenciar).
class ProvaResumo {
  const ProvaResumo(this.prova, this.questoes, this.respostas);
  final Prova prova;
  final int questoes;
  final int respostas;
}

/// Condição SQL do escopo: com concurso, o tópico da questão está no
/// edital dele, ou a questão está "sem tópico" e a matéria faz parte do
/// concurso. Sem concurso ("Tudo junto"), todas.
String sqlQuestaoNoEscopo(String q, String? concursoId) {
  if (concursoId == null) return '1';
  final c = sqlTexto(concursoId);
  return '(($q.topico_id IS NOT NULL AND EXISTS (SELECT 1 FROM topicos tq '
      'WHERE tq.id = $q.topico_id AND ${sqlNoEdital('tq', c)})) OR '
      '($q.topico_id IS NULL AND $q.materia_id IN (SELECT materia_id FROM '
      'concurso_materias WHERE concurso_id = $c)))';
}

extension ProvasDb on AppDatabase {
  // ---------------------------------------------------------------------------
  // Colar prova
  // ---------------------------------------------------------------------------

  Future<Prova?> provaPorChave(String chave) =>
      (select(provas)
            ..where((p) => p.chave.equals(chave))
            ..orderBy([(p) => OrderingTerm.asc(p.criadoEm)])
            ..limit(1))
          .getSingleOrNull();

  /// Liga cada questão ao tópico mais parecido da matéria (quando a
  /// semelhança é boa) e devolve as sugestões das que ficaram sem tópico.
  Future<Map<int, List<CandidatoTopico>>> ligarTopicos(ProvaImportada p) async {
    final sugestoes = <int, List<CandidatoTopico>>{};
    final cache = <String, List<({String id, String nome})>>{};
    for (final q in p.questoes) {
      final m = await materiaPorNome(nomeOficialMateria(q.materia));
      final lista = m == null
          ? const <({String id, String nome})>[]
          : cache[m.id] ??= [
              for (final t in await (select(
                topicos,
              )..where((t) => t.materiaId.equals(m.id))).get())
                (id: t.id, nome: t.nome),
            ];
      final cands = candidatosTopico(q.topico, lista);
      sugestoes[q.numero] = cands.take(4).toList();
      if (q.topicoDecidido) continue;
      final melhor = melhorTopico(cands);
      q.topicoId = melhor?.id;
      q.criarTopico = false;
    }
    return sugestoes;
  }

  /// Importa a prova (já validada e com as divergências decididas).
  /// Não duplica: questão com o mesmo número na mesma prova é pulada.
  /// Se o gabarito novo é definitivo e o salvo é preliminar, as respostas
  /// e os status das questões que já existiam são atualizados.
  Future<ResultadoImportacao> importarProva(ProvaImportada p) {
    return transaction(() async {
      final existente = await provaPorChave(p.chave);
      final viraDefinitivo =
          existente != null &&
          existente.gabarito != 'definitivo' &&
          p.definitivo;

      // Prova
      final String provaId;
      if (existente == null) {
        provaId = (await into(provas).insertReturning(
          ProvasCompanion.insert(
            banca: p.banca,
            orgao: p.orgao,
            cargo: p.cargo,
            ano: p.ano,
            chave: p.chave,
            gabarito: p.gabarito,
            numAlternativas: p.numAlternativas,
            totalQuestoes: p.totalQuestoes,
            gabaritoLido: Value(_gabaritoJson(p.gabaritoLido)),
            descartadas: Value(_descartadasJson(p.descartadas)),
          ),
        )).id;
      } else {
        provaId = existente.id;
        final gab = {
          for (final e in (jsonDecode(existente.gabaritoLido) as Map).entries)
            int.parse('${e.key}'): '${e.value}',
        };
        // O gabarito definitivo prevalece sobre o preliminar.
        if (viraDefinitivo || existente.gabarito == p.gabarito) {
          gab.addAll(p.gabaritoLido);
        } else {
          for (final e in p.gabaritoLido.entries) {
            gab.putIfAbsent(e.key, () => e.value);
          }
        }
        final desc = {
          for (final d in jsonDecode(existente.descartadas) as List)
            (d['numero'] as num).toInt(): Descartada(
              (d['numero'] as num).toInt(),
              '${d['motivo']}',
            ),
        };
        for (final d in p.descartadas) {
          desc[d.numero] = d;
        }
        await (update(provas)..where((x) => x.id.equals(provaId))).write(
          ProvasCompanion(
            gabarito: Value(viraDefinitivo ? 'definitivo' : existente.gabarito),
            totalQuestoes: Value(
              p.totalQuestoes > existente.totalQuestoes
                  ? p.totalQuestoes
                  : existente.totalQuestoes,
            ),
            gabaritoLido: Value(_gabaritoJson(gab)),
            descartadas: Value(
              _descartadasJson(
                desc.values.toList()
                  ..sort((a, b) => a.numero.compareTo(b.numero)),
              ),
            ),
            atualizadoEm: Value(DateTime.now()),
          ),
        );
      }

      // Textos-base (reaproveita pelo código).
      final textosExistentes = {
        for (final t in await (select(
          textosBase,
        )..where((t) => t.provaId.equals(provaId))).get())
          t.codigo: t.id,
      };
      for (final t in p.textos) {
        if (textosExistentes.containsKey(t.id)) continue;
        textosExistentes[t.id] = (await into(textosBase).insertReturning(
          TextosBaseCompanion.insert(
            provaId: provaId,
            codigo: t.id,
            titulo: Value(t.titulo),
            conteudo: t.conteudo,
          ),
        )).id;
      }

      // Matérias (novas não entram em nenhum concurso).
      final cores = {for (final m in await select(materias).get()) m.cor};
      final materiaIds = <String, String>{};
      final criadas = <String>[];
      Future<String> materiaDe(String nome) async {
        final oficial = nomeOficialMateria(nome);
        final k = chaveMateria(oficial);
        if (materiaIds.containsKey(k)) return materiaIds[k]!;
        var m = await materiaPorNome(oficial);
        if (m == null) {
          final cor = Cores.proximaCor(cores);
          cores.add(cor);
          m = await into(materias).insertReturning(
            MateriasCompanion.insert(nome: oficial, chave: k, cor: cor),
          );
          criadas.add(oficial);
        }
        return materiaIds[k] = m.id;
      }

      final salvas = {
        for (final q in await (select(
          questoesProva,
        )..where((q) => q.provaId.equals(provaId))).get())
          q.numero: q,
      };
      var novas = 0, repetidas = 0;
      final mudancas = <String>[];
      for (final q in p.questoes) {
        final ja = salvas[q.numero];
        final status = StatusQuestao.juntar(q.status);
        if (ja != null) {
          if (viraDefinitivo) {
            final antes = StatusQuestao.separar(ja.status);
            final partes = [
              if (ja.resposta != q.resposta)
                'resposta ${ja.resposta} → ${q.resposta}',
              if (!antes.contains(StatusQuestao.anulada) && q.anulada)
                'anulada',
              if (antes.contains(StatusQuestao.anulada) && !q.anulada)
                'deixou de ser anulada',
            ];
            if (partes.isNotEmpty) {
              mudancas.add('Questão ${q.numero}: ${partes.join(', ')}');
            }
            await (update(
              questoesProva,
            )..where((x) => x.id.equals(ja.id))).write(
              QuestoesProvaCompanion(
                resposta: Value(q.resposta),
                status: Value(status),
                obs: Value(q.obs),
                atualizadoEm: Value(DateTime.now()),
              ),
            );
          } else {
            repetidas++;
          }
          continue;
        }
        final materiaId = await materiaDe(q.materia);
        String? topicoId = q.topicoId;
        if (topicoId == null && q.criarTopico && q.topico.trim().isNotEmpty) {
          topicoId = await _topicoPorNomeOuNovo(materiaId, q.topico);
        }
        await into(questoesProva).insert(
          QuestoesProvaCompanion.insert(
            provaId: provaId,
            numero: q.numero,
            textoId: Value(
              q.textoId == null ? null : textosExistentes[q.textoId],
            ),
            materiaId: materiaId,
            topicoId: Value(topicoId),
            topicoOriginal: Value(q.topicoOriginal),
            enunciado: q.enunciado,
            alternativas: jsonEncode(q.alternativas),
            resposta: q.resposta,
            status: Value(status),
            obs: Value(q.obs),
          ),
        );
        novas++;
      }
      return ResultadoImportacao(
        provaId: provaId,
        provaNova: existente == null,
        novas: novas,
        repetidas: repetidas,
        mudancas: mudancas,
        materiasCriadas: criadas,
        viraDefinitivo: viraDefinitivo,
      );
    });
  }

  /// Tópico de primeiro nível com esse nome na matéria, ou um novo (que
  /// entra no edital dos concursos que têm a matéria).
  Future<String> _topicoPorNomeOuNovo(String materiaId, String nome) async {
    final k = chaveTexto(nome);
    for (final t in await (select(
      topicos,
    )..where((t) => t.materiaId.equals(materiaId))).get()) {
      if (chaveTexto(t.nome) == k) return t.id;
    }
    return adicionarTopico(materiaId, nome);
  }

  // ---------------------------------------------------------------------------
  // Gerenciar provas
  // ---------------------------------------------------------------------------

  Stream<List<ProvaResumo>> watchProvas() =>
      customSelect(
        '''
    SELECT p.*,
      (SELECT COUNT(*) FROM questoes_prova q WHERE q.prova_id = p.id) AS nq,
      (SELECT COUNT(*) FROM respostas r JOIN questoes_prova q
         ON q.id = r.questao_id WHERE q.prova_id = p.id) AS nr
    FROM provas p ORDER BY p.ano DESC, p.orgao
    ''',
        readsFrom: {provas, questoesProva, respostas},
      ).watch().map(
        (rows) => [
          for (final r in rows)
            ProvaResumo(
              provas.map(r.data),
              r.read<int>('nq'),
              r.read<int>('nr'),
            ),
        ],
      );

  /// Exclui a prova inteira: textos, questões, respostas e prints saem
  /// junto (e, com eles, das estatísticas).
  Future<void> excluirProva(String id) =>
      (delete(provas)..where((p) => p.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Resolver
  // ---------------------------------------------------------------------------

  /// Questões no escopo e nos filtros de banco (matéria, tópico, banca,
  /// ano). Os filtros de status e de histórico ficam em [FiltroQuestoes.aceita].
  Future<List<QuestaoCompleta>> questoesCompletas({
    FiltroQuestoes filtro = const FiltroQuestoes(),
    Iterable<String>? ids,
  }) async {
    final onde = <String>[sqlQuestaoNoEscopo('q', filtro.concursoId)];
    final vars = <Variable>[];
    if (filtro.materiaId != null) {
      onde.add('q.materia_id = ?');
      vars.add(Variable.withString(filtro.materiaId!));
    }
    if (filtro.topicoId != null) {
      // O tópico e os subtópicos dele.
      onde.add(
        '(q.topico_id = ? OR q.topico_id IN (SELECT id FROM topicos WHERE '
        'pai_id = ? OR pai_id IN (SELECT id FROM topicos WHERE pai_id = ?)))',
      );
      vars.addAll(List.filled(3, Variable.withString(filtro.topicoId!)));
    }
    if (filtro.banca != null) {
      onde.add('p.banca = ?');
      vars.add(Variable.withString(filtro.banca!));
    }
    if (filtro.ano != null) {
      onde.add('p.ano = ?');
      vars.add(Variable.withInt(filtro.ano!));
    }
    if (ids != null) {
      final l = ids.toList();
      if (l.isEmpty) return [];
      onde.add('q.id IN (${l.map(sqlTexto).join(', ')})');
    }
    final rows = await customSelect(
      '''
      SELECT q.id AS qid, q.prova_id, q.numero, q.texto_id, q.materia_id,
        q.topico_id, q.topico_original, q.enunciado, q.alternativas,
        q.resposta, q.status, q.obs, q.atualizado_em AS q_atualizado_em,
        (SELECT COUNT(*) FROM respostas r WHERE r.questao_id = q.id) AS feitas,
        (SELECT r.acertou FROM respostas r WHERE r.questao_id = q.id
           ORDER BY r.data DESC, r.rowid DESC LIMIT 1) AS ultima
      FROM questoes_prova q JOIN provas p ON p.id = q.prova_id
      WHERE ${onde.join(' AND ')}
      ORDER BY p.ano DESC, p.id, q.numero
      ''',
      variables: vars,
      readsFrom: {questoesProva, provas, respostas, topicos, topicoConcursos},
    ).get();
    if (rows.isEmpty) return [];

    final provasPorId = {for (final p in await select(provas).get()) p.id: p};
    final mats = {for (final m in await select(materias).get()) m.id: m};
    final tops = {for (final t in await select(topicos).get()) t.id: t};
    final txts = {for (final t in await select(textosBase).get()) t.id: t};
    return [
      for (final r in rows)
        if (mats.containsKey(r.read<String>('materia_id')))
          QuestaoCompleta(
            questao: QuestaoProva(
              id: r.read<String>('qid'),
              atualizadoEm: r.read<DateTime>('q_atualizado_em'),
              provaId: r.read<String>('prova_id'),
              numero: r.read<int>('numero'),
              textoId: r.readNullable<String>('texto_id'),
              materiaId: r.read<String>('materia_id'),
              topicoId: r.readNullable<String>('topico_id'),
              topicoOriginal: r.read<String>('topico_original'),
              enunciado: r.read<String>('enunciado'),
              alternativas: r.read<String>('alternativas'),
              resposta: r.read<String>('resposta'),
              status: r.read<String>('status'),
              obs: r.read<String>('obs'),
            ),
            prova: provasPorId[r.read<String>('prova_id')]!,
            materia: mats[r.read<String>('materia_id')]!,
            topico: tops[r.readNullable<String>('topico_id')],
            texto: txts[r.readNullable<String>('texto_id')],
            feitas: r.read<int>('feitas'),
            ultimaAcertou: r.readNullable<int>('ultima') == null
                ? null
                : r.read<int>('ultima') == 1,
          ),
    ];
  }

  /// Questões que passam em todos os filtros.
  Future<List<QuestaoCompleta>> questoesFiltradas(FiltroQuestoes f) async => [
    for (final q in await questoesCompletas(filtro: f))
      if (f.aceita(q)) q,
  ];

  /// "Treino rápido": [n] questões do escopo, primeiro as nunca feitas,
  /// depois as que errei. Anuladas, desatualizadas e "revisar" ficam fora.
  Future<List<QuestaoCompleta>> treinoRapido(
    String? concursoId, {
    int n = 10,
  }) => sortear(FiltroQuestoes(concursoId: concursoId), n);

  /// Sorteia [n] questões dos filtros, priorizando nunca feitas e erradas.
  Future<List<QuestaoCompleta>> sortear(FiltroQuestoes f, int n) async {
    final todas = await questoesFiltradas(f);
    final ids = sortearPriorizando([
      for (final q in todas)
        ItemSorteio(
          q.id,
          feitas: q.feitas,
          errouUltima: q.ultimaAcertou == false,
        ),
    ], n);
    final porId = {for (final q in todas) q.id: q};
    return [for (final id in ids) porId[id]!];
  }

  /// Bancas e anos das provas (para os filtros).
  Future<(List<String>, List<int>)> bancasEAnos() async {
    final ps = await select(provas).get();
    return (
      ({for (final p in ps) p.banca}.toList()..sort()),
      ({for (final p in ps) p.ano}.toList()..sort((a, b) => b - a)),
    );
  }

  Future<String> registrarResposta({
    required String questaoId,
    required String marcada,
    required bool acertou,
    required int segundos,
    required String modo,
    String? motivoErro,
  }) async => (await into(respostas).insertReturning(
    RespostasCompanion.insert(
      questaoId: questaoId,
      marcada: marcada,
      acertou: acertou,
      segundos: Value(segundos < 0 ? 0 : segundos),
      modo: modo,
      motivoErro: Value(motivoErro),
    ),
  )).id;

  Future<void> definirMotivoErro(String respostaId, String? motivo) =>
      (update(respostas)..where((r) => r.id.equals(respostaId))).write(
        RespostasCompanion(
          motivoErro: Value(motivo),
          atualizadoEm: Value(DateTime.now()),
        ),
      );

  /// "Conferi, está certa": tira o status "revisar".
  Future<void> conferirQuestao(String questaoId) async {
    final q = await (select(
      questoesProva,
    )..where((q) => q.id.equals(questaoId))).getSingle();
    final s = StatusQuestao.separar(q.status)..remove(StatusQuestao.revisar);
    await (update(questoesProva)..where((x) => x.id.equals(questaoId))).write(
      QuestoesProvaCompanion(
        status: Value(StatusQuestao.juntar(s)),
        atualizadoEm: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<PrintQuestao>> watchPrints(String questaoId) => (select(
    printsQuestao,
  )..where((p) => p.questaoId.equals(questaoId))).watch();

  Future<void> adicionarPrint(String questaoId, String arquivo) =>
      into(printsQuestao).insert(
        PrintsQuestaoCompanion.insert(questaoId: questaoId, arquivo: arquivo),
      );

  Future<void> excluirPrint(String id) =>
      (delete(printsQuestao)..where((p) => p.id.equals(id))).go();

  /// Registra o Treino/Simulado como sessão de estudo com método
  /// "Questões": uma sessão por matéria, com o tempo gasto nela. Os
  /// acertos ficam nas respostas (a sessão só leva os números para a
  /// folha do dia). Retorna os ids das matérias estudadas.
  Future<Set<String>> registrarSessoesDeQuestoes(
    List<({String materiaId, String? topicoId, bool? acertou, int segundos})>
    itens,
  ) {
    return transaction(() async {
      final porMateria =
          <String, List<({String? topicoId, bool? acertou, int segundos})>>{};
      for (final i in itens) {
        (porMateria[i.materiaId] ??= []).add((
          topicoId: i.topicoId,
          acertou: i.acertou,
          segundos: i.segundos,
        ));
      }
      final hoje = DateTime.now();
      for (final e in porMateria.entries) {
        final segs = e.value.fold<int>(0, (a, x) => a + x.segundos);
        final contam = e.value.where((x) => x.acertou != null);
        final topicosDistintos = {for (final x in e.value) x.topicoId};
        await registrarSessao(
          dia: hoje,
          minutos: ((segs + 30) ~/ 60).clamp(1, 24 * 60),
          materiaId: e.key,
          topicoId: topicosDistintos.length == 1
              ? topicosDistintos.first
              : null,
          metodo: 'questoes',
          questoesFeitas: contam.length,
          questoesAcertos: contam.where((x) => x.acertou!).length,
          origem: 'provas',
        );
      }
      return porMateria.keys.toSet();
    });
  }

  // ---------------------------------------------------------------------------
  // Estatísticas
  // ---------------------------------------------------------------------------

  Stream<List<RespostaInfo>> watchRespostasInfo() =>
      customSelect(
        '''
    SELECT r.*, q.numero, q.prova_id, q.materia_id, q.topico_id, q.status,
      p.banca, p.ano
    FROM respostas r
    JOIN questoes_prova q ON q.id = r.questao_id
    JOIN provas p ON p.id = q.prova_id
    ORDER BY r.data
    ''',
        readsFrom: {respostas, questoesProva, provas},
      ).watch().map(
        (rows) => [
          for (final r in rows)
            RespostaInfo(
              resposta: respostas.map(r.data),
              questaoId: r.read<String>('questao_id'),
              numero: r.read<int>('numero'),
              provaId: r.read<String>('prova_id'),
              materiaId: r.read<String>('materia_id'),
              topicoId: r.readNullable<String>('topico_id'),
              banca: r.read<String>('banca'),
              ano: r.read<int>('ano'),
              anulada: StatusQuestao.separar(r.read<String>('status'))
                  .contains(StatusQuestao.anulada),
            ),
        ],
      );

  /// Sessões + questões respondidas nas provas (ver
  /// [mesclarSessoesComRespostas]). Para estatísticas e mapa mental.
  Stream<List<Sessao>> watchSessoesComQuestoes() => combinarUltimos(
    watchTodasSessoes(),
    watchRespostasInfo(),
    mesclarSessoesComRespostas,
  );

  Stream<List<Sessao>> watchSessoesDoTopicoComQuestoes(String topicoId) =>
      combinarUltimos(
        watchSessoesDoTopico(topicoId),
        watchRespostasInfo(),
        (List<Sessao> s, List<RespostaInfo> r) =>
            mesclarSessoesComRespostas(s, [
              for (final x in r)
                if (x.topicoId == topicoId) x,
            ]),
      );
}

String _gabaritoJson(Map<int, String> g) =>
    jsonEncode({for (final k in (g.keys.toList()..sort())) '$k': g[k]});

String _descartadasJson(List<Descartada> d) => jsonEncode([
  for (final x in d) {'numero': x.numero, 'motivo': x.motivo},
]);

/// As sessões criadas por Treino/Simulado (origem 'provas') mantêm o tempo,
/// mas perdem os números de questões; no lugar entram linhas sem tempo,
/// uma por dia + matéria + tópico, com as respostas não anuladas. Assim a
/// % de acerto do tópico e da matéria vem sempre das respostas (e some
/// quando a prova é excluída), sem contar duas vezes.
List<Sessao> mesclarSessoesComRespostas(
  List<Sessao> sessoes,
  List<RespostaInfo> respostas,
) {
  final grupos = <(DateTime, String, String?), (int, int)>{};
  for (final r in respostas) {
    if (r.anulada) continue;
    final k = (soDia(r.resposta.data), r.materiaId, r.topicoId);
    final (f, a) = grupos[k] ?? (0, 0);
    grupos[k] = (f + 1, a + (r.resposta.acertou ? 1 : 0));
  }
  return [
    for (final s in sessoes)
      s.origem == 'provas'
          ? s.copyWith(questoesFeitas: 0, questoesAcertos: 0)
          : s,
    for (final e in grupos.entries)
      Sessao(
        id: 'q|${e.key.$1.toIso8601String()}|${e.key.$2}|${e.key.$3}',
        atualizadoEm: e.key.$1,
        materiaId: e.key.$2,
        topicoId: e.key.$3,
        dia: e.key.$1,
        inicio: e.key.$1,
        minutos: 0,
        metodo: 'questoes',
        questoesFeitas: e.value.$1,
        questoesAcertos: e.value.$2,
        paginas: 0,
        origem: 'respostas',
      ),
  ];
}

/// Acertos e total de um grupo (matéria, tópico, banca, semana).
class Placar {
  int feitas = 0;
  int acertos = 0;
  int segundos = 0;
  double? get acerto => feitas == 0 ? null : acertos / feitas;

  /// Borda laranja do mapa mental: abaixo de 60% com 10+ questões.
  bool get baixo => feitas >= 10 && acertos / feitas < 0.6;
}

/// Números da tela "Estatísticas das provas". Anuladas ficam de fora.
class EstatisticasProvas {
  EstatisticasProvas(List<RespostaInfo> todas, {required DateTime hoje}) {
    final semanaAtual = inicioSemana(hoje);
    for (var i = 11; i >= 0; i--) {
      semanas[DateTime(
            semanaAtual.year,
            semanaAtual.month,
            semanaAtual.day - 7 * i,
          )] =
          Placar();
    }
    for (final r in todas) {
      if (r.anulada) continue;
      final ok = r.resposta.acertou;
      void somar(Placar p) {
        p.feitas++;
        if (ok) p.acertos++;
        p.segundos += r.resposta.segundos;
      }

      somar(geral);
      somar(porMateria[r.materiaId] ??= Placar());
      if (r.topicoId != null) somar(porTopico[r.topicoId!] ??= Placar());
      somar(porBanca[r.banca] ??= Placar());
      final s = semanas[inicioSemana(r.resposta.data)];
      if (s != null) somar(s);
      if (!ok) {
        final m = r.resposta.motivoErro;
        final k = m == null || m.isEmpty ? '' : m;
        errosPorMotivo[k] = (errosPorMotivo[k] ?? 0) + 1;
      }
      ultima[r.questaoId] = r;
    }
  }

  final geral = Placar();
  final porMateria = <String, Placar>{};
  final porTopico = <String, Placar>{};
  final porBanca = <String, Placar>{};

  /// Últimas 12 semanas (domingo a sábado), da mais antiga à atual.
  final semanas = <DateTime, Placar>{};

  /// Motivo → erros ('' = não informado).
  final errosPorMotivo = <String, int>{};

  /// Última resposta de cada questão (as respostas vêm em ordem de data).
  final ultima = <String, RespostaInfo>{};

  double? get segundosPorQuestao =>
      geral.feitas == 0 ? null : geral.segundos / geral.feitas;

  /// Caderno de erros: questões cuja última resposta foi errada.
  List<String> get cadernoDeErros => [
    for (final r in ultima.values)
      if (!r.resposta.acertou) r.questaoId,
  ];

  static DateTime inicioSemana(DateTime d) {
    return DateTime(d.year, d.month, d.day - d.weekday % 7);
  }
}
