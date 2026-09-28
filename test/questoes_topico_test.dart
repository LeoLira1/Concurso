import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/data/provas_db.dart';
import 'package:edital/data/questoes_topico_db.dart';
import 'package:edital/logic/estatisticas.dart';
import 'package:edital/logic/questoes_topico.dart';
import 'package:edital/util/texto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sincronizacao_test.dart' show Aparelho, ServidorFalso;

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

Map<String, Object?> questao({
  String materia = 'Língua Portuguesa',
  String? topico = 'Conjunções',
  String? subtopico = 'Adversativas',
  int dificuldade = 2,
  String enunciado = 'Na frase "Estudei, mas não passei", a conjunção é:',
  String gabarito = 'C',
  String explicacao = '"Mas" indica oposição.',
}) => {
  'materia': materia,
  'topico': ?topico,
  'subtopico': ?subtopico,
  'dificuldade': dificuldade,
  'enunciado': enunciado,
  'alternativas': {
    'A': 'aditiva',
    'B': 'conclusiva',
    'C': 'adversativa',
    'D': 'explicativa',
    'E': 'alternativa',
  },
  'gabarito': gabarito,
  'explicacao': explicacao,
};

String lista(List<Map<String, Object?>> qs) => jsonEncode(qs);

void main() {
  group('leitura do JSON colado', () {
    test('lê o formato pedido, com subtópico e dificuldade', () {
      final l = lerQuestoes(lista([questao()]));
      expect(l.erro, isNull);
      final q = l.questoes.single;
      expect(q.valida, isTrue, reason: '${q.erros}');
      expect(q.materia, 'Língua Portuguesa');
      expect(q.topico, 'Conjunções');
      expect(q.subtopico, 'Adversativas');
      expect(q.dificuldade, 2);
      expect(q.alternativas.keys, ['A', 'B', 'C', 'D', 'E']);
      expect(q.gabarito, 'C');
      expect(q.explicacao, '"Mas" indica oposição.');
    });

    test('aceita cercas de código e texto em volta', () {
      final l = lerQuestoes(
        'Aqui estão:\n```json\n${lista([questao()])}\n```\nBons estudos!',
      );
      expect(l.erro, isNull);
      expect(l.novas, 1);
    });

    test('JSON quebrado diz a linha', () {
      final l = lerQuestoes('[\n{"materia": "X",\n"topico" "Y"}\n]');
      expect(l.erro, contains('linha 3'));
    });

    test('erros por questão, sem travar as outras', () {
      final l = lerQuestoes(
        lista([
          questao(),
          questao(enunciado: 'Outra', gabarito: 'F'),
          {...questao(enunciado: 'Sem gabarito'), 'gabarito': ''},
          questao(enunciado: 'Sem tópico', topico: null, subtopico: null),
        ]),
      );
      expect(l.novas, 1);
      expect(l.comErro, 3);
      expect(l.questoes[1].erros.single, contains('"F" não está'));
      expect(l.questoes[2].erros.single, 'falta o gabarito');
      expect(l.questoes[3].erros.single, 'falta o tópico');
    });

    test('a tela do tópico completa matéria e tópico', () {
      final l = lerQuestoes(
        jsonEncode([
          {
            'enunciado': 'Qual?',
            'alternativas': {'A': '1', 'B': '2'},
            'gabarito': 'b',
          },
        ]),
        materiaPadrao: 'Português',
        topicoPadrao: 'Crase',
      );
      final q = l.questoes.single;
      expect(q.valida, isTrue, reason: '${q.erros}');
      expect(q.topico, 'Crase');
      expect(q.subtopico, '');
      expect(q.gabarito, 'B');
      expect(q.dificuldade, 3);
    });

    test('enunciado repetido na mesma lista entra uma vez só', () {
      final l = lerQuestoes(
        lista([
          questao(),
          questao(
            enunciado: 'na frase  "estudei mas nao passei" a conjuncao e',
          ),
        ]),
      );
      expect(l.novas, 1);
      expect(l.repetidas, 1);
      expect(l.questoes[1].repetidaDe, 'item 1 desta lista');
    });

    test('mesmo enunciado com alternativas diferentes: as duas entram', () {
      const enunciado =
          'Assinale a alternativa em que o acento grave está empregado '
          'corretamente.';
      final l = lerQuestoes(
        lista([
          questao(enunciado: enunciado),
          {
            ...questao(enunciado: enunciado),
            'alternativas': {
              'A': 'Fui à Bahia.',
              'B': 'Refiro-me à você.',
              'C': 'Saiu à cavalo.',
              'D': 'Chegou à uma hora.',
              'E': 'Andou à pé.',
            },
            'gabarito': 'A',
          },
        ]),
      );
      expect(l.novas, 2);
      expect(l.repetidas, 0);
    });

    test('duas questões idênticas no mesmo lote: só uma entra', () {
      final l = lerQuestoes(lista([questao(), questao(), questao()]));
      expect(l.novas, 1);
      expect(l.repetidas, 2);
      expect(l.questoes.first.repetida, isFalse);
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

    test('cria tópico e subtópico no edital e não duplica', () async {
      final l = lerQuestoes(
        lista([
          questao(),
          questao(enunciado: 'Outra questão', subtopico: 'Aditivas'),
          questao(enunciado: 'Terceira', subtopico: null),
        ]),
      );
      await db.marcarRepetidas(l);
      final destinos = await db.destinosColagem(l, concursoId: pm);
      expect(destinos[1]!.topicoNovo, isTrue);
      expect(destinos[1]!.subtopicoNovo, isTrue);
      expect(destinos[1]!.materiaNova, isFalse);

      final r = await db.importarQuestoesTopico(l, concursoId: pm);
      expect(r.novas, 3);
      expect(r.topicosCriados, hasLength(3)); // tópico + 2 subtópicos

      final tops = await db.watchTopicos(portugues, concursoId: pm).first;
      final conj = tops.firstWhere((t) => t.nome == 'Conjunções');
      expect(conj.paiId, isNull);
      expect(
        tops.where((t) => t.paiId == conj.id).map((t) => t.nome),
        containsAll(['Adversativas', 'Aditivas']),
      );
      // Entrou só no edital da PM (o concurso de onde colei).
      expect(await db.watchVinculos(conj.id).first, {pm});

      // As do tópico incluem as dos subtópicos.
      expect(
        await db.watchQuestoesTopico(topicoId: conj.id).first,
        hasLength(3),
      );
      final adv = tops.firstWhere((t) => t.nome == 'Adversativas');
      final qAdv = await db.watchQuestoesTopico(topicoId: adv.id).first;
      expect(qAdv.single.caminho, 'Conjunções › Adversativas');

      // Colar de novo (com outra pontuação) não duplica.
      final de2 = lerQuestoes(
        lista([
          questao(
            enunciado: 'Na frase “Estudei, mas não passei” a conjunção é',
          ),
          questao(enunciado: 'Nova de verdade'),
        ]),
      );
      await db.marcarRepetidas(de2);
      expect(de2.repetidas, 1);
      final r2 = await db.importarQuestoesTopico(de2, concursoId: pm);
      expect(r2.novas, 1);
      expect(r2.topicosCriados, isEmpty);
      expect(
        await db.watchQuestoesTopico(topicoId: conj.id).first,
        hasLength(4),
      );
    });

    test('igual à do banco (só maiúsculas, acentos e espaços): fica de fora, '
        'dizendo com qual bateu', () async {
      await db.importarQuestoesTopico(
        lerQuestoes(lista([questao()])),
        concursoId: pm,
      );
      final de2 = lerQuestoes(
        lista([
          {
            ...questao(
              enunciado:
                  '  NA FRASE "ESTUDEI, MAS NAO PASSEI",   A CONJUNCAO E: ',
            ),
            'alternativas': {
              'A': 'ADITIVA',
              'B': ' Conclusiva ',
              'C': 'adversatíva',
              'D': 'explicativa.',
              'E': 'alternativa',
            },
          },
        ]),
      );
      await db.marcarRepetidas(de2);
      final q = de2.questoes.single;
      expect(q.repetida, isTrue);
      expect(q.repetidaDe, startsWith('Conjunções › Adversativas: “Na frase'));
      final r = await db.importarQuestoesTopico(de2, concursoId: pm);
      expect(r.novas, 0);
      expect(r.repetidas, 1);
    });

    test(
      'mesmo enunciado do banco com alternativas diferentes entra',
      () async {
        await db.importarQuestoesTopico(
          lerQuestoes(lista([questao()])),
          concursoId: pm,
        );
        final de2 = lerQuestoes(
          lista([
            {
              ...questao(),
              'alternativas': {
                'A': 'concessiva',
                'B': 'conclusiva',
                'C': 'adversativa',
                'D': 'causal',
                'E': 'final',
              },
            },
          ]),
        );
        await db.marcarRepetidas(de2);
        expect(de2.repetidas, 0);
        final r = await db.importarQuestoesTopico(de2, concursoId: pm);
        expect(r.novas, 1);
      },
    );

    test('questão de Português vale para os dois concursos', () async {
      await db.importarQuestoesTopico(lerQuestoes(lista([questao()])));
      // Sem concurso: o tópico novo entra em todos que têm a matéria.
      final t = (await db.watchTopicos(portugues, concursoId: gm).first)
          .firstWhere((t) => t.nome == 'Conjunções');
      expect(await db.watchVinculos(t.id).first, {pm, gm});
      for (final c in [pm, gm]) {
        expect(
          await db
              .watchQuestoesTopico(materiaId: portugues, concursoId: c)
              .first,
          hasLength(1),
        );
      }
    });

    test('tópico que existe em outro edital ganha o vínculo', () async {
      final crase = await db.adicionarTopico(
        portugues,
        'Crase',
        concursoIds: [gm],
      );
      final l = lerQuestoes(lista([questao(topico: 'crase', subtopico: null)]));
      final d = await db.destinosColagem(l, concursoId: pm);
      expect(d[1]!.topicoNovo, isFalse);
      expect(d[1]!.entraNoEdital, isTrue);
      await db.importarQuestoesTopico(l, concursoId: pm);
      expect(await db.watchVinculos(crase).first, {pm, gm});
      expect(await db.watchQuestoesTopico(topicoId: crase).first, hasLength(1));
    });

    test('matéria nova entra no concurso de destino', () async {
      final l = lerQuestoes(
        lista([
          questao(materia: 'Direito Penal', topico: 'Crimes', subtopico: null),
        ]),
      );
      expect(
        (await db.destinosColagem(l, concursoId: pm))[1]!.materiaNova,
        isTrue,
      );
      final r = await db.importarQuestoesTopico(l, concursoId: pm);
      expect(r.materiasCriadas, ['Direito Penal']);
      final mats = await db.watchMaterias(pm).first;
      expect(mats.map((m) => m.materia.nome), contains('Direito Penal'));
      expect(
        (await db.watchMaterias(gm).first).map((m) => m.materia.nome),
        isNot(contains('Direito Penal')),
      );
    });
  });

  group('resolver: Leitner, fila e estatísticas', () {
    late AppDatabase db;
    late String pm, portugues;
    setUp(() async {
      db = bancoMemoria();
      pm = await db.criarConcurso(nome: 'PM', cor: 1);
      portugues = await db.adicionarMateria(pm, 'Língua Portuguesa', 3);
      await db.importarQuestoesTopico(
        lerQuestoes(
          lista([
            questao(enunciado: 'Difícil', dificuldade: 5, subtopico: null),
            questao(enunciado: 'Fácil', dificuldade: 1, subtopico: null),
            questao(enunciado: 'Média', dificuldade: 3, subtopico: null),
          ]),
        ),
        concursoId: pm,
      );
    });
    tearDown(() => db.close());

    test('errada volta hoje na caixa 0; certa sobe e volta depois', () async {
      // As questões importadas vencem no dia de hoje (data real).
      final agora = DateTime.now();
      final hoje = DateTime(agora.year, agora.month, agora.day, 15);
      final dia = soDia(hoje),
          diaSeguinte = DateTime(dia.year, dia.month, dia.day + 1);
      var fila = await db.filaQuestoesTopico(materiaId: portugues, hoje: hoje);
      // Novas, das mais fáceis para as mais difíceis.
      expect(
        [for (final q in fila) q.questao.enunciado],
        ['Fácil', 'Média', 'Difícil'],
      );

      final certa = await db.responderQuestaoTopico(
        fila[0].questao,
        acertou: true,
        hoje: hoje,
      );
      expect(certa.caixa, 1);
      expect(certa.proximaRevisao, diaSeguinte);
      final errada = await db.responderQuestaoTopico(
        fila[2].questao,
        acertou: false,
        hoje: hoje,
      );
      expect(errada.caixa, 0);
      expect(errada.erros, 1);
      expect(errada.proximaRevisao, dia);

      // A errada vem antes das novas; a certa só volta amanhã.
      fila = await db.filaQuestoesTopico(materiaId: portugues, hoje: hoje);
      expect([for (final q in fila) q.questao.enunciado], ['Difícil', 'Média']);
      final amanha = await db.filaQuestoesTopico(
        materiaId: portugues,
        hoje: diaSeguinte,
      );
      expect(amanha.first.questao.enunciado, 'Difícil');
      expect(amanha.map((q) => q.questao.enunciado), contains('Fácil'));

      // Errar de novo depois de subir: volta para a caixa 0.
      final sobe = await db.responderQuestaoTopico(certa, acertou: true);
      expect(sobe.caixa, 2);
      final cai = await db.responderQuestaoTopico(sobe, acertou: false);
      expect(cai.caixa, 0);

      // "Praticar todas" inclui as que ainda não venceram.
      final todas = await db.filaQuestoesTopico(
        materiaId: portugues,
        hoje: hoje,
        todas: true,
      );
      expect(todas, hasLength(3));
    });

    test('gabarito suspeito: marcar, listar e corrigir', () async {
      final q =
          (await db.watchQuestoesTopico(materiaId: portugues).first).first;
      await db.marcarSuspeito(q.id, true);
      var s = await db
          .watchQuestoesTopico(materiaId: portugues, soSuspeitas: true)
          .first;
      expect(s.single.id, q.id);
      await db.corrigirGabarito(q.id, 'A');
      s = await db
          .watchQuestoesTopico(materiaId: portugues, soSuspeitas: true)
          .first;
      expect(s, isEmpty);
      final depois = (await db.watchQuestoesTopico(materiaId: portugues).first)
          .firstWhere((x) => x.id == q.id);
      expect(depois.questao.gabarito, 'A');
    });

    test('a sessão preenche questões feitas e acertos por matéria', () async {
      final qs = await db.watchQuestoesTopico(materiaId: portugues).first;
      final t = qs.first.topico.id;
      final estudadas = await db.registrarSessaoQuestoesTopico([
        (materiaId: portugues, topicoId: t, acertou: true, segundos: 70),
        (materiaId: portugues, topicoId: t, acertou: false, segundos: 50),
        (materiaId: portugues, topicoId: t, acertou: true, segundos: 60),
      ]);
      expect(estudadas, {portugues});
      final sessoes = await db.watchSessoesComQuestoes().first;
      final s = sessoes.single;
      expect(s.metodo, 'questoes');
      expect(s.questoesFeitas, 3);
      expect(s.questoesAcertos, 2);
      expect(s.minutos, 3);
      expect(s.topicoId, t);
      expect(s.dia, soDia(DateTime.now()));

      final est = Estatisticas([
        for (final x in sessoes)
          SessaoResumo(
            dia: x.dia,
            minutos: x.minutos,
            materiaId: x.materiaId,
            feitas: x.questoesFeitas,
            acertos: x.questoesAcertos,
          ),
      ], hoje: DateTime.now());
      final pm = est.porMateria().single;
      expect(pm.feitas, 3);
      expect(pm.acerto, closeTo(2 / 3, 1e-9));
    });

    test('sessão curta conta pelo menos 1 minuto', () async {
      final t = (await db.watchQuestoesTopico(materiaId: portugues).first)
          .first
          .topico
          .id;
      await db.registrarSessaoQuestoesTopico([
        (materiaId: portugues, topicoId: t, acertou: true, segundos: 8),
      ]);
      expect((await db.watchTodasSessoes().first).single.minutos, 1);
    });

    test('excluir o tópico leva as questões junto', () async {
      final q =
          (await db.watchQuestoesTopico(materiaId: portugues).first).first;
      await db.excluirTopico(q.topico.id);
      expect(await db.watchQuestoesTopico(materiaId: portugues).first, isEmpty);
    });
  });

  test('as questões e as respostas sincronizam pelo Turso', () async {
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
    await tablet.db.importarQuestoesTopico(
      lerQuestoes(lista([questao()])),
      concursoId: c,
    );
    final q = (await tablet.db.watchQuestoesTopico(materiaId: m).first).single;
    await tablet.db.responderQuestaoTopico(q.questao, acertou: false);
    await tablet.db.marcarSuspeito(q.id, true);
    await tablet.sincronizar();
    await celular.sincronizar();

    final noCelular =
        (await celular.db
                .watchQuestoesTopico(materiaId: m, concursoId: c)
                .first)
            .single;
    expect(noCelular.id, q.id);
    expect(noCelular.questao.erros, 1);
    expect(noCelular.questao.suspeito, isTrue);
    expect(noCelular.caminho, 'Conjunções › Adversativas');

    // Exclusão também vai.
    await celular.db.excluirQuestaoTopico(q.id);
    await celular.sincronizar();
    await tablet.sincronizar();
    expect(await tablet.db.watchQuestoesTopico(materiaId: m).first, isEmpty);
  });
}
