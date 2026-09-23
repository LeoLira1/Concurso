/// Ponto de extensão para sincronizar celular + tablet via Turso (libSQL).
///
/// Ainda NÃO implementado. O banco já foi preparado para isso:
/// - todos os ids são UUID gerados no aparelho (sem conflito entre aparelhos);
/// - todas as tabelas têm `atualizado_em` (base para "última escrita vence").
///
/// Caminho previsto: trocar o executor do drift por uma réplica embutida do
/// libSQL (arquivo local + sync com a URL do Turso), ou enviar/receber as
/// linhas alteradas desde a última sincronização usando `atualizado_em`.
abstract interface class Sincronizacao {
  /// Envia alterações locais e recebe as remotas.
  Future<void> sincronizar();

  /// Momento da última sincronização bem-sucedida (null = nunca).
  DateTime? get ultimaSincronizacao;
}
