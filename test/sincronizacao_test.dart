import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/data/sync/cliente_turso.dart';
import 'package:edital/data/sync/sincronizador.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';

/// SQLite em memória fazendo o papel do Turso.
class ServidorFalso implements ExecutorRemoto {
  final banco = sqlite3.openInMemory();
  int chamadas = 0;

  @override
  Future<List<List<Linha>>> executar(List<Comando> comandos) async {
    chamadas++;
    return [
      for (final c in comandos)
        if (c.sql.trimLeft().toUpperCase().startsWith('SELECT'))
          [
            for (final r in banco.select(c.sql, c.args))
              Map<String, Object?>.from(r),
          ]
        else
          () {
            banco.execute(c.sql, c.args);
            return <Linha>[];
          }(),
    ];
  }
}

AppDatabase novoBanco() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

/// Um "aparelho": banco local + a última versão recebida.
class Aparelho {
  Aparelho(this.nome, ServidorFalso servidor)
    : db = novoBanco(),
      _servidor = servidor;
  final String nome;
  final AppDatabase db;
  final ServidorFalso _servidor;
  int versao = 0;

  Sincronizador get sinc =>
      Sincronizador(db: db, remoto: _servidor, dispositivo: nome);

  Future<ResultadoSinc> sincronizar() async {
    final r = await sinc.sincronizar(desdeVersao: versao);
    versao = r.versao;
    return r;
  }
}

Future<List<String>> nomesMaterias(AppDatabase db) async => [
  for (final m in await db.todasMaterias()) m.nome,
];

void main() {
  late ServidorFalso servidor;
  late Aparelho tablet;
  late Aparelho celular;

  setUp(() {
    servidor = ServidorFalso();
    tablet = Aparelho('tablet', servidor);
    celular = Aparelho('celular', servidor);
  });
  tearDown(() async {
    await tablet.db.close();
    await celular.db.close();
    servidor.banco.close();
  });

  test('o que é criado no tablet aparece no celular, e vice-versa', () async {
    final c = await tablet.db.criarConcurso(
      nome: 'PM-SP',
      banca: 'Vunesp',
      cor: 1,
    );
    final m = await tablet.db.adicionarMateria(c, 'Português', 2);
    await tablet.db.adicionarTopicosEmLote(m, 'Crase\nPontuação\n- Vírgula');
    await tablet.db.registrarSessao(
      dia: DateTime(2026, 9, 20),
      minutos: 50,
      materiaId: m,
      pontoParada: 'pág. 10',
    );
    await tablet.db.salvarFlashcard(
      topicoId: (await tablet.db.watchTopicos(m).first).first.id,
      frente: 'P',
      verso: 'R',
    );

    final envio = await tablet.sincronizar();
    expect(envio.enviados, greaterThanOrEqualTo(7));
    expect(await tablet.sinc.contarPendentes(), 0);

    final receb = await celular.sincronizar();
    expect(receb.recebidos, envio.enviados);
    final concursos = await celular.db.watchConcursos().first;
    expect(concursos.single.id, c); // mesmos ids nos dois aparelhos
    expect(concursos.single.banca, 'Vunesp');
    final topicos = await celular.db.watchTopicos(m).first;
    expect(
      topicos.map((t) => t.nome),
      containsAll(['Crase', 'Pontuação', 'Vírgula']),
    );
    expect(topicos.firstWhere((t) => t.nome == 'Vírgula').paiId, isNotNull);
    expect(
      (await celular.db.watchUltimaParada(m).first)?.pontoParada,
      'pág. 10',
    );
    expect(await celular.db.watchCartoesParaRevisar().first, hasLength(1));
    // O que chegou não volta como pendência (sem eco).
    expect(await celular.sinc.contarPendentes(), 0);

    // Celular marca um tópico como visto -> tablet recebe (com as revisões).
    final crase = topicos.firstWhere((t) => t.nome == 'Crase');
    await celular.db.marcarVisto(crase.id, true);
    await celular.sincronizar();
    await tablet.sincronizar();
    expect((await tablet.db.topico(crase.id))!.visto, isTrue);
    expect(await tablet.db.select(tablet.db.revisoes).get(), hasLength(3));

    // Nada novo: nada enviado nem recebido.
    final vazio = await tablet.sincronizar();
    expect(vazio.enviados, 0);
    expect(vazio.recebidos, 0);
  });

  test('exclusões (inclusive em cascata) chegam ao outro aparelho', () async {
    final c = await tablet.db.criarConcurso(nome: 'A', cor: 1);
    final m = await tablet.db.adicionarMateria(c, 'Direito', 1);
    final t = await tablet.db.adicionarTopico(m, 'Atos');
    await tablet.db.marcarVisto(t, true);
    await tablet.sincronizar();
    await celular.sincronizar();
    expect(await celular.db.select(celular.db.revisoes).get(), hasLength(3));

    await tablet.db.excluirTopico(t); // apaga revisões em cascata
    await tablet.sincronizar();
    await celular.sincronizar();
    expect(await celular.db.topico(t), isNull);
    expect(await celular.db.select(celular.db.revisoes).get(), isEmpty);

    await celular.db.excluirConcurso(c); // concurso + vínculo + matéria órfã
    await celular.sincronizar();
    await tablet.sincronizar();
    expect(await tablet.db.watchConcursos().first, isEmpty);
    expect(await tablet.db.todasMaterias(), isEmpty);
  });

  test('conflito: vale a alteração mais recente', () async {
    final c = await tablet.db.criarConcurso(nome: 'Original', cor: 1);
    await tablet.sincronizar();
    await celular.sincronizar();

    // Os dois editam sem sincronizar; o celular edita "depois".
    await tablet.db.atualizarConcurso(
      c,
      nome: 'Tablet',
      banca: '',
      dataProva: null,
      cor: 1,
    );
    await celular.db.atualizarConcurso(
      c,
      nome: 'Celular',
      banca: '',
      dataProva: null,
      cor: 1,
    );
    final agora = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await tablet.db.customStatement(
      'UPDATE concursos SET atualizado_em = ? WHERE id = ?',
      [agora + 100, c],
    );
    await celular.db.customStatement(
      'UPDATE concursos SET atualizado_em = ? WHERE id = ?',
      [agora + 200, c],
    );

    await tablet.sincronizar();
    await celular.sincronizar();
    await tablet.sincronizar();
    expect((await tablet.db.watchConcurso(c).first)!.nome, 'Celular');
    expect((await celular.db.watchConcurso(c).first)!.nome, 'Celular');
  });

  test(
    'envio mais antigo que o do servidor é descartado e o aparelho se corrige',
    () async {
      final c = await tablet.db.criarConcurso(nome: 'Original', cor: 1);
      await tablet.sincronizar();
      await celular.sincronizar();
      final agora = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Celular edita "depois" e sincroniza primeiro.
      await celular.db.atualizarConcurso(
        c,
        nome: 'Novo',
        banca: '',
        dataProva: null,
        cor: 1,
      );
      await celular.db.customStatement(
        'UPDATE concursos SET atualizado_em = ? WHERE id = ?',
        [agora + 200, c],
      );
      await celular.sincronizar();
      // Tablet tinha editado "antes", offline, e só agora sincroniza.
      await tablet.db.atualizarConcurso(
        c,
        nome: 'Velho',
        banca: '',
        dataProva: null,
        cor: 1,
      );
      await tablet.db.customStatement(
        'UPDATE concursos SET atualizado_em = ? WHERE id = ?',
        [agora + 100, c],
      );
      await tablet.sincronizar();

      expect((await tablet.db.watchConcurso(c).first)!.nome, 'Novo');
      await celular.sincronizar();
      expect((await celular.db.watchConcurso(c).first)!.nome, 'Novo');
    },
  );

  test(
    'matéria com o mesmo nome criada nos dois aparelhos vira uma só',
    () async {
      final ct = await tablet.db.criarConcurso(nome: 'TRT', cor: 1);
      final mt = await tablet.db.adicionarMateria(ct, 'Português', 1);
      await tablet.db.adicionarTopico(mt, 'Crase');
      final cc = await celular.db.criarConcurso(nome: 'TRF', cor: 2);
      final mc = await celular.db.adicionarMateria(cc, 'português', 2);
      await celular.db.adicionarTopico(mc, 'Regência');
      await celular.db.registrarSessao(
        dia: DateTime.now(),
        minutos: 30,
        materiaId: mc,
      );

      for (var i = 0; i < 3; i++) {
        await tablet.sincronizar();
        await celular.sincronizar();
      }

      final vencedora = mt.compareTo(mc) < 0 ? mt : mc;
      for (final a in [tablet, celular]) {
        final mats = await a.db.todasMaterias();
        expect(mats, hasLength(1), reason: a.nome);
        expect(mats.single.id, vencedora, reason: a.nome);
        final topicos = await a.db.watchTopicos(vencedora).first;
        expect(topicos.map((t) => t.nome).toSet(), {
          'Crase',
          'Regência',
        }, reason: a.nome);
        expect(await a.db.watchConcursos().first, hasLength(2), reason: a.nome);
        // Os dois concursos apontam para a mesma matéria.
        for (final c in [ct, cc]) {
          final ms = await a.db.watchMaterias(c).first;
          expect(ms.single.materia.id, vencedora, reason: '${a.nome} $c');
        }
        final sessoes = await a.db.select(a.db.sessoes).get();
        expect(sessoes.single.materiaId, vencedora, reason: a.nome);
      }
    },
  );

  test('usar só os dados da nuvem apaga os locais e baixa tudo', () async {
    final c = await tablet.db.criarConcurso(nome: 'Da nuvem', cor: 1);
    await tablet.db.adicionarMateria(c, 'Informática', 1);
    await tablet.sincronizar();

    await celular.db.carregarExemplo(); // dados locais que serão descartados
    expect(await celular.sinc.contarRemoto(), greaterThan(0));
    await celular.sinc.apagarLocal();
    expect(await celular.sinc.contarLocal(), 0);
    expect(await celular.sinc.contarPendentes(), 0);
    celular.versao = 0;
    await celular.sincronizar();
    expect((await celular.db.watchConcursos().first).single.nome, 'Da nuvem');
    expect(await nomesMaterias(celular.db), ['Informática']);
  });

  test(
    'juntar: dados que já existiam antes de conectar também sobem',
    () async {
      // Tablet já tinha dados antes de ligar a sincronização.
      await tablet.db.carregarExemplo();
      await tablet.db.customStatement('DELETE FROM sync_pendentes');
      await tablet.sinc.marcarTudoPendente();
      final r = await tablet.sincronizar();
      expect(r.enviados, await tablet.sinc.contarLocal());
      await celular.sincronizar();
      expect(await celular.sinc.contarLocal(), await tablet.sinc.contarLocal());
    },
  );

  group('cliente HTTP do Turso', () {
    test('monta o pedido e lê a resposta no formato Hrana', () async {
      late Map<String, dynamic> pedido;
      late http.Request req;
      final cliente = ClienteTurso(
        url: 'libsql://edital-leo.turso.io',
        token: 'abc',
        cliente: MockClient((r) async {
          req = r;
          pedido = jsonDecode(r.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'baton': null,
              'base_url': null,
              'results': [
                {
                  'type': 'ok',
                  'response': {
                    'type': 'execute',
                    'result': {
                      'cols': [
                        {'name': 'n', 'decltype': 'INTEGER'},
                        {'name': 'nome', 'decltype': 'TEXT'},
                        {'name': 'x', 'decltype': null},
                      ],
                      'rows': [
                        [
                          {'type': 'integer', 'value': '42'},
                          {'type': 'text', 'value': 'Língua Portuguesa'},
                          {'type': 'null'},
                        ],
                      ],
                      'affected_row_count': 0,
                      'last_insert_rowid': null,
                    },
                  },
                },
                {
                  'type': 'ok',
                  'response': {'type': 'close'},
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final r = await cliente.executar([
        const Comando('SELECT ?, ?, ?, ?', [7, 'a', null, 1.5]),
      ]);
      expect(req.url.toString(), 'https://edital-leo.turso.io/v2/pipeline');
      expect(req.headers['Authorization'], 'Bearer abc');
      final stmt = (pedido['requests'] as List).first['stmt'] as Map;
      expect(stmt['args'], [
        {'type': 'integer', 'value': '7'},
        {'type': 'text', 'value': 'a'},
        {'type': 'null'},
        {'type': 'float', 'value': 1.5},
      ]);
      expect((pedido['requests'] as List).last, {'type': 'close'});
      expect(r.single.single, {
        'n': 42,
        'nome': 'Língua Portuguesa',
        'x': null,
      });
    });

    test('erros: token inválido e erro de SQL', () async {
      final semToken = ClienteTurso(
        url: 'https://x.turso.io',
        token: 'ruim',
        cliente: MockClient((_) async => http.Response('unauthorized', 401)),
      );
      expect(
        () => semToken.executar([const Comando('SELECT 1')]),
        throwsA(
          isA<ErroTurso>().having(
            (e) => e.autenticacao,
            'autenticacao',
            isTrue,
          ),
        ),
      );
      final comErro = ClienteTurso(
        url: 'https://x.turso.io',
        token: 't',
        cliente: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'results': [
                {
                  'type': 'error',
                  'error': {
                    'message': 'no such table: x',
                    'code': 'SQLITE_ERROR',
                  },
                },
                {
                  'type': 'ok',
                  'response': {'type': 'close'},
                },
              ],
            }),
            200,
          ),
        ),
      );
      expect(
        () => comErro.executar([const Comando('SELECT * FROM x')]),
        throwsA(
          isA<ErroTurso>().having(
            (e) => e.mensagem,
            'mensagem',
            contains('no such table'),
          ),
        ),
      );
    });

    test('normaliza a URL', () {
      expect(
        ClienteTurso.normalizarUrl('libsql://a-b.turso.io/'),
        'https://a-b.turso.io',
      );
      expect(
        ClienteTurso.normalizarUrl('a-b.turso.io'),
        'https://a-b.turso.io',
      );
      expect(
        ClienteTurso.normalizarUrl('https://a-b.turso.io'),
        'https://a-b.turso.io',
      );
    });
  });
}
