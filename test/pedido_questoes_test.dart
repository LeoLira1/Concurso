import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/data/pedido_db.dart';
import 'package:edital/data/questoes_topico_db.dart';
import 'package:edital/logic/pedido_questoes.dart';
import 'package:edital/logic/questoes_topico.dart';
import 'package:edital/screens/pedir_questoes_screen.dart';
import 'package:edital/state/app_state.dart';
import 'package:edital/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

final _base = DateTime(2026, 1, 1);

QuestaoExistente q(
  int i, {
  String? enunciado,
  int acertos = 0,
  int erros = 0,
  String? subtopico,
  bool suspeito = false,
}) => QuestaoExistente(
  enunciado: enunciado ?? 'Enunciado da questão número $i',
  gabarito: 'C',
  respostaCerta: 'resposta $i',
  acertos: acertos,
  erros: erros,
  criadoEm: _base.add(Duration(minutes: i)),
  subtopico: subtopico,
  suspeito: suspeito,
);

/// Linhas da seção [titulo] (até a próxima linha em branco).
List<String> secao(String texto, String titulo) {
  final linhas = texto.split('\n');
  final i = linhas.indexOf(titulo);
  expect(i, isNot(-1), reason: 'falta a seção $titulo');
  return linhas.skip(i + 1).takeWhile((l) => l.isNotEmpty).toList();
}

ContextoPedido contextoTopico(List<QuestaoExistente> qs) => ContextoPedido(
  concurso: 'Guarda Municipal de Araucária',
  banca: 'IBFC',
  materia: 'Língua Portuguesa',
  topicos: [
    TopicoPedido(
      nome: 'Conjunções',
      subtopicos: const ['Adversativas', 'Aditivas'],
      questoes: qs,
    ),
  ],
);

void main() {
  group('montagem do texto', () {
    test('segue a ordem pedida e traz as instruções fixas', () {
      final t = montarPedido(contextoTopico([q(1)]), quantidade: 20);
      final ordem = [
        'REGRAS',
        'CONTEXTO',
        'NOMES EXATOS (copie assim)',
        'SITUAÇÃO DO TÓPICO',
        'JÁ EXISTEM (não repita estes conceitos)',
        'ONDE EU MAIS ERRO',
      ].map(t.indexOf).toList();
      expect(ordem.every((i) => i >= 0), isTrue, reason: '$ordem');
      expect([...ordem]..sort(), ordem);
      expect(t, startsWith('Gere 20 questões inéditas'));
      expect(t, contains('5 alternativas (A a E)'));
      expect(t, contains('gabarito'));
      expect(t, contains('explicação curta'));
      expect(
        t,
        contains('Dificuldade de 1 (fácil) a 5 (difícil), bem distribuída'),
      );
      expect(t, contains('bloco de código ```json'));
      expect(t, contains('EXATAMENTE'));
      expect(t, contains('Não invente tópicos'));
      expect(t, contains('nem reescritos com outras palavras'));
      final regras = t.substring(t.indexOf('REGRAS'), t.indexOf('CONTEXTO'));
      expect(
        regras,
        contains(
          'Cada questão precisa ter um enunciado diferente: não repita o '
          'enunciado de outra questão deste lote nem os da lista "Já existem".',
        ),
      );
      expect(
        regras,
        contains(
          'Evite enunciados genéricos como "Assinale a alternativa '
          'correta": inclua no enunciado o assunto específico',
        ),
      );
      expect(t, contains('Concurso em foco: Guarda Municipal de Araucária'));
      expect(t, contains('Banca: IBFC'));
    });

    test('o exemplo do formato é o JSON da etapa 8 e o app lê de volta', () {
      final t = montarPedido(contextoTopico([]), quantidade: 10);
      final linha = t
          .split('\n')
          .firstWhere((l) => l.trimLeft().startsWith('[{"materia"'));
      final lista = jsonDecode(linha.trim()) as List;
      expect((lista.single as Map).keys, [
        'materia',
        'topico',
        'subtopico',
        'dificuldade',
        'enunciado',
        'alternativas',
        'gabarito',
        'explicacao',
      ]);
      // Uma resposta nesse formato entra direto no "Colar questões".
      final l = lerQuestoes(linha);
      expect(
        l.questoes.single.valida,
        isTrue,
        reason: '${l.questoes.single.erros}',
      );
      expect(l.questoes.single.materia, 'Língua Portuguesa');
      expect(l.questoes.single.topico, 'Conjunções');
      expect(l.questoes.single.subtopico, 'Adversativas');
    });

    test('nomes exatos: matéria, tópico e subtópicos como estão', () {
      final t = montarPedido(contextoTopico([]), quantidade: 10);
      expect(secao(t, 'NOMES EXATOS (copie assim)'), [
        'Matéria: Língua Portuguesa',
        'Tópico: Conjunções',
        'Subtópicos existentes:',
        '- Adversativas',
        '- Aditivas',
      ]);
    });

    test('situação: total, % de acerto e gabaritos suspeitos', () {
      final t = montarPedido(
        contextoTopico([
          q(1, acertos: 3, erros: 1),
          q(2, erros: 0, acertos: 0, suspeito: true),
          q(3, acertos: 0, erros: 0, suspeito: true),
        ]),
        quantidade: 10,
      );
      expect(secao(t, 'SITUAÇÃO DO TÓPICO'), [
        'Total: 3 questões · 75% de acerto (4 respostas)',
        'Gabarito suspeito: 2 questões marcadas',
      ]);
    });

    test('"Já existem": até 60, as mais recentes, com até 120 caracteres', () {
      final longo = 'Palavra ' * 40; // 320 caracteres
      final qs = [for (var i = 0; i < 75; i++) q(i, enunciado: '$i: $longo')];
      final t = montarPedido(contextoTopico(qs), quantidade: 10);
      final s = secao(t, 'JÁ EXISTEM (não repita estes conceitos)');
      expect(s.first, 'Questões (75):');
      final itens = s.where((l) => l.startsWith('- ')).toList();
      expect(itens, hasLength(limiteExistentesTopico));
      for (final l in itens) {
        expect(l.substring(2).length, lessThanOrEqualTo(limiteResumo));
        expect(l, endsWith('…'));
      }
      // As mais recentes primeiro: 74, 73, ... 15.
      expect(itens.first, startsWith('- 74: '));
      expect(itens.last, startsWith('- 15: '));
      expect(s.last, '  (e mais 15 mais antigas)');
    });

    test('resumir junta as linhas e não corta o que é curto', () {
      expect(resumir('Qual   é\n a regra?'), 'Qual é a regra?');
      final r = resumir('x' * 300);
      expect(r.length, limiteResumo);
      expect(r, endsWith('…'));
    });

    test('subtópico aparece entre colchetes na lista', () {
      final t = montarPedido(
        contextoTopico([q(1, subtopico: 'Adversativas')]),
        quantidade: 10,
      );
      expect(t, contains('- [Adversativas] Enunciado da questão número 1'));
    });

    test('"Onde eu mais erro": até 10, enunciado completo e resposta', () {
      final longo = 'Enunciado bem comprido ${'e detalhado ' * 20}';
      final qs = [
        q(0, enunciado: longo, acertos: 0, erros: 30),
        for (var i = 1; i <= 14; i++) q(i, acertos: 1, erros: 1 + i),
        q(20, acertos: 5, erros: 5), // empate não entra
        q(21, acertos: 3, erros: 1), // mais acertos não entra
      ];
      final t = montarPedido(contextoTopico(qs), quantidade: 20);
      final s = secao(t, 'ONDE EU MAIS ERRO');
      final numeradas = s.where((l) => RegExp(r'^\d+\. ').hasMatch(l)).toList();
      expect(numeradas, hasLength(limiteErros));
      // A pior primeiro, com o enunciado inteiro.
      expect(numeradas.first, '1. ${longo.trim()}');
      expect(s[2], '   Resposta certa: C) resposta 0 (errei 30, acertei 0)');
      expect(s.join('\n'), isNot(contains('número 20')));
      expect(s.join('\n'), isNot(contains('número 21')));
      expect(s.first, contains('mesmo conceito de outro jeito'));
      expect(t, isNot(contains('Foco em reforçar meus erros')));
    });

    test('foco "reforçar meus erros" pede metade para esses conceitos', () {
      final qs = [q(1, erros: 2)];
      final t = montarPedido(
        contextoTopico(qs),
        quantidade: 30,
        foco: FocoPedido.erros,
      );
      expect(
        t,
        contains('pelo menos 15 das 30 questões devem ir para esses conceitos'),
      );
    });

    test('flashcards e os dois usam o formato da etapa 9', () {
      final ctx = ContextoPedido(
        materia: 'Língua Portuguesa',
        topicos: [
          TopicoPedido(
            nome: 'Crase',
            flashcards: [
              FlashcardExistente(
                frente: 'Crase antes de hora?',
                criadoEm: _base,
              ),
            ],
          ),
        ],
      );
      final f = montarPedido(ctx, quantidade: 10, tipo: TipoPedido.flashcards);
      expect(f, startsWith('Gere 10 flashcards inéditos'));
      expect(f, contains('"frente":"..."'));
      expect(f, isNot(contains('"alternativas"')));
      expect(f, contains('- Crase antes de hora?'));
      expect(f, contains('Subtópicos existentes: nenhum (use só o tópico)'));
      expect(f, contains('Concurso: nenhum em foco'));
      expect(f, contains('Banca: não informada'));

      final a = montarPedido(ctx, quantidade: 20, tipo: TipoPedido.ambos);
      expect(
        a,
        startsWith(
          'Gere 20 questões inéditas de múltipla escolha e 20 flashcards',
        ),
      );
      expect(a, contains('duas listas JSON'));
      expect(a, contains('"alternativas"'));
      expect(a, contains('"frente"'));
    });

    test('matéria inteira: todos os tópicos, 15 por tópico e distribuição', () {
      final ctx = ContextoPedido(
        concurso: 'PM',
        materia: 'Língua Portuguesa',
        materiaInteira: true,
        topicos: [
          TopicoPedido(
            nome: 'Crase',
            questoes: [for (var i = 0; i < 20; i++) q(i, acertos: 1, erros: 1)],
          ),
          TopicoPedido(nome: 'Conjunções', subtopicos: const ['Adversativas']),
        ],
      );
      final t = montarPedido(ctx, quantidade: 30);
      expect(secao(t, 'NOMES EXATOS (copie assim)'), [
        'Matéria: Língua Portuguesa',
        'Tópicos do edital:',
        '- Crase',
        '- Conjunções',
        '  - subtópico: Adversativas',
      ]);
      final s = secao(t, 'SITUAÇÃO DA MATÉRIA');
      expect(
        s,
        contains('- Crase: 20 questões · 50% de acerto (40 respostas)'),
      );
      expect(s, contains('- Conjunções: 0 questões · sem respostas ainda'));
      expect(
        s.last,
        contains(
          'priorizando os que têm menos questões e os de menor % de acerto',
        ),
      );
      final e = secao(t, 'JÁ EXISTEM (não repita estes conceitos)');
      expect(e.first, 'Crase · Questões (20):');
      expect(
        e.where((l) => l.startsWith('- ')),
        hasLength(limiteExistentesMateria),
      );
      expect(e.last, '  (e mais 5 mais antigas)');
    });
  });

  group('dados do banco', () {
    late AppDatabase db;
    setUp(() => db = bancoMemoria());
    tearDown(() => db.close());

    Future<(String, Materia, Topico, Topico)> montar() async {
      final pm = await db.criarConcurso(nome: 'PM-PR', banca: 'AOCP', cor: 1);
      final mid = await db.adicionarMateria(pm, 'Língua Portuguesa', 2);
      final l = lerQuestoes(
        jsonEncode([
          for (final (i, sub) in [(1, null), (2, 'Adversativas'), (3, null)])
            {
              'materia': 'Língua Portuguesa',
              'topico': 'Conjunções',
              'subtopico': ?sub,
              'enunciado': 'Questão $i sobre conjunções',
              'alternativas': {'A': 'um', 'B': 'dois', 'C': 'três'},
              'gabarito': 'B',
            },
        ]),
      );
      await db.importarQuestoesTopico(l, concursoId: pm);
      final m = (await db.watchMateria(mid).first)!;
      final tops = await db.watchTopicos(mid, concursoId: pm).first;
      final conj = tops.firstWhere((t) => t.nome == 'Conjunções');
      final adv = tops.firstWhere((t) => t.nome == 'Adversativas');
      await db.adicionarTopico(mid, 'Crase', concursoIds: [pm]);
      final qs = await db.watchQuestoesTopico(topicoId: conj.id).first;
      final q1 = qs.firstWhere(
        (x) => x.questao.enunciado.startsWith('Questão 1'),
      );
      await db.responderQuestaoTopico(q1.questao, acertou: false);
      await db.marcarSuspeito(qs.last.id, true);
      return (pm, m, conj, adv);
    }

    test('tópico: nomes, subtópicos, erros com a resposta certa', () async {
      final (pm, m, conj, _) = await montar();
      final c = await db.contextoPedido(
        materia: m,
        topico: conj,
        concursoId: pm,
      );
      expect(c.concurso, 'PM-PR');
      expect(c.banca, 'AOCP');
      expect(c.materiaInteira, isFalse);
      final t = c.topicos.single;
      expect(t.nome, 'Conjunções');
      expect(t.subtopicos, ['Adversativas']);
      expect(t.questoes, hasLength(3));
      expect(t.questoes.where((x) => x.suspeito), hasLength(1));
      final texto = montarPedido(c, quantidade: 10);
      expect(texto, contains('- [Adversativas] Questão 2 sobre conjunções'));
      expect(texto, contains('1. Questão 1 sobre conjunções'));
      expect(texto, contains('Resposta certa: B) dois (errei 1, acertei 0)'));
    });

    test('subtópico aberto vale pelo tópico de cima', () async {
      final (pm, m, _, adv) = await montar();
      final c = await db.contextoPedido(
        materia: m,
        topico: adv,
        concursoId: pm,
      );
      expect(c.topicos.single.nome, 'Conjunções');
      expect(c.subtopicoAberto, 'Adversativas');
      expect(
        montarPedido(c, quantidade: 10),
        contains('Todos os itens devem usar o subtópico: Adversativas'),
      );
    });

    test('matéria: todos os tópicos do edital, com os números', () async {
      final (pm, m, _, _) = await montar();
      final c = await db.contextoPedido(materia: m, concursoId: pm);
      expect(c.materiaInteira, isTrue);
      expect(c.topicos.map((t) => t.nome), ['Conjunções', 'Crase']);
      expect(c.topicos.first.subtopicos, ['Adversativas']);
      expect(c.topicos.first.questoes, hasLength(3));
      expect(c.topicos.last.questoes, isEmpty);
    });
  });

  testWidgets('tela: opções refazem o texto e "Copiar" copia', (t) async {
    final db = bancoMemoria();
    addTearDown(db.close);
    t.view.physicalSize = const Size(1280, 800) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    String? copiado;
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiado = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    final (pm, m) = (await t.runAsync(() async {
      final pm = await db.criarConcurso(nome: 'PM', cor: 1);
      final mid = await db.adicionarMateria(pm, 'Língua Portuguesa', 2);
      await db.adicionarTopico(mid, 'Crase', concursoIds: [pm]);
      return (pm, (await db.watchMateria(mid).first)!);
    }))!;
    await t.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: db),
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: MaterialApp(
          theme: temaEdital(),
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PedirQuestoesScreen(materia: m, concursoId: pm),
        ),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await t.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await t.pump(const Duration(milliseconds: 300));
    }
    String texto() => t
        .widget<TextField>(find.byKey(const ValueKey('texto-pedido')))
        .controller!
        .text;
    expect(texto(), startsWith('Gere 10 questões'));
    expect(texto(), contains('- Crase'));

    await t.tap(find.byKey(const ValueKey('pedido-30')));
    await t.tap(find.byKey(const ValueKey('pedido-TipoPedido.ambos')));
    await t.pump();
    expect(
      texto(),
      startsWith(
        'Gere 30 questões inéditas de múltipla escolha e 30 flashcards',
      ),
    );

    await t.enterText(find.byKey(const ValueKey('texto-pedido')), 'meu texto');
    await t.tap(find.byKey(const ValueKey('copiar-pedido')));
    await t.pump();
    expect(copiado, 'meu texto');
    expect(find.textContaining('Pedido copiado'), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });
}
