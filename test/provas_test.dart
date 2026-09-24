import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/data/provas_db.dart';
import 'package:edital/logic/importar_edital.dart';
import 'package:edital/logic/provas.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sincronizacao_test.dart' show Aparelho, ServidorFalso;

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

final jsonAraucaria = File('test/dados/araucaria_2019.json').readAsStringSync();

Map<String, dynamic> araucaria() =>
    jsonDecode(jsonAraucaria) as Map<String, dynamic>;

List<int> numeros(Iterable<QuestaoImportada> qs) => [
  for (final q in qs) q.numero,
];

/// Importa o JSON (sem divergências) e devolve o resultado.
Future<ResultadoImportacao> importar(AppDatabase db, String texto) async {
  final l = lerProva(texto);
  expect(l.erros, isEmpty, reason: '${l.erros}');
  expect(l.podeImportar, isTrue);
  await db.ligarTopicos(l.prova!);
  return db.importarProva(l.prova!);
}

void main() {
  group('leitura do JSON', () {
    test('prova de Araucária 2019: contagens, status e gabarito', () {
      final l = lerProva(jsonAraucaria);
      expect(l.erros, isEmpty);
      expect(l.avisos, isEmpty); // 36 + 4 = 40
      expect(l.divergencias, isEmpty); // tudo igual ao gabarito lido
      final p = l.prova!;
      expect(p.questoes, hasLength(36));
      expect([for (final d in p.descartadas) d.numero], [11, 12, 14, 15]);
      expect(p.totalQuestoes, 40);
      expect(p.definitivo, isTrue);
      expect(p.gabaritoLido, hasLength(40));

      final st = contarPorStatus(p.questoes);
      expect(st[StatusQuestao.anulada], [7, 24]);
      expect(st[StatusQuestao.desatualizada], [37]);
      expect(st[StatusQuestao.imagem], [3]);
      expect(st[StatusQuestao.revisar], [6, 7]);
      for (final q in p.questoes.where((q) => q.anulada)) {
        expect(q.resposta, 'X');
      }

      expect(contarPorMateria(p.questoes), {
        'Língua Portuguesa': 5,
        'Matemática e Raciocínio Lógico': 5,
        'Cidadania e Segurança Pública': 4,
        'Noções de Segurança e Vigilância': 14,
        'Direito Administrativo': 1,
        'Direito Penal': 2,
        'Crimes contra a Administração Pública': 1,
        'Leis Penais Especiais': 4,
      });
      for (final q in p.questoes) {
        expect(materiasDeProva, contains(q.materia));
      }
      expect(p.questoes.first.textoId, 'T1');
      expect(p.textos.map((t) => t.id), ['T1', 'T2']);
    });

    test('JSON com erro de sintaxe', () {
      final l = lerProva(
        jsonAraucaria.replaceFirst('"ano": 2019,', '"ano": 2019'),
      );
      expect(l.prova, isNull);
      expect(l.podeImportar, isFalse);
      expect(l.erros.single.mensagem, contains('erro de digitação'));
      expect(l.erros.single.mensagem, contains('linha'));

      expect(
        lerProva('isso não é json').erros.single.mensagem,
        contains('Não encontrei nenhum JSON'),
      );
    });

    test('formato errado', () {
      final m = araucaria()..['formato'] = 'outro';
      expect(
        lerProva(jsonEncode(m)).erros.single.mensagem,
        contains('edital-prova-v1'),
      );
    });

    test('resposta diferente do gabarito lido: aviso e escolha', () {
      final m = araucaria();
      final q1 = (m['questoes'] as List).first as Map;
      q1['resposta'] = 'A'; // gabarito lido diz C
      final l = lerProva(jsonEncode(m));
      expect(l.erros, isEmpty);
      final d = l.divergencias.single;
      expect(d.numero, 1);
      expect(d.mensagem, 'Resposta A, mas o gabarito lido diz C');
      expect(l.podeImportar, isFalse); // precisa escolher
      d.escolhida = 'C';
      expect(l.podeImportar, isTrue);
      l.aplicarEscolhas();
      expect(l.prova!.questoes.first.resposta, 'C');
    });

    test('"X" sem status anulada dá erro', () {
      final m = araucaria();
      final q8 =
          (m['questoes'] as List).firstWhere((q) => q['numero'] == 8) as Map;
      q8['resposta'] = 'X';
      final l = lerProva(jsonEncode(m));
      expect(l.podeImportar, isFalse);
      expect(
        l.erros.map((e) => e.mensagem),
        contains(
          contains('Questão 8: resposta "X" só vale para questão anulada'),
        ),
      );
    });

    test('alternativa faltando, texto inexistente, número repetido', () {
      final m = araucaria();
      final qs = m['questoes'] as List;
      (qs[1]['alternativas'] as Map).remove('D');
      qs[2]['texto_id'] = 'T9';
      qs[3]['numero'] = 1;
      qs[4]['resposta'] = 'E';
      final msgs = lerProva(jsonEncode(m)).erros.map((e) => e.mensagem);
      expect(msgs, contains(contains('Questão 2: falta a alternativa D')));
      expect(msgs, contains(contains('Questão 3: usa o texto "T9"')));
      expect(msgs, contains(contains('Questão 1 aparece repetida')));
      expect(msgs, contains(contains('Questão 5: resposta "E" inválida')));
    });

    test('total que não bate é aviso, não impede importar', () {
      final m = araucaria();
      (m['questoes'] as List).removeLast();
      final l = lerProva(jsonEncode(m));
      expect(l.erros, isEmpty);
      expect(l.avisos.single.mensagem, contains('mas a prova tem 40'));
      expect(l.podeImportar, isTrue);
    });

    test('continuação em dois blocos da mesma prova', () {
      final a = araucaria(), b = araucaria();
      final qs = a['questoes'] as List;
      a['questoes'] = qs.sublist(0, 20);
      b['questoes'] = qs.sublist(20);
      b['textos'] = [];
      final texto =
          '${const JsonEncoder.withIndent('  ').convert(a)}\n\n'
          'continua:\n${jsonEncode(b)}';
      expect(separarBlocosJson(texto), hasLength(2));
      final l = lerProva(texto);
      expect(l.erros, isEmpty);
      expect(l.avisos, isEmpty);
      expect(l.prova!.questoes, hasLength(36));
    });

    test('blocos de provas diferentes não se juntam', () {
      final a = araucaria(), b = araucaria();
      (b['prova'] as Map)['ano'] = 2020;
      final l = lerProva('${jsonEncode(a)}${jsonEncode(b)}');
      expect(l.podeImportar, isFalse);
      expect(l.erros.single.mensagem, contains('outra prova'));
    });
  });

  group('tópicos por semelhança', () {
    test('Estatuto das Guardas casa com o tópico do edital', () {
      final c = candidatosTopico(
        'Estatuto das Guardas – princípios mínimos de atuação',
        [
          (
            id: '1',
            nome: 'Estatuto Geral das Guardas Municipais (Lei 13.022/2014)',
          ),
          (id: '2', nome: 'Estatuto do Desarmamento (Lei 10.826/2003)'),
          (id: '3', nome: 'Lei Maria da Penha (Lei 11.340/2006)'),
        ],
      );
      expect(melhorTopico(c)?.id, '1');
    });

    test('igual ignorando acento e maiúscula; sem nada parecido fica sem', () {
      final lista = [
        (id: 'a', nome: 'Compreensão e interpretação de textos'),
        (id: 'b', nome: 'Crase'),
      ];
      expect(
        melhorTopico(candidatosTopico('Interpretação de texto', lista))?.id,
        'a',
      );
      expect(melhorTopico(candidatosTopico('CRASE', lista))?.id, 'b');
      expect(
        melhorTopico(candidatosTopico('Regra de três composta', lista)),
        isNull,
      );
    });

    test('ambíguo não liga sozinho, mas sugere', () {
      final c = candidatosTopico('Porte de arma', [
        (id: '1', nome: 'Porte de arma de fogo'),
        (id: '2', nome: 'Porte de arma branca'),
      ]);
      expect(melhorTopico(c), isNull);
      expect(c.map((x) => x.id), containsAll(['1', '2']));
    });
  });

  group('banco', () {
    late AppDatabase db;
    setUp(() => db = bancoMemoria());
    tearDown(() => db.close());

    Future<List<QuestaoProva>> questoes() => db.select(db.questoesProva).get();

    test('importa Araucária; matéria nova não entra em concurso', () async {
      final c = await db.criarConcurso(nome: 'Guarda', cor: 1);
      await db.adicionarMateria(c, 'Língua portuguesa', 1);
      final r = await importar(db, jsonAraucaria);
      expect(r.provaNova, isTrue);
      expect(r.novas, 36);
      final qs = await questoes();
      expect(qs, hasLength(36));
      expect({for (final q in qs) q.topicoOriginal}, hasLength(36));
      // Língua Portuguesa já existia: reaproveitada, sem duplicar.
      final mats = await db.todasMaterias();
      expect(mats, hasLength(8));
      expect(r.materiasCriadas, hasLength(7));
      expect(r.materiasCriadas, isNot(contains('Língua Portuguesa')));
      final doConcurso = await db.watchMaterias(c).first;
      expect(doConcurso.map((m) => m.materia.nome), ['Língua portuguesa']);

      final p = (await db.watchProvas().first).single;
      expect(p.questoes, 36);
      expect(p.prova.totalQuestoes, 40);
      expect(jsonDecode(p.prova.descartadas), hasLength(4));
      expect(await db.select(db.textosBase).get(), hasLength(2));
      final q1 = qs.firstWhere((q) => q.numero == 1);
      expect(q1.textoId, isNotNull);
    });

    test('importar a mesma prova duas vezes não duplica', () async {
      await importar(db, jsonAraucaria);
      final r = await importar(db, jsonAraucaria);
      expect(r.provaNova, isFalse);
      expect(r.novas, 0);
      expect(r.repetidas, 36);
      expect(await questoes(), hasLength(36));
      expect(await db.select(db.provas).get(), hasLength(1));
      expect(await db.select(db.textosBase).get(), hasLength(2));
      expect(await db.todasMaterias(), hasLength(8));
    });

    test('continuação colada depois completa a mesma prova', () async {
      final a = araucaria(), b = araucaria();
      final qs = a['questoes'] as List;
      a['questoes'] = qs.sublist(0, 10);
      b['questoes'] = qs.sublist(10);
      final ra = await importar(db, jsonEncode(a));
      final rb = await importar(db, jsonEncode(b));
      expect(ra.novas + rb.novas, 36);
      expect(rb.provaNova, isFalse);
      expect(await db.select(db.provas).get(), hasLength(1));
    });

    test('preliminar → definitivo atualiza respostas e status', () async {
      final pre = araucaria();
      (pre['prova'] as Map)['gabarito'] = 'preliminar';
      final gl = (pre['prova'] as Map)['gabarito_lido'] as Map;
      gl['7'] = 'B';
      gl['24'] = 'A';
      gl['9'] = 'C';
      for (final q in pre['questoes'] as List) {
        if (q['numero'] == 7) {
          q['resposta'] = 'B';
          q['status'] = ['revisar'];
        }
        if (q['numero'] == 24) {
          q['resposta'] = 'A';
          q['status'] = <String>[];
        }
        if (q['numero'] == 9) q['resposta'] = 'C';
      }
      await importar(db, jsonEncode(pre));
      var qs = await questoes();
      expect(qs.firstWhere((q) => q.numero == 7).resposta, 'B');
      expect((await db.select(db.provas).getSingle()).gabarito, 'preliminar');

      final r = await importar(db, jsonAraucaria);
      expect(r.viraDefinitivo, isTrue);
      expect(r.novas, 0);
      expect(r.mudancas, [
        'Questão 7: resposta B → X, anulada',
        'Questão 9: resposta C → D',
        'Questão 24: resposta A → X, anulada',
      ]);
      qs = await questoes();
      expect(qs, hasLength(36));
      final q7 = qs.firstWhere((q) => q.numero == 7);
      expect(q7.resposta, 'X');
      expect(StatusQuestao.separar(q7.status), {'anulada', 'revisar'});
      final prova = await db.select(db.provas).getSingle();
      expect(prova.gabarito, 'definitivo');
      expect(jsonDecode(prova.gabaritoLido)['9'], 'D');

      // Colar o preliminar de novo não desfaz o definitivo.
      await importar(db, jsonEncode(pre));
      expect((await questoes()).firstWhere((q) => q.numero == 9).resposta, 'D');
    });

    test(
      'tópico casa com o edital; sem semelhança fica "sem tópico"',
      () async {
        final c = await db.criarConcurso(nome: 'Guarda', cor: 1);
        final m = await db.adicionarMateria(
          c,
          'Cidadania e Segurança Pública',
          1,
        );
        final t = await db.adicionarTopico(
          m,
          'Estatuto Geral das Guardas Municipais (Lei 13.022/2014)',
        );
        final l = lerProva(jsonAraucaria);
        final sug = await db.ligarTopicos(l.prova!);
        final q39 = l.prova!.questoes.firstWhere((q) => q.numero == 39);
        expect(q39.topicoId, t);
        final q13 = l.prova!.questoes.firstWhere((q) => q.numero == 13);
        expect(q13.topicoId, isNull); // Agenda 21: nada parecido
        expect(sug[13], isEmpty);

        // O usuário pede para criar um tópico novo para a 13.
        q13
          ..criarTopico = true
          ..topicoDecidido = true;
        await db.importarProva(l.prova!);
        final qs = await questoes();
        final g39 = qs.firstWhere((q) => q.numero == 39);
        expect(g39.topicoId, t);
        expect(
          g39.topicoOriginal,
          'Estatuto das Guardas – princípios mínimos de atuação',
        );
        final g13 = qs.firstWhere((q) => q.numero == 13);
        final novo = await db.topico(g13.topicoId!);
        expect(novo!.nome, 'Agenda 21 (Rio-92) – desenvolvimento sustentável');
        // Tópico novo entra no edital de quem tem a matéria.
        expect(await db.watchVinculos(novo.id).first, {c});
      },
    );

    test('escopo: foco, sem tópico e "Tudo junto"', () async {
      final a = await db.criarConcurso(nome: 'Guarda', cor: 1);
      final b = await db.criarConcurso(nome: 'PM', cor: 2);
      final m = await db.adicionarMateria(
        a,
        'Cidadania e Segurança Pública',
        1,
      );
      await db.adicionarMateria(b, 'Direito Penal', 1);
      await db.adicionarTopico(
        m,
        'Estatuto Geral das Guardas Municipais (Lei 13.022/2014)',
        concursoIds: [a],
      );
      await importar(db, jsonAraucaria);

      Future<List<int>> nums(String? c) async => [
        for (final q in await db.questoesCompletas(
          filtro: FiltroQuestoes(concursoId: c),
        ))
          q.questao.numero,
      ]..sort();

      // Guarda: 39 (tópico no edital) + 13, 38 e 40 (sem tópico, matéria
      // no concurso). A 38 e a 40 também casam com o Estatuto.
      final guarda = await nums(a);
      expect(guarda, containsAll([13, 38, 39, 40]));
      expect(guarda.every((n) => [13, 38, 39, 40].contains(n)), isTrue);
      // PM: Direito Penal sem tópicos → as duas "sem tópico".
      expect(await nums(b), [31, 32]);
      expect(await nums(null), hasLength(36));
    });

    test('sorteio exclui anuladas, desatualizadas e "revisar"', () async {
      await importar(db, jsonAraucaria);
      final padrao = await db.questoesFiltradas(const FiltroQuestoes());
      final ns = {for (final q in padrao) q.questao.numero};
      expect(ns, hasLength(32)); // 36 - (6, 7, 24, 37)
      for (final n in [6, 7, 24, 37]) {
        expect(ns, isNot(contains(n)));
      }
      final sim = await db.sortear(const FiltroQuestoes(), 100);
      expect(sim, hasLength(32));

      final todas = await db.questoesFiltradas(
        const FiltroQuestoes(
          incluirAnuladas: true,
          incluirDesatualizadas: true,
          incluirRevisar: true,
        ),
      );
      expect(todas, hasLength(36));

      // "Conferi, está certa" libera a 6.
      final q6 = todas.firstWhere((q) => q.questao.numero == 6);
      await db.conferirQuestao(q6.id);
      expect(await db.questoesFiltradas(const FiltroQuestoes()), hasLength(33));
      // A 7 continua fora: é anulada.
      final q7 = todas.firstWhere((q) => q.questao.numero == 7);
      await db.conferirQuestao(q7.id);
      expect(await db.questoesFiltradas(const FiltroQuestoes()), hasLength(33));
    });

    test('treino rápido prioriza nunca feitas e as que errei', () async {
      await importar(db, jsonAraucaria);
      final todas = await db.questoesFiltradas(const FiltroQuestoes());
      // Respondo 30 das 32: 5 erradas, 25 certas.
      for (final (i, q) in todas.take(30).indexed) {
        await db.registrarResposta(
          questaoId: q.id,
          marcada: 'A',
          acertou: i >= 5,
          segundos: 60,
          modo: 'treino',
        );
      }
      final nunca = {for (final q in todas.skip(30)) q.id};
      final erradas = {for (final q in todas.take(5)) q.id};
      final t = await db.treinoRapido(null);
      expect(t, hasLength(10));
      expect(t.take(2).map((q) => q.id).toSet(), nunca);
      expect(t.skip(2).take(5).map((q) => q.id).toSet(), erradas);

      final so = await db.questoesFiltradas(
        const FiltroQuestoes(soErradas: true),
      );
      expect(so.map((q) => q.id).toSet(), erradas);
      final nf = await db.questoesFiltradas(
        const FiltroQuestoes(soNuncaFeitas: true),
      );
      expect(nf.map((q) => q.id).toSet(), nunca);
    });

    test('% de acerto do tópico recalculada; anuladas não contam', () async {
      final c = await db.criarConcurso(nome: 'Guarda', cor: 1);
      final m = await db.adicionarMateria(
        c,
        'Matemática e Raciocínio Lógico',
        1,
      );
      final t = await db.adicionarTopico(m, 'Teoria dos conjuntos');
      await importar(db, jsonAraucaria);
      final todas = await db.questoesCompletas(
        filtro: const FiltroQuestoes(
          incluirAnuladas: true,
          incluirRevisar: true,
        ),
      );
      final q7 = todas.firstWhere((q) => q.questao.numero == 7); // anulada
      expect(q7.questao.topicoId, t);
      final q8 = todas.firstWhere((q) => q.questao.numero == 8);
      // Liga a 8 ao mesmo tópico para ter duas questões nele.
      await (db.update(db.questoesProva)..where((x) => x.id.equals(q8.id)))
          .write(QuestoesProvaCompanion(topicoId: Value(t)));

      await db.registrarResposta(
        questaoId: q7.id,
        marcada: 'A',
        acertou: false,
        segundos: 30,
        modo: 'treino',
      );
      await db.registrarResposta(
        questaoId: q8.id,
        marcada: 'B',
        acertou: true,
        segundos: 30,
        modo: 'treino',
      );
      await db.registrarResposta(
        questaoId: q8.id,
        marcada: 'A',
        acertou: false,
        segundos: 30,
        modo: 'treino',
      );
      await db.registrarSessoesDeQuestoes([
        (materiaId: m, topicoId: t, acertou: null, segundos: 30),
        (materiaId: m, topicoId: t, acertou: true, segundos: 30),
        (materiaId: m, topicoId: t, acertou: false, segundos: 30),
      ]);

      var ss = await db.watchSessoesComQuestoes().first;
      int feitas(String? top) => ss
          .where((s) => s.topicoId == top)
          .fold(0, (a, s) => a + s.questoesFeitas);
      int acertos(String? top) => ss
          .where((s) => s.topicoId == top)
          .fold(0, (a, s) => a + s.questoesAcertos);
      expect(feitas(t), 2); // a anulada não conta
      expect(acertos(t), 1);
      // A sessão do treino conta o tempo, com método Questões.
      final treino = ss.singleWhere((s) => s.origem == 'provas');
      expect(treino.metodo, 'questoes');
      expect(treino.minutos, 2);
      expect(treino.questoesFeitas, 0); // os números vêm das respostas
      final gravada = (await db.watchTodasSessoes().first).single;
      expect(gravada.questoesFeitas, 2);

      // Mais um acerto: recalcula.
      await db.registrarResposta(
        questaoId: q8.id,
        marcada: 'B',
        acertou: true,
        segundos: 30,
        modo: 'simulado',
      );
      ss = await db.watchSessoesComQuestoes().first;
      expect(feitas(t), 3);
      expect(acertos(t), 2);
      final doTopico = await db.watchSessoesDoTopicoComQuestoes(t).first;
      expect(doTopico.fold<int>(0, (a, s) => a + s.questoesFeitas), 3);

      // Excluir a prova tira as respostas das estatísticas.
      final p = (await db.watchProvas().first).single;
      expect(p.respostas, 4);
      await db.excluirProva(p.prova.id);
      ss = await db.watchSessoesComQuestoes().first;
      expect(feitas(t), 0);
      expect(await db.select(db.respostas).get(), isEmpty);
      expect(await questoes(), isEmpty);
      expect(await db.watchProvas().first, isEmpty);
      // O tempo estudado continua.
      expect(ss.single.minutos, 2);
    });

    test('matéria só com questões não some ao excluir concurso', () async {
      final c = await db.criarConcurso(nome: 'Guarda', cor: 1);
      await db.adicionarMateria(c, 'Português', 1);
      await importar(db, jsonAraucaria);
      await db.excluirConcurso(c);
      expect(await questoes(), hasLength(36));
      expect(await db.materiaPorNome('Português'), isNull);
    });

    test('legislação antiga ganha selo', () {
      expect(ehLegislacao('Leis Penais Especiais', ''), isTrue);
      expect(ehLegislacao('Língua Portuguesa', 'Crase'), isFalse);
      expect(provaAntiga(2019, DateTime(2026)), isTrue);
      expect(provaAntiga(2023, DateTime(2026)), isFalse);
    });

    test('sorteio sem repetição e na ordem de prioridade', () {
      final l = sortearPriorizando(
        [
          const ItemSorteio('a', feitas: 1, errouUltima: false),
          const ItemSorteio('b', feitas: 0, errouUltima: false),
          const ItemSorteio('c', feitas: 2, errouUltima: true),
        ],
        3,
        rnd: math.Random(1),
      );
      expect(l, ['b', 'c', 'a']);
    });
  });

  test(
    'provas e respostas sincronizam em dois aparelhos, com exclusão',
    () async {
      final servidor = ServidorFalso();
      final a = Aparelho('A', servidor), b = Aparelho('B', servidor);
      await importar(a.db, jsonAraucaria);
      final q = (await a.db.questoesCompletas()).first;
      await a.db.registrarResposta(
        questaoId: q.id,
        marcada: 'A',
        acertou: true,
        segundos: 10,
        modo: 'treino',
      );
      await a.db.adicionarPrint(q.id, 'x.jpg');
      await a.sincronizar();
      await b.sincronizar();
      expect(await b.db.select(b.db.questoesProva).get(), hasLength(36));
      expect(await b.db.select(b.db.textosBase).get(), hasLength(2));
      expect(await b.db.select(b.db.respostas).get(), hasLength(1));
      expect(await b.db.select(b.db.printsQuestao).get(), isEmpty);
      expect(await b.db.todasMaterias(), hasLength(8));

      // B confere a 6 e A recebe.
      final q6 = (await b.db.select(b.db.questoesProva).get()).firstWhere(
        (x) => x.numero == 6,
      );
      await b.db.conferirQuestao(q6.id);
      await b.sincronizar();
      await a.sincronizar();
      final a6 = (await a.db.select(a.db.questoesProva).get()).firstWhere(
        (x) => x.numero == 6,
      );
      expect(a6.status, '');

      // A exclui a prova; B também perde.
      await a.db.excluirProva((await a.db.select(a.db.provas).getSingle()).id);
      await a.sincronizar();
      await b.sincronizar();
      expect(await b.db.select(b.db.provas).get(), isEmpty);
      expect(await b.db.select(b.db.questoesProva).get(), isEmpty);
      expect(await b.db.select(b.db.respostas).get(), isEmpty);
      await a.db.close();
      await b.db.close();
    },
  );

  test('migra banco v5 -> v6 mantendo os dados', () async {
    final dir = await Directory.systemTemp.createTemp('edital');
    final arquivo = File('${dir.path}/edital.sqlite');
    var db = AppDatabase(NativeDatabase(arquivo));
    final c = await db.criarConcurso(nome: 'PM', cor: 1);
    final m = await db.adicionarMateria(c, 'Português', 1);
    await db.registrarSessao(dia: DateTime.now(), minutos: 30, materiaId: m);
    for (final t in [
      'prints_questao',
      'respostas',
      'questoes_prova',
      'textos_base',
      'provas',
    ]) {
      for (final op in ['ins', 'upd', 'toque', 'del']) {
        await db.customStatement('DROP TRIGGER IF EXISTS sync_${op}_$t');
      }
      await db.customStatement('DROP TABLE $t');
    }
    await db.customStatement('ALTER TABLE sessoes DROP COLUMN origem');
    await db.customStatement('PRAGMA user_version = 5');
    await db.close();

    db = AppDatabase(NativeDatabase(arquivo));
    expect((await db.watchTodasSessoes().first).single.minutos, 30);
    await importar(db, jsonAraucaria);
    expect(await db.select(db.questoesProva).get(), hasLength(36));
    // Os gatilhos do sync pegam as tabelas novas.
    final pend = await db
        .customSelect(
          "SELECT COUNT(*) AS n FROM sync_pendentes WHERE tabela = 'questoes_prova'",
        )
        .getSingle();
    expect(pend.read<int>('n'), 36);
    expect(chaveTexto('Língua'), 'lingua');
    await db.close();
    await dir.delete(recursive: true);
  });
}
