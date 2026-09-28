import 'package:drift/drift.dart';

import '../logic/colagem.dart';
import '../logic/importar_edital.dart' show chaveTexto;
import '../theme.dart' show Cores;
import '../util/texto.dart';
import 'database.dart';

/// Onde cada item colado vai parar (para a prévia).
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

/// Resultado de "Colar questões" ou "Colar flashcards".
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

/// Marca os itens válidos cuja [ItemColado.chave] está em [chaves]. O
/// valor de cada chave descreve o item do banco com que bateu (vai para
/// [ItemColado.repetidaDe]).
void marcarRepetidos(LeituraColagem l, Map<String, String> chaves) {
  for (final q in l.itens) {
    if (!q.valida || q.repetida) continue;
    final de = chaves[q.chave];
    if (de != null) {
      q.repetida = true;
      q.repetidaDe = de;
    }
  }
}

/// "Conjunções: “Assinale a alternativa em que…”" (para a prévia).
String descreverRepetido(String topico, String texto) {
  final t = texto.replaceAll(RegExp(r'\s+'), ' ').trim();
  final inicio = t.length > 70 ? '${t.substring(0, 69)}…' : t;
  return '$topico: “$inicio”';
}

extension ColagemDb on AppDatabase {
  /// Para a prévia: matéria, tópico e subtópico novos de cada item (pelo
  /// índice). [concursoId] é o edital de destino (nulo = "Tudo junto").
  Future<Map<int, DestinoColagem>> destinosColagem(
    LeituraColagem l, {
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
    for (final q in l.itens) {
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

  /// Importa os itens válidos e não repetidos: [marcar] marca os que já
  /// existem no banco e [inserir] grava cada item no tópico de destino.
  /// Matéria, tópico e subtópico que não existem são criados; o tópico
  /// entra no edital de [concursoId] (nulo = de todos os concursos que têm
  /// a matéria). Uma matéria nova entra em [concursoId] ou, sem ele, no
  /// concurso em foco.
  Future<ResultadoColagem> importarColagem<T extends ItemColado>(
    LeituraColagem<T> l, {
    String? concursoId,
    required Future<void> Function() marcar,
    required Future<void> Function(T item, String topicoId) inserir,
  }) {
    return transaction(() async {
      await marcar();
      final cores = {for (final m in await select(materias).get()) m.cor};
      final foco = await (select(
        concursos,
      )..where((c) => c.foco.equals(true))).getSingleOrNull();
      final topicosCriados = <String>[];
      final materiasCriadas = <String>[];
      var novas = 0;
      for (final q in l.itens) {
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

        await inserir(q, alvo.id);
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

  /// Tópico (ou subtópico) onde [q] vai parar, se já existe.
  Future<Topico?> topicoDestino(ItemColado q) async {
    final m = await materiaPorNome(q.materia);
    if (m == null) return null;
    final t = await _topicoPorNome(m.id, null, q.topico);
    if (t == null || q.subtopico.isEmpty) return t;
    return _topicoPorNome(m.id, t.id, q.subtopico);
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
}
