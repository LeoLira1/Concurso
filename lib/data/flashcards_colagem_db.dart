import 'package:drift/drift.dart';

import '../logic/flashcards_colados.dart';
import '../util/texto.dart';
import 'colagem_db.dart';
import 'database.dart';

export 'colagem_db.dart' show DestinoColagem, ResultadoColagem, ColagemDb;

extension FlashcardsColagemDb on AppDatabase {
  /// Marca os cartões cuja frente já existe (em qualquer tópico).
  Future<void> marcarFlashcardsRepetidos(LeituraFlashcards l) async =>
      marcarRepetidos(l, {
        for (final r in await customSelect(
          'SELECT f.frente, t.nome FROM flashcards f '
          'JOIN topicos t ON t.id = f.topico_id',
          readsFrom: {flashcards, topicos},
        ).get())
          chaveFrente(r.read<String>('frente')): descreverRepetido(
            r.read<String>('nome'),
            r.read<String>('frente'),
          ),
      });

  /// Importa os cartões válidos e não repetidos (ver [importarColagem]).
  /// Entram na caixa 0 do Leitner, com revisão para hoje, no fim da lista
  /// do tópico.
  Future<ResultadoColagem> importarFlashcards(
    LeituraFlashcards l, {
    String? concursoId,
  }) {
    final hoje = soDia(DateTime.now());
    return importarColagem(
      l,
      concursoId: concursoId,
      marcar: () => marcarFlashcardsRepetidos(l),
      inserir: (c, topicoId) async {
        final r = await customSelect(
          'SELECT COALESCE(MAX(ordem), -1) AS m FROM flashcards '
          'WHERE topico_id = ?',
          variables: [Variable.withString(topicoId)],
        ).getSingle();
        await into(flashcards).insert(
          FlashcardsCompanion.insert(
            topicoId: topicoId,
            frente: c.frente,
            verso: c.verso,
            ordem: Value(r.read<int>('m') + 1),
            caixa: const Value(0),
            proximaRevisao: Value(hoje),
          ),
        );
      },
    );
  }
}
