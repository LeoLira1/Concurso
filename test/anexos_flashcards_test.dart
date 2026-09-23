import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/logic/flashcards.dart';
import 'package:edital/state/arquivos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('caixas de Leitner', () {
    final hoje = DateTime(2026, 9, 23, 15);

    test('acertar sobe a caixa e espaça', () {
      var r = responderCartao(caixaAtual: 0, acertou: true, hoje: hoje);
      expect(r.caixa, 1);
      expect(r.proxima, DateTime(2026, 9, 24));
      r = responderCartao(caixaAtual: 3, acertou: true, hoje: hoje);
      expect(r.caixa, 4);
      expect(r.proxima, DateTime(2026, 10, 7));
      r = responderCartao(caixaAtual: 5, acertou: true, hoje: hoje);
      expect(r.caixa, 5);
      expect(r.proxima, DateTime(2026, 10, 23));
    });

    test('errar volta para a caixa 0 e fica para hoje', () {
      final r = responderCartao(caixaAtual: 4, acertou: false, hoje: hoje);
      expect(r.caixa, 0);
      expect(r.proxima, DateTime(2026, 9, 23));
    });

    test('texto do próximo intervalo', () {
      expect(proximoIntervalo(0), 'amanhã');
      expect(proximoIntervalo(2), 'em 7 dias');
    });
  });

  group('banco', () {
    late AppDatabase db;
    late String materia;
    late String topico;
    late Directory pasta;

    setUp(() async {
      db = AppDatabase(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );
      final c = await db.criarConcurso(nome: 'A', cor: 1);
      materia = await db.adicionarMateria(c, 'Português', 1);
      topico = await db.adicionarTopico(materia, 'Crase');
      pasta = await Directory.systemTemp.createTemp('anexos');
      ArquivosAnexos.pastaFixa = pasta;
    });
    tearDown(() async {
      await db.close();
      ArquivosAnexos.pastaFixa = null;
      await pasta.delete(recursive: true);
    });

    test(
      'flashcards: novos vencem hoje; responder tira da fila de hoje',
      () async {
        await db.salvarFlashcard(
          topicoId: topico,
          frente: 'Quando a crase é facultativa?',
          verso: '...',
        );
        await db.salvarFlashcard(
          topicoId: topico,
          frente: 'Crase antes de horas?',
          verso: 'Sim',
        );
        var fila = await db.watchCartoesParaRevisar(materiaId: materia).first;
        expect(fila, hasLength(2));
        expect(fila.first.topico.nome, 'Crase');
        expect(fila.first.materia.nome, 'Português');

        await db.responderFlashcard(fila.first.cartao, acertou: true);
        fila = await db.watchCartoesParaRevisar(topicoId: topico).first;
        expect(fila, hasLength(1));

        await db.responderFlashcard(fila.first.cartao, acertou: false);
        fila = await db.watchCartoesParaRevisar(topicoId: topico).first;
        expect(fila.single.cartao.erros, 1);

        // "Praticar todos" enxerga também os que não vencem hoje.
        final todos = await db
            .watchCartoesParaRevisar(topicoId: topico, ate: DateTime(9999))
            .first;
        expect(todos, hasLength(2));

        final extras = await db.watchContagemExtras(materia).first;
        expect(extras[topico], (0, 2));
      },
    );

    test('editar flashcard mantém a caixa', () async {
      await db.salvarFlashcard(topicoId: topico, frente: 'A', verso: 'B');
      final c = (await db.watchFlashcards(topico).first).single;
      await db.responderFlashcard(c, acertou: true);
      await db.salvarFlashcard(
        id: c.id,
        topicoId: topico,
        frente: 'A2',
        verso: 'B2',
      );
      final e = (await db.watchFlashcards(topico).first).single;
      expect(e.frente, 'A2');
      expect(e.caixa, 1);
    });

    test(
      'anexos: importa, exclui e limpa órfãos quando o tópico some',
      () async {
        final origem = File(
          '${pasta.path}/../mapa_${DateTime.now().microsecondsSinceEpoch}.jpg',
        );
        await origem.writeAsBytes(List.filled(2048, 7));
        await ArquivosAnexos.importar(
          db: db,
          topicoId: topico,
          origem: XFile(origem.path),
          tipo: 'imagem',
          nome: 'Mapa mental',
        );
        var anexos = await db.watchAnexos(topico).first;
        expect(anexos.single.nome, 'Mapa mental');
        expect(anexos.single.bytes, 2048);
        final arquivo = await ArquivosAnexos.arquivo(anexos.single.arquivo);
        expect(await arquivo.exists(), isTrue);
        expect(anexos.single.arquivo, endsWith('.jpg'));

        // Excluir o tópico apaga o anexo (cascade); o arquivo vira órfão.
        await db.excluirTopico(topico);
        anexos = await db.watchAnexos(topico).first;
        expect(anexos, isEmpty);
        await ArquivosAnexos.limparOrfaos(db);
        expect(await arquivo.exists(), isFalse);
        await origem.delete();
      },
    );
  });
}
