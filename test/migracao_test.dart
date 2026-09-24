import 'dart:io';

import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Quem instalou a versão 1 do app precisa abrir a versão 2 sem perder dados.
void main() {
  test('migra banco v1 -> v5 mantendo os dados', () async {
    final dir = await Directory.systemTemp.createTemp('edital');
    final arquivo = File('${dir.path}/edital.sqlite');

    // Cria o banco atual e "rebaixa" para o formato v1.
    var db = AppDatabase(NativeDatabase(arquivo));
    final c = await db.criarConcurso(nome: 'PM', cor: 1);
    await db.adicionarMateria(c, 'Português', 1);
    for (final col in [
      'ciclo_minutos',
      'ciclo_bloco_min',
      'ciclo_posicao',
      'ciclo_voltas',
    ]) {
      await db.customStatement('ALTER TABLE concursos DROP COLUMN $col');
    }
    for (final col in [
      'metodo',
      'questoes_feitas',
      'questoes_acertos',
      'paginas',
      'ponto_parada',
    ]) {
      await db.customStatement('ALTER TABLE sessoes DROP COLUMN $col');
    }
    for (final col in ['peso', 'dificuldade', 'no_ciclo']) {
      await db.customStatement(
        'ALTER TABLE concurso_materias DROP COLUMN $col',
      );
    }
    await db.customStatement('DROP TABLE anexos');
    await db.customStatement('DROP TABLE flashcards');
    await db.customStatement('DROP TABLE topico_concursos');
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();

    db = AppDatabase(NativeDatabase(arquivo));
    final concursos = await db.watchConcursos().first;
    expect(concursos.single.nome, 'PM');
    expect(concursos.single.cicloMinutos, 1200);
    final mats = await db.watchMaterias(c).first;
    expect(mats.single.peso, 3);
    await db.registrarSessao(
      dia: DateTime.now(),
      minutos: 30,
      materiaId: mats.single.materia.id,
      pontoParada: 'pág. 10',
    );
    expect(
      (await db.watchUltimaParada(mats.single.materia.id).first)?.pontoParada,
      'pág. 10',
    );
    final t = await db.adicionarTopico(mats.single.materia.id, 'Crase');
    expect(await db.watchVinculos(t).first, {c});
    await db.salvarFlashcard(topicoId: t, frente: 'P', verso: 'R');
    expect(await db.watchCartoesParaRevisar().first, hasLength(1));
    final ciclo = await db.watchCiclo(c).first;
    expect(ciclo.fila, isNotEmpty);
    await db.close();
    await dir.delete(recursive: true);
  });
}
