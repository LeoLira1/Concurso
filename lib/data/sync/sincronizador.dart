import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';
import 'cliente_turso.dart';
import 'infra.dart';

/// Resultado de uma rodada de sincronização.
class ResultadoSinc {
  const ResultadoSinc({
    required this.enviados,
    required this.recebidos,
    required this.versao,
  });
  final int enviados;
  final int recebidos;

  /// Última versão do servidor já recebida (guardar para a próxima vez).
  final int versao;
}

/// Sincroniza o banco local com uma tabela genérica `registros` no Turso.
///
/// - Cada linha local vira um registro (tabela, chave, JSON, atualizado_em).
/// - O servidor numera cada gravação com uma `versao` crescente; cada
///   aparelho baixa só o que veio depois da última versão que já viu.
/// - Conflito: vale a alteração mais recente (atualizado_em).
/// - Exclusões viram registros marcados como excluídos.
class Sincronizador {
  Sincronizador({
    required this.db,
    required this.remoto,
    required this.dispositivo,
  });

  final AppDatabase db;
  final ExecutorRemoto remoto;

  /// Identifica este aparelho (para não reaplicar o que ele mesmo enviou).
  final String dispositivo;

  static const _tamanhoLote = 200;

  static const _upsertRemoto = '''
    INSERT INTO registros (tabela, chave, dados, atualizado_em, excluido, versao, dispositivo)
    VALUES (?, ?, ?, ?, ?, (SELECT COALESCE(MAX(versao), 0) + 1 FROM registros), ?)
    ON CONFLICT (tabela, chave) DO UPDATE SET
      dados = CASE WHEN excluded.atualizado_em >= registros.atualizado_em
                   THEN excluded.dados ELSE registros.dados END,
      excluido = CASE WHEN excluded.atualizado_em >= registros.atualizado_em
                      THEN excluded.excluido ELSE registros.excluido END,
      dispositivo = CASE WHEN excluded.atualizado_em >= registros.atualizado_em
                         THEN excluded.dispositivo ELSE 'servidor' END,
      atualizado_em = MAX(excluded.atualizado_em, registros.atualizado_em),
      versao = excluded.versao''';
  // Quando a alteração enviada é mais antiga que a do servidor, ela é
  // descartada, mas a versão avança e o dispositivo vira "servidor": assim
  // o aparelho que enviou recebe de volta a versão vencedora.

  Future<void> prepararServidor() => remoto.executar(const [
    Comando('''CREATE TABLE IF NOT EXISTS registros (
          tabela TEXT NOT NULL,
          chave TEXT NOT NULL,
          dados TEXT,
          atualizado_em INTEGER NOT NULL,
          excluido INTEGER NOT NULL DEFAULT 0,
          versao INTEGER NOT NULL,
          dispositivo TEXT,
          PRIMARY KEY (tabela, chave)
        )'''),
    Comando(
      'CREATE INDEX IF NOT EXISTS registros_versao ON registros (versao)',
    ),
  ]);

  Future<int> contarRemoto() async {
    final r = await remoto.executar(const [
      Comando('SELECT COUNT(*) AS n FROM registros WHERE excluido = 0'),
    ]);
    return (r.first.first['n'] as int?) ?? 0;
  }

  Future<int> contarLocal() async {
    var n = 0;
    for (final t in tabelasSincronizadas) {
      final r = await db
          .customSelect('SELECT COUNT(*) AS n FROM ${t.nome}')
          .getSingle();
      n += r.read<int>('n');
    }
    return n;
  }

  Future<int> contarPendentes() async =>
      (await db
              .customSelect('SELECT COUNT(*) AS n FROM sync_pendentes')
              .getSingle())
          .read<int>('n');

  /// Marca todas as linhas locais para envio (primeira conexão / "juntar").
  Future<void> marcarTudoPendente() async {
    for (final t in tabelasSincronizadas) {
      final chave = t.chaves.join(" || '|' || ");
      await db.customStatement(
        "INSERT OR REPLACE INTO sync_pendentes (tabela, chave, marca) "
        "SELECT '${t.nome}', $chave, (SELECT COALESCE(MAX(marca), 0) + 1 FROM sync_pendentes) FROM ${t.nome}",
      );
    }
  }

  /// Apaga os dados deste aparelho (para usar só os da nuvem).
  Future<void> apagarLocal() => _aplicando(() async {
    await db.customStatement('DELETE FROM anexos');
    await db.customStatement('DELETE FROM prints_questao');
    for (final t in tabelasSincronizadas.reversed) {
      await db.customStatement('DELETE FROM ${t.nome}');
    }
    await db.customStatement('DELETE FROM sync_pendentes');
    await db.customStatement('DELETE FROM sync_aliases');
  });

  /// Envia as pendências e recebe as novidades desde [desdeVersao].
  Future<ResultadoSinc> sincronizar({required int desdeVersao}) async {
    await prepararServidor();
    final enviados = await _enviar();
    final (recebidos, versao) = await _receber(desdeVersao);
    return ResultadoSinc(
      enviados: enviados,
      recebidos: recebidos,
      versao: versao,
    );
  }

  // ---------------------------------------------------------------------------
  // Envio
  // ---------------------------------------------------------------------------

  Future<Linha?> _linhaLocal(TabelaSinc t, String chave) async {
    final partes = chave.split('|');
    final onde = t.chaves.map((c) => '$c = ?').join(' AND ');
    final r = await db
        .customSelect(
          'SELECT * FROM ${t.nome} WHERE $onde',
          variables: [for (final p in partes) Variable.withString(p)],
        )
        .getSingleOrNull();
    return r?.data;
  }

  Future<int> _enviar() async {
    final snap =
        (await db
                .customSelect(
                  'SELECT COALESCE(MAX(marca), 0) AS m FROM sync_pendentes',
                )
                .getSingle())
            .read<int>('m');
    final pendentes = await db
        .customSelect(
          'SELECT tabela, chave FROM sync_pendentes WHERE marca <= ? ORDER BY marca',
          variables: [Variable.withInt(snap)],
        )
        .get();
    final agora = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var enviados = 0;

    for (var i = 0; i < pendentes.length; i += _tamanhoLote) {
      final lote = pendentes.skip(i).take(_tamanhoLote).toList();
      final comandos = <Comando>[];
      for (final p in lote) {
        final t = tabelaSinc(p.read<String>('tabela'));
        if (t == null) continue;
        final chave = p.read<String>('chave');
        final linha = await _linhaLocal(t, chave);
        comandos.add(
          Comando(_upsertRemoto, [
            t.nome,
            chave,
            linha == null ? null : jsonEncode(linha),
            linha?['atualizado_em'] ?? agora,
            linha == null ? 1 : 0,
            dispositivo,
          ]),
        );
      }
      if (comandos.isNotEmpty) await remoto.executar(comandos);
      enviados += comandos.length;
      await db.batch((b) {
        for (final p in lote) {
          b.customStatement(
            'DELETE FROM sync_pendentes WHERE tabela = ? AND chave = ? AND marca <= ?',
            [p.read<String>('tabela'), p.read<String>('chave'), snap],
          );
        }
      });
    }
    return enviados;
  }

  // ---------------------------------------------------------------------------
  // Recebimento
  // ---------------------------------------------------------------------------

  Future<(int, int)> _receber(int desde) async {
    var versao = desde;
    var recebidos = 0;
    while (true) {
      final r = await remoto.executar([
        Comando(
          'SELECT tabela, chave, dados, atualizado_em, excluido, versao, dispositivo '
          'FROM registros WHERE versao > ? ORDER BY versao LIMIT 500',
          [versao],
        ),
      ]);
      final linhas = r.first;
      if (linhas.isEmpty) break;
      recebidos += await _aplicar(linhas);
      versao = linhas.last['versao'] as int;
      if (linhas.length < 500) break;
    }
    return (recebidos, versao);
  }

  /// Executa [f] com os gatilhos de sincronização desligados (para não
  /// reenviar o que acabou de chegar) e sem checagem de chaves estrangeiras
  /// (os registros podem chegar fora de ordem).
  Future<T> _aplicando<T>(Future<T> Function() f) async {
    await db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      return await db.transaction(() async {
        await db.customStatement(
          'UPDATE sync_controle SET aplicando = 1 WHERE id = 1',
        );
        try {
          return await f();
        } finally {
          await db.customStatement(
            'UPDATE sync_controle SET aplicando = 0 WHERE id = 1',
          );
        }
      });
    } finally {
      await db.customStatement('PRAGMA foreign_keys = ON');
      // SQL direto não avisa as telas; avisa agora.
      db.markTablesUpdated(db.allTables);
    }
  }

  final _colunas = <String, Set<String>>{};

  Future<Set<String>> _colunasLocais(String tabela) async =>
      _colunas[tabela] ??= {
        for (final r
            in await db.customSelect('PRAGMA table_info($tabela)').get())
          r.read<String>('name'),
      };

  Future<void> _pendente(String tabela, String chave) => db.customStatement(
    'INSERT OR REPLACE INTO sync_pendentes (tabela, chave, marca) '
    'VALUES (?, ?, (SELECT COALESCE(MAX(marca), 0) + 1 FROM sync_pendentes))',
    [tabela, chave],
  );

  Future<int> _aplicar(List<Linha> registros) {
    final ordem = {
      for (final (i, t) in tabelasSincronizadas.indexed) t.nome: i,
    };
    final lista = [...registros]
      ..sort((a, b) {
        final c = (ordem[a['tabela']] ?? 99).compareTo(
          ordem[b['tabela']] ?? 99,
        );
        return c != 0 ? c : (a['versao'] as int).compareTo(b['versao'] as int);
      });

    return _aplicando(() async {
      final aliases = {
        for (final r
            in await db
                .customSelect(
                  "SELECT de, para FROM sync_aliases WHERE tabela = 'materias'",
                )
                .get())
          r.read<String>('de'): r.read<String>('para'),
      };
      var aplicados = 0;
      for (final reg in lista) {
        if (reg['dispositivo'] == dispositivo) continue;
        final t = tabelaSinc(reg['tabela'] as String);
        if (t == null) continue;
        final atualizado = reg['atualizado_em'] as int;

        if (reg['excluido'] == 1) {
          if (t.nome == 'materias' && aliases.containsKey(reg['chave'])) {
            continue;
          }
          final chave = _traduzirChave(t, reg['chave'] as String, aliases);
          final local = await _linhaLocal(t, chave);
          if (local == null) continue;
          if ((local['atualizado_em'] as int? ?? 0) > atualizado) continue;
          final partes = chave.split('|');
          await db.customStatement(
            'DELETE FROM ${t.nome} WHERE ${t.chaves.map((c) => '$c = ?').join(' AND ')}',
            partes,
          );
          aplicados++;
          continue;
        }

        final dados = Map<String, Object?>.from(
          jsonDecode(reg['dados'] as String) as Map,
        );
        final mid = dados['materia_id'];
        if (mid is String && aliases.containsKey(mid)) {
          dados['materia_id'] = aliases[mid];
        }

        if (t.nome == 'materias') {
          final pular = await _resolverMateriaDuplicada(dados, aliases);
          if (pular) continue;
        }

        final chave = t.chaves.map((c) => '${dados[c]}').join('|');
        final local = await _linhaLocal(t, chave);
        if (local != null &&
            (local['atualizado_em'] as int? ?? 0) > atualizado) {
          continue;
        }

        final cols = await _colunasLocais(t.nome);
        final usadas = [
          for (final c in dados.keys)
            if (cols.contains(c)) c,
        ];
        final atualizar = [
          for (final c in usadas)
            if (!t.chaves.contains(c)) '$c = excluded.$c',
        ];
        await db.customStatement(
          'INSERT INTO ${t.nome} (${usadas.join(', ')}) VALUES (${List.filled(usadas.length, '?').join(', ')}) '
          'ON CONFLICT (${t.chaves.join(', ')}) DO ${atualizar.isEmpty ? 'NOTHING' : 'UPDATE SET ${atualizar.join(', ')}'}',
          [for (final c in usadas) dados[c]],
        );
        aplicados++;
      }
      return aplicados;
    });
  }

  String _traduzirChave(
    TabelaSinc t,
    String chave,
    Map<String, String> aliases,
  ) {
    if (t.nome != 'concurso_materias') return chave;
    final p = chave.split('|');
    return '${p[0]}|${aliases[p[1]] ?? p[1]}';
  }

  /// Duas matérias com o mesmo nome criadas em aparelhos diferentes viram
  /// uma só. Os dois aparelhos escolhem a mesma (menor id), então convergem.
  /// Retorna true se a matéria recebida deve ser descartada.
  Future<bool> _resolverMateriaDuplicada(
    Map<String, Object?> dados,
    Map<String, String> aliases,
  ) async {
    final remotoId = dados['id'] as String;
    final outra = await db
        .customSelect(
          'SELECT id FROM materias WHERE chave = ? AND id <> ?',
          variables: [
            Variable.withString('${dados['chave']}'),
            Variable.withString(remotoId),
          ],
        )
        .getSingleOrNull();
    if (outra == null) return false;
    final localId = outra.read<String>('id');

    if (localId.compareTo(remotoId) < 0) {
      // Fica a local; a recebida passa a apontar para ela.
      aliases[remotoId] = localId;
      await db.customStatement(
        "INSERT OR REPLACE INTO sync_aliases (tabela, de, para) VALUES ('materias', ?, ?)",
        [remotoId, localId],
      );
      return true;
    }

    // Fica a recebida: move tudo da local para ela.
    for (final tabela in const [
      'topicos',
      'questoes',
      'sessoes',
      'questoes_prova',
    ]) {
      final ids = await db
          .customSelect(
            'SELECT id FROM $tabela WHERE materia_id = ?',
            variables: [Variable.withString(localId)],
          )
          .get();
      await db.customStatement(
        'UPDATE $tabela SET materia_id = ? WHERE materia_id = ?',
        [remotoId, localId],
      );
      for (final r in ids) {
        await _pendente(tabela, r.read<String>('id'));
      }
    }
    final vinculos = await db
        .customSelect(
          'SELECT concurso_id FROM concurso_materias WHERE materia_id = ?',
          variables: [Variable.withString(localId)],
        )
        .get();
    for (final v in vinculos) {
      final c = v.read<String>('concurso_id');
      await db.customStatement(
        'INSERT OR IGNORE INTO concurso_materias (concurso_id, materia_id, ordem, atualizado_em, peso, dificuldade, no_ciclo) '
        'SELECT concurso_id, ?, ordem, atualizado_em, peso, dificuldade, no_ciclo FROM concurso_materias '
        'WHERE concurso_id = ? AND materia_id = ?',
        [remotoId, c, localId],
      );
      await db.customStatement(
        'DELETE FROM concurso_materias WHERE concurso_id = ? AND materia_id = ?',
        [c, localId],
      );
      await _pendente('concurso_materias', '$c|$localId');
      await _pendente('concurso_materias', '$c|$remotoId');
    }
    await db.customStatement('DELETE FROM materias WHERE id = ?', [localId]);
    await _pendente('materias', localId);
    aliases[localId] = remotoId;
    await db.customStatement(
      "INSERT OR REPLACE INTO sync_aliases (tabela, de, para) VALUES ('materias', ?, ?)",
      [localId, remotoId],
    );
    return false;
  }
}
