/// Infraestrutura local da sincronização: tabelas de controle e gatilhos
/// (triggers) que anotam toda inserção, alteração e exclusão nas tabelas
/// sincronizadas. Assim o app sabe exatamente o que enviar, inclusive
/// exclusões (que não deixariam rastro de outra forma).
library;

class TabelaSinc {
  const TabelaSinc(this.nome, this.chaves);
  final String nome;

  /// Colunas da chave primária.
  final List<String> chaves;

  /// Expressão SQL da chave (ex.: NEW.id ou NEW.concurso_id || '|' || ...).
  String chaveSql(String prefixo) =>
      chaves.map((c) => '$prefixo.$c').join(" || '|' || ");
}

/// Em ordem de dependência (pais antes dos filhos).
/// Anexos ficam de fora: o arquivo só existe no aparelho que o criou.
const tabelasSincronizadas = [
  TabelaSinc('concursos', ['id']),
  TabelaSinc('materias', ['id']),
  TabelaSinc('concurso_materias', ['concurso_id', 'materia_id']),
  TabelaSinc('topicos', ['id']),
  TabelaSinc('revisoes', ['id']),
  TabelaSinc('questoes', ['id']),
  TabelaSinc('sessoes', ['id']),
  TabelaSinc('flashcards', ['id']),
];

TabelaSinc? tabelaSinc(String nome) {
  for (final t in tabelasSincronizadas) {
    if (t.nome == nome) return t;
  }
  return null;
}

/// Comandos idempotentes (IF NOT EXISTS), executados ao abrir o banco.
List<String> comandosInfraSync() {
  const quandoAtivo = '(SELECT aplicando FROM sync_controle WHERE id = 1) = 0';
  const marca = '(SELECT COALESCE(MAX(marca), 0) + 1 FROM sync_pendentes)';
  return [
    '''CREATE TABLE IF NOT EXISTS sync_controle (
         id INTEGER PRIMARY KEY CHECK (id = 1),
         aplicando INTEGER NOT NULL DEFAULT 0
       )''',
    'INSERT OR IGNORE INTO sync_controle (id, aplicando) VALUES (1, 0)',
    // Se o app fechou no meio de uma sincronização, o flag não fica preso.
    'UPDATE sync_controle SET aplicando = 0 WHERE id = 1',
    '''CREATE TABLE IF NOT EXISTS sync_pendentes (
         tabela TEXT NOT NULL,
         chave TEXT NOT NULL,
         marca INTEGER NOT NULL,
         PRIMARY KEY (tabela, chave)
       )''',
    '''CREATE TABLE IF NOT EXISTS sync_aliases (
         tabela TEXT NOT NULL,
         de TEXT NOT NULL,
         para TEXT NOT NULL,
         PRIMARY KEY (tabela, de)
       )''',
    for (final t in tabelasSincronizadas) ...[
      '''CREATE TRIGGER IF NOT EXISTS sync_ins_${t.nome} AFTER INSERT ON ${t.nome}
         WHEN $quandoAtivo BEGIN
           INSERT OR REPLACE INTO sync_pendentes (tabela, chave, marca)
           VALUES ('${t.nome}', ${t.chaveSql('NEW')}, $marca);
         END''',
      '''CREATE TRIGGER IF NOT EXISTS sync_upd_${t.nome} AFTER UPDATE ON ${t.nome}
         WHEN $quandoAtivo BEGIN
           INSERT OR REPLACE INTO sync_pendentes (tabela, chave, marca)
           VALUES ('${t.nome}', ${t.chaveSql('NEW')}, $marca);
         END''',
      // Alterações que não mexem em atualizado_em ganham o horário atual
      // (a regra de conflito é "vale a última alteração").
      '''CREATE TRIGGER IF NOT EXISTS sync_toque_${t.nome} AFTER UPDATE ON ${t.nome}
         WHEN $quandoAtivo AND NEW.atualizado_em IS OLD.atualizado_em BEGIN
           UPDATE ${t.nome} SET atualizado_em = CAST(strftime('%s', 'now') AS INTEGER)
           WHERE rowid = NEW.rowid;
         END''',
      '''CREATE TRIGGER IF NOT EXISTS sync_del_${t.nome} AFTER DELETE ON ${t.nome}
         WHEN $quandoAtivo BEGIN
           INSERT OR REPLACE INTO sync_pendentes (tabela, chave, marca)
           VALUES ('${t.nome}', ${t.chaveSql('OLD')}, $marca);
         END''',
    ],
  ];
}
