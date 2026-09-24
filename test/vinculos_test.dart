import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/logic/importar_edital.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sincronizacao_test.dart' show Aparelho, ServidorFalso;

AppDatabase bancoMemoria() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

List<String> nomes(List<Topico> l) => [for (final t in l) t.nome];

/// Tópicos por edital: a matéria e o tópico são compartilhados (um
/// progresso só), mas cada concurso mostra só os tópicos do seu edital.
void main() {
  late AppDatabase db;
  setUp(() => db = bancoMemoria());
  tearDown(() => db.close());

  Future<int> vinculos(String topicoId) async =>
      (await db.watchVinculos(topicoId).first).length;

  test(
    'mesmo tópico importado em dois concursos: um tópico, dois vínculos',
    () async {
      final a = await db.criarConcurso(nome: 'Guarda', cor: 1);
      final b = await db.criarConcurso(nome: 'PM', cor: 2);
      await db.importarConteudo(
        a,
        separarEdital('LÍNGUA PORTUGUESA:\nCrase\nPontuação\n- Vírgula'),
      );
      final (_, novos) = await db.importarConteudo(
        b,
        separarEdital('LÍNGUA PORTUGUESA:\ncrase\nRegência'),
      );
      expect(novos, 1); // só "Regência" é novo; "crase" reaproveita "Crase"

      final m = (await db.materiaPorNome('Língua Portuguesa'))!.id;
      final todos = await db.watchTopicos(m, semFiltro: true).first;
      expect(nomes(todos).where((n) => chaveTexto(n) == 'crase'), hasLength(1));
      final crase = todos.firstWhere((t) => t.nome == 'Crase');
      expect(await db.watchVinculos(crase.id).first, {a, b});
      // Subtópicos não têm vínculo próprio: seguem o pai.
      final virgula = todos.firstWhere((t) => t.nome == 'Vírgula');
      expect(await vinculos(virgula.id), 0);
    },
  );

  test('o progresso é um só, com os mesmos revisões e flashcards', () async {
    final a = await db.criarConcurso(nome: 'Guarda', cor: 1);
    final b = await db.criarConcurso(nome: 'PM', cor: 2);
    await db.importarConteudo(a, separarEdital('PORTUGUÊS:\nCrase'));
    final m = (await db.materiaPorNome('Português'))!.id;
    final crase = (await db.watchTopicos(m, concursoId: a).first).single;
    await db.marcarVisto(crase.id, true);
    await db.salvarFlashcard(topicoId: crase.id, frente: 'P', verso: 'R');

    await db.importarConteudo(b, separarEdital('PORTUGUÊS:\nCrase'));
    final emB = (await db.watchTopicos(m, concursoId: b).first).single;
    expect(emB.id, crase.id);
    expect(emB.visto, isTrue);
    expect(
      await db
          .watchCartoesParaRevisar(concursoId: b, ate: DateTime(9999))
          .first,
      hasLength(1),
    );
    expect(
      await db.watchRevisoesPendentes(DateTime(9999), concursoId: b).first,
      hasLength(3),
    );
  });

  test('com um concurso em foco, só os tópicos do edital dele', () async {
    // O caso real: o exemplo e "Caldas" dividem Língua Portuguesa.
    await db.carregarExemplo();
    final exemplo = (await db.watchConcursos().first).single.id;
    final caldas = await db.criarConcurso(nome: 'Guarda Caldas Novas', cor: 2);
    await db.importarConteudo(
      caldas,
      separarEdital(
        'LÍNGUA PORTUGUESA:\nCompreensão textual\nCrase\nPontuação\n'
        'NOÇÕES DE INFORMÁTICA:\nHardware e software',
      ),
    );
    final port = (await db.materiaPorNome('Língua Portuguesa'))!.id;

    final deCaldas = await db.watchTopicos(port, concursoId: caldas).first;
    expect(
      nomes(deCaldas),
      unorderedEquals(['Crase', 'Pontuação', 'Compreensão textual']),
    );
    expect(nomes(deCaldas), isNot(contains('Ortografia oficial')));

    final doExemplo = await db.watchTopicos(port, concursoId: exemplo).first;
    expect(nomes(doExemplo), contains('Ortografia oficial'));
    expect(nomes(doExemplo), isNot(contains('Compreensão textual')));

    // Tudo junto: a união dos dois editais.
    final uniao = await db.watchTopicos(port).first;
    expect(uniao.length, doExemplo.length + 1);

    // Contagens da matéria (sidebar, grade, estatísticas, ciclo).
    final matsCaldas = await db.watchMaterias(caldas).first;
    final pc = matsCaldas.firstWhere((m) => m.materia.id == port);
    expect(pc.total, 3);
    final todosCaldas = await db.watchTodosTopicos(concursoId: caldas).first;
    expect(todosCaldas, hasLength(4));

    // Progresso por concurso (Meus concursos).
    final prog = await db.watchProgressoConcursos().first;
    expect(prog[caldas]!.total, 4);

    // Revisões só do edital em foco.
    final ortografia = doExemplo.firstWhere(
      (t) => t.nome == 'Ortografia oficial',
    );
    await db.marcarVisto(ortografia.id, true);
    final crase = deCaldas.firstWhere((t) => t.nome == 'Crase');
    await db.marcarVisto(crase.id, true);
    final revCaldas = await db
        .watchRevisoesPendentes(DateTime(9999), concursoId: caldas)
        .first;
    expect({for (final r in revCaldas) r.topico.nome}, {'Crase'});
    final revExemplo = await db
        .watchRevisoesPendentes(DateTime(9999), concursoId: exemplo)
        .first;
    expect(
      {for (final r in revExemplo) r.topico.nome},
      {
        'Ortografia oficial',
        'Crase', // o exemplo também tem Crase: é o mesmo tópico
      },
    );
  });

  test('tirar e pôr o vínculo pela tela do tópico', () async {
    final a = await db.criarConcurso(nome: 'A', cor: 1);
    final b = await db.criarConcurso(nome: 'B', cor: 2);
    final m = await db.adicionarMateria(a, 'Direito', 1);
    await db.adicionarMateria(b, 'Direito', 1);
    // Criado sem concurso definido: entra em todos que têm a matéria.
    final t = await db.adicionarTopico(m, 'Atos');
    expect(await db.watchVinculos(t).first, {a, b});
    await db.desvincular(t, b);
    expect(await db.watchTopicos(m, concursoId: b).first, isEmpty);
    expect(await db.watchTopicos(m, concursoId: a).first, hasLength(1));
    await db.vincular(t, b);
    await db.vincular(t, b); // repetir não duplica
    expect(await db.watchVinculos(t).first, {a, b});
    // Subtópico segue o pai.
    final sub = await db.adicionarTopico(m, 'Elementos', paiId: t);
    expect(
      nomes(await db.watchTopicos(m, concursoId: b).first),
      unorderedEquals(['Atos', 'Elementos']),
    );
    expect((await db.raizDoTopico(sub))!.id, t);
  });

  test(
    'excluir concurso apaga só os vínculos dele; órfãos ficam "sem edital"',
    () async {
      final a = await db.criarConcurso(nome: 'A', cor: 1);
      final b = await db.criarConcurso(nome: 'B', cor: 2);
      await db.importarConteudo(
        a,
        separarEdital('DIREITO:\nAtos\nPoderes\n- Hierárquico'),
      );
      await db.importarConteudo(b, separarEdital('DIREITO:\nAtos'));
      final m = (await db.materiaPorNome('Direito'))!.id;
      final atos = (await db.watchTopicos(m, concursoId: b).first).single;
      await db.marcarVisto(atos.id, true);

      await db.excluirConcurso(a);

      // "Atos" ainda está no edital de B, com o progresso.
      final emB = (await db.watchTopicos(m, concursoId: b).first).single;
      expect(emB.id, atos.id);
      expect(emB.visto, isTrue);
      expect(await db.watchVinculos(atos.id).first, {b});
      // "Poderes" (só de A) não foi apagado: está sem edital, com o subtópico.
      final sem = await db.watchTopicosSemEdital(m).first;
      expect(nomes(sem), unorderedEquals(['Poderes', 'Hierárquico']));
      expect(nomes(await db.watchTopicos(m).first), ['Atos']);

      expect(await db.excluirTopicosSemEdital(m), 1);
      expect(await db.watchTopicosSemEdital(m).first, isEmpty);
      expect(nomes(await db.watchTopicos(m, semFiltro: true).first), ['Atos']);
    },
  );

  test('tirar a matéria do concurso tira os tópicos do edital dele', () async {
    final a = await db.criarConcurso(nome: 'A', cor: 1);
    final b = await db.criarConcurso(nome: 'B', cor: 2);
    await db.importarConteudo(a, separarEdital('DIREITO:\nAtos'));
    await db.importarConteudo(b, separarEdital('DIREITO:\nAtos'));
    final m = (await db.materiaPorNome('Direito'))!.id;
    await db.removerMateriaDoConcurso(a, m);
    final atos = (await db.watchTopicos(m, concursoId: b).first).single;
    expect(await db.watchVinculos(atos.id).first, {b});
  });

  test(
    'migração v4 -> v5: cada tópico entra em todo concurso da matéria',
    () async {
      final dir = await Directory.systemTemp.createTemp('edital');
      final arquivo = File('${dir.path}/edital.sqlite');
      var db = AppDatabase(NativeDatabase(arquivo));
      final a = await db.criarConcurso(nome: 'A', cor: 1);
      final b = await db.criarConcurso(nome: 'B', cor: 2);
      final c = await db.criarConcurso(nome: 'C', cor: 3);
      final m = await db.adicionarMateria(a, 'Português', 1);
      await db.adicionarMateria(b, 'Português', 1);
      await db.adicionarMateria(c, 'Matemática', 2);
      await db.adicionarTopicosEmLote(m, 'Crase\n- Casos\nPontuação');
      final crase = (await db.watchTopicos(m).first).first;
      await db.marcarVisto(crase.id, true);
      await db.salvarFlashcard(topicoId: crase.id, frente: 'P', verso: 'R');
      // "Rebaixa" para a v4: sem a tabela de vínculos.
      await db.customStatement('DROP TABLE topico_concursos');
      await db.customStatement('PRAGMA user_version = 4');
      await db.close();

      db = AppDatabase(NativeDatabase(arquivo));
      final todos = await db.watchTopicos(m, semFiltro: true).first;
      expect(todos, hasLength(3));
      for (final t in todos.where((t) => t.paiId == null)) {
        expect(await db.watchVinculos(t.id).first, {a, b});
      }
      expect(await db.watchTopicos(m, concursoId: c).first, isEmpty);
      expect(
        nomes(await db.watchTopicos(m, concursoId: a).first),
        unorderedEquals(['Crase', 'Pontuação', 'Casos']),
      );
      final crase2 = todos.firstWhere((t) => t.id == crase.id);
      expect(crase2.visto, isTrue);
      expect(
        await db.watchRevisoesPendentes(DateTime(9999), concursoId: b).first,
        hasLength(3),
      );
      expect(
        await db
            .watchCartoesParaRevisar(concursoId: a, ate: DateTime(9999))
            .first,
        hasLength(1),
      );
      // Os vínculos criados na migração vão para a nuvem.
      final pend = await db
          .customSelect(
            "SELECT COUNT(*) AS n FROM sync_pendentes WHERE tabela = 'topico_concursos'",
          )
          .getSingle();
      expect(pend.read<int>('n'), 4);
      await db.close();
      await dir.delete(recursive: true);
    },
  );

  test(
    'sync: vínculos vão e voltam entre dois aparelhos, inclusive exclusão',
    () async {
      final servidor = ServidorFalso();
      final tablet = Aparelho('tablet', servidor);
      final celular = Aparelho('celular', servidor);
      addTearDown(() async {
        await tablet.db.close();
        await celular.db.close();
        servidor.banco.close();
      });

      final a = await tablet.db.criarConcurso(nome: 'A', cor: 1);
      final b = await tablet.db.criarConcurso(nome: 'B', cor: 2);
      await tablet.db.importarConteudo(
        a,
        separarEdital('DIREITO:\nAtos\nPoderes'),
      );
      await tablet.db.importarConteudo(b, separarEdital('DIREITO:\nAtos'));
      await tablet.sincronizar();
      await celular.sincronizar();

      final m = (await celular.db.materiaPorNome('Direito'))!.id;
      expect(nomes(await celular.db.watchTopicos(m, concursoId: b).first), [
        'Atos',
      ]);
      final atos =
          (await celular.db.watchTopicos(m, concursoId: b).first).single;
      expect(await celular.db.watchVinculos(atos.id).first, {a, b});

      // O celular tira "Atos" do edital de A; o tablet recebe a exclusão.
      await celular.db.desvincular(atos.id, a);
      await celular.sincronizar();
      await tablet.sincronizar();
      expect(await tablet.db.watchVinculos(atos.id).first, {b});
      expect(nomes(await tablet.db.watchTopicos(m, concursoId: a).first), [
        'Poderes',
      ]);

      // Excluir o concurso B no tablet apaga os vínculos dele no celular.
      await tablet.db.excluirConcurso(b);
      await tablet.sincronizar();
      await celular.sincronizar();
      expect(await celular.db.watchVinculos(atos.id).first, isEmpty);
      expect(nomes(await celular.db.watchTopicosSemEdital(m).first), ['Atos']);
    },
  );
}
