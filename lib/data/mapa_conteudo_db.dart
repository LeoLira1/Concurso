import 'package:drift/drift.dart';

import '../logic/mapa_conteudo.dart';
import 'colagem_db.dart';
import 'database.dart';

export 'colagem_db.dart' show DestinoColagem, ResultadoColagem, ColagemDb;

/// Mapa do conteúdo gravado, já com os nós lidos.
class MapaSalvo {
  MapaSalvo(this.linha) : nos = nosDeJson(linha.nos);
  final MapaConteudo linha;
  final List<NoConteudo> nos;

  String get titulo => linha.titulo;
  String get topicoId => linha.topicoId;
}

extension MapaConteudoDb on AppDatabase {
  /// Mapa do tópico (nulo = ainda não tem).
  Stream<MapaSalvo?> watchMapa(String topicoId) =>
      (select(
        mapasConteudo,
      )..where((m) => m.topicoId.equals(topicoId))).watch().map((l) {
        if (l.isEmpty) return null;
        // Com dados de dois aparelhos, vale o mais recente.
        l.sort((a, b) => b.atualizadoEm.compareTo(a.atualizadoEm));
        return MapaSalvo(l.first);
      });

  Future<MapaSalvo?> mapaDoTopico(String topicoId) => watchMapa(topicoId).first;

  /// Tópicos que têm mapa (para o ícone na lista de tópicos).
  Stream<Set<String>> watchTopicosComMapa() => customSelect(
    'SELECT DISTINCT topico_id AS id FROM mapas_conteudo',
    readsFrom: {mapasConteudo},
  ).watch().map((rows) => {for (final r in rows) r.read<String>('id')});

  /// Grava (ou substitui) o mapa do tópico. Sem UPSERT: dentro de um
  /// "ON CONFLICT DO UPDATE" o SQLite troca o "INSERT OR REPLACE" dos
  /// gatilhos do sync por ABORT.
  Future<void> salvarMapa(
    String topicoId, {
    required String titulo,
    required List<NoConteudo> nos,
  }) => transaction(() async {
    // Linhas com outro id (vindas de outro aparelho) saem.
    await (delete(mapasConteudo)..where(
          (m) => m.topicoId.equals(topicoId) & m.id.equals(topicoId).not(),
        ))
        .go();
    final alterou =
        await (update(
          mapasConteudo,
        )..where((m) => m.id.equals(topicoId))).write(
          MapasConteudoCompanion(
            titulo: Value(titulo),
            nos: Value(nosParaJson(nos)),
            atualizadoEm: Value(DateTime.now()),
          ),
        );
    if (alterou == 0) {
      await into(mapasConteudo).insert(
        MapasConteudoCompanion.insert(
          id: Value(topicoId),
          topicoId: topicoId,
          titulo: titulo,
          nos: nosParaJson(nos),
        ),
      );
    }
  });

  Future<void> excluirMapa(String topicoId) =>
      (delete(mapasConteudo)..where((m) => m.topicoId.equals(topicoId))).go();

  /// Para a prévia: os itens (pelo índice) cujo tópico já tem mapa.
  Future<Set<int>> mapasQueSubstituem(LeituraMapas l) async {
    final r = <int>{};
    for (final q in l.mapas) {
      if (!q.valida) continue;
      final t = await topicoDestino(q);
      if (t != null && await mapaDoTopico(t.id) != null) r.add(q.indice);
    }
    return r;
  }

  /// Importa os mapas válidos, cada um no seu tópico (criado se não
  /// existe, com a mesma regra do "Colar questões"), substituindo o mapa
  /// que já existia.
  Future<ResultadoColagem> importarMapas(
    LeituraMapas l, {
    String? concursoId,
  }) => importarColagem(
    l,
    concursoId: concursoId,
    marcar: () async {},
    inserir: (q, topicoId) =>
        salvarMapa(topicoId, titulo: q.titulo, nos: q.nos),
  );
}
