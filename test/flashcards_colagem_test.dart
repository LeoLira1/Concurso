import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/data/flashcards_colagem_db.dart';
import 'package:edital/logic/flashcards_colados.dart';
import 'package:edital/util/texto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sincronizacao_test.dart' show Aparelho, ServidorFalso;

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

Map<String, Object?> cartao({
  String materia = 'Língua Portuguesa',
  String? topico = 'Concordância nominal e verbal',
  String? subtopico = 'Verbo haver',
  String? frente = 'Quando o verbo haver fica no singular?',
  String? verso =
      'Quando significa existir ou indica tempo decorrido. '
      'Ex.: Havia muitos candidatos.',
}) => {
  'materia': materia,
  'topico': ?topico,
  'subtopico': ?subtopico,
  'frente': ?frente,
  'verso': ?verso,
};

String lista(List<Map<String, Object?>> cs) => jsonEncode(cs);

void main() {
  group('leitura do JSON colado', () {
    test('lê o formato pedido, com subtópico', () {
      final l = lerFlashcards(lista([cartao()]));
      expect(l.erro, isNull);
      final c = l.itens.single;
      expect(c.valida, isTrue, reason: '${c.erros}');
      expect(c.materia, 'Língua Portuguesa');
      expect(c.topico, 'Concordância nominal e verbal');
      expect(c.subtopico, 'Verbo haver');
      expect(c.frente, 'Quando o verbo haver fica no singular?');
      expect(c.verso, startsWith('Quando significa existir'));
    });

    test('subtópico é opcional', () {
      final c = lerFlashcards(lista([cartao(subtopico: null)])).itens.single;
      expect(c.valida, isTrue);
      expect(c.subtopico, '');
    });

    test('aceita cercas de código e texto copiado do chat', () {
      final l = lerFlashcards(
        'Claro! Seguem os cartões:\n```json\n${lista([cartao()])}\n```\n'
        'Bons estudos!',
      );
      expect(l.erro, isNull);
      expect(l.novas, 1);
    });

    test('JSON quebrado diz a linha', () {
      final l = lerFlashcards('[\n{"frente": "A",\n"verso" "B"}\n]');
      expect(l.erro, contains('linha 3'));
    });

    test('texto sem JSON', () {
      expect(lerFlashcards('nada aqui').erro, contains('lista de flashcards'));
    });

    test('erros por cartão, sem travar os outros', () {
      final l = lerFlashcards(
        lista([
          cartao(),
          cartao(frente: 'Sem verso', verso: null),
          cartao(frente: '', verso: 'Sem frente'),
          cartao(frente: 'Sem tópico', topico: null, subtopico: null),
        ]),
      );
      expect(l.novas, 1);
      expect(l.comErro, 3);
      expect(l.itens[1].erros, ['falta o verso']);
      expect(l.itens[2].erros, ['falta a frente']);
      expect(l.itens[3].erros, ['falta o tópico']);
    });

    test('na tela do tópico, o cartão sem matéria/tópico vai para ele', () {
      final l = lerFlashcards(
        jsonEncode([
          {'frente': 'Crase antes de palavra masculina?', 'verso': 'Não.'},
        ]),
        materiaPadrao: 'Português',
        topicoPadrao: 'Crase',
        subtopicoPadrao: 'Casos proibidos',
      );
      final c = l.itens.single;
      expect(c.valida, isTrue, reason: '${c.erros}');
      expect(c.topico, 'Crase');
      expect(c.subtopico, 'Casos proibidos');
    });

    test('frente repetida na mesma lista entra uma vez só', () {
      final l = lerFlashcards(
        lista([
          cartao(),
          cartao(frente: 'quando o VERBO haver fica no singular', verso: 'x'),
        ]),
      );
      expect(l.novas, 1);
      expect(l.repetidas, 1);
    });
  });

  group('importar', () {
    late AppDatabase db;
    late String pm, gm, portugues;
    setUp(() async {
      db = bancoMemoria();
      pm = await db.criarConcurso(nome: 'PM', cor: 1);
      gm = await db.criarConcurso(nome: 'GM', cor: 2);
      portugues = await db.adicionarMateria(pm, 'Língua Portuguesa', 3);
      await db.adicionarMateria(gm, 'Língua Portuguesa', 3);
    });
    tearDown(() => db.close());

    test('cria tópico e subtópico, caixa 0 para hoje e não duplica', () async {
      final l = lerFlashcards(
        lista([
          cartao(),
          cartao(
            frente: 'Fazer indicando tempo vai para o plural?',
            subtopico: 'Verbo fazer',
            verso: 'Não: "Faz dois anos".',
          ),
          cartao(frente: 'Regra geral?', subtopico: null, verso: 'Concorda.'),
        ]),
      );
      await db.marcarFlashcardsRepetidos(l);
      final d = await db.destinosColagem(l, concursoId: pm);
      expect(d[1]!.topicoNovo, isTrue);
      expect(d[1]!.subtopicoNovo, isTrue);
      expect(d[1]!.materiaNova, isFalse);

      final r = await db.importarFlashcards(l, concursoId: pm);
      expect(r.novas, 3);
      expect(r.topicosCriados, hasLength(3)); // tópico + 2 subtópicos

      final tops = await db.watchTopicos(portugues, concursoId: pm).first;
      final conc = tops.firstWhere(
        (t) => t.nome == 'Concordância nominal e verbal',
      );
      expect(conc.paiId, isNull);
      expect(await db.watchVinculos(conc.id).first, {pm});
      final haver = tops.firstWhere((t) => t.nome == 'Verbo haver');
      expect(haver.paiId, conc.id);

      final cartoes = await db.watchFlashcards(haver.id).first;
      final c = cartoes.single;
      expect(c.caixa, 0);
      expect(c.proximaRevisao, soDia(DateTime.now()));
      expect(c.acertos + c.erros, 0);
      // Já aparece para revisar hoje.
      expect(
        await db.watchCartoesParaRevisar(materiaId: portugues).first,
        hasLength(3),
      );

      // Colar de novo (com outra pontuação e maiúscula) não duplica.
      final de2 = lerFlashcards(
        lista([
          cartao(frente: 'QUANDO o verbo "haver" fica no singular'),
          cartao(frente: 'Cartão novo de verdade', verso: 'Sim.'),
        ]),
      );
      await db.marcarFlashcardsRepetidos(de2);
      expect(de2.repetidas, 1);
      final r2 = await db.importarFlashcards(de2, concursoId: pm);
      expect(r2.novas, 1);
      expect(r2.topicosCriados, isEmpty);
      expect(await db.watchFlashcards(haver.id).first, hasLength(2));
    });

    test('frente que já existe num cartão digitado à mão', () async {
      final crase = await db.adicionarTopico(portugues, 'Crase');
      await db.salvarFlashcard(
        topicoId: crase,
        frente: 'Crase antes de verbo?',
        verso: 'Nunca.',
      );
      final l = lerFlashcards(
        lista([
          cartao(
            topico: 'Crase',
            subtopico: null,
            frente: 'crase antes de verbo',
          ),
        ]),
      );
      await db.marcarFlashcardsRepetidos(l);
      expect(l.novas, 0);
      expect((await db.importarFlashcards(l)).novas, 0);
    });

    test('entra depois dos cartões que o tópico já tem', () async {
      final crase = await db.adicionarTopico(portugues, 'Crase');
      await db.salvarFlashcard(topicoId: crase, frente: 'A', verso: 'a');
      await db.importarFlashcards(
        lerFlashcards(
          lista([
            cartao(topico: 'crase', subtopico: null, frente: 'B', verso: 'b'),
          ]),
        ),
      );
      final l = await db.watchFlashcards(crase).first;
      expect(l.map((c) => c.frente), ['A', 'B']);
    });

    test('"Tudo junto": tópico novo entra em todos com a matéria', () async {
      await db.importarFlashcards(lerFlashcards(lista([cartao()])));
      final t = (await db.watchTopicos(portugues, concursoId: gm).first)
          .firstWhere((t) => t.nome == 'Concordância nominal e verbal');
      expect(await db.watchVinculos(t.id).first, {pm, gm});
    });

    test('tópico de outro edital ganha o vínculo', () async {
      final crase = await db.adicionarTopico(
        portugues,
        'Crase',
        concursoIds: [gm],
      );
      final l = lerFlashcards(
        lista([cartao(topico: 'CRASE', subtopico: null)]),
      );
      final d = await db.destinosColagem(l, concursoId: pm);
      expect(d[1]!.topicoNovo, isFalse);
      expect(d[1]!.entraNoEdital, isTrue);
      await db.importarFlashcards(l, concursoId: pm);
      expect(await db.watchVinculos(crase).first, {pm, gm});
      expect(await db.watchFlashcards(crase).first, hasLength(1));
    });

    test('matéria nova entra no concurso de destino', () async {
      final l = lerFlashcards(
        lista([
          cartao(materia: 'Direito Penal', topico: 'Peculato', subtopico: null),
        ]),
      );
      expect(
        (await db.destinosColagem(l, concursoId: pm))[1]!.materiaNova,
        isTrue,
      );
      final r = await db.importarFlashcards(l, concursoId: pm);
      expect(r.materiasCriadas, ['Direito Penal']);
      expect(
        (await db.watchMaterias(pm).first).map((m) => m.materia.nome),
        contains('Direito Penal'),
      );
    });
  });

  test('cartões colados sincronizam pelo Turso', () async {
    final servidor = ServidorFalso();
    final tablet = Aparelho('tablet', servidor);
    final celular = Aparelho('celular', servidor);
    addTearDown(() async {
      await tablet.db.close();
      await celular.db.close();
      servidor.banco.close();
    });
    final c = await tablet.db.criarConcurso(nome: 'PM', cor: 1);
    final m = await tablet.db.adicionarMateria(c, 'Língua Portuguesa', 2);
    await tablet.db.importarFlashcards(
      lerFlashcards(lista([cartao()])),
      concursoId: c,
    );
    await tablet.sincronizar();
    await celular.sincronizar();

    final noCelular = await celular.db
        .watchCartoesParaRevisar(materiaId: m, concursoId: c)
        .first;
    expect(noCelular.single.cartao.frente, startsWith('Quando o verbo haver'));
    expect(noCelular.single.cartao.caixa, 0);
    expect(noCelular.single.topico.nome, 'Verbo haver');
  });
}
