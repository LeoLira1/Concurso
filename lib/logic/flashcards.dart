/// Repetição espaçada dos flashcards (caixas de Leitner).
///
/// Acertou: sobe uma caixa e volta em 1, 3, 7, 14 ou 30 dias.
/// Errou: volta para a caixa 0 e reaparece ainda hoje (fim da fila).
library;

const intervalosCaixas = [0, 1, 3, 7, 14, 30];
const caixaMaxima = 5;

class ResultadoCartao {
  const ResultadoCartao(this.caixa, this.proxima);
  final int caixa;
  final DateTime proxima;
}

DateTime _dia(DateTime d) => DateTime(d.year, d.month, d.day);

ResultadoCartao responderCartao({
  required int caixaAtual,
  required bool acertou,
  required DateTime hoje,
}) {
  if (!acertou) return ResultadoCartao(0, _dia(hoje));
  final caixa = (caixaAtual + 1).clamp(1, caixaMaxima);
  final d = _dia(hoje);
  return ResultadoCartao(
    caixa,
    DateTime(d.year, d.month, d.day + intervalosCaixas[caixa]),
  );
}

/// Texto do intervalo para o botão "Acertei" (ex.: "3 dias").
String proximoIntervalo(int caixaAtual) {
  final dias = intervalosCaixas[(caixaAtual + 1).clamp(1, caixaMaxima)];
  return dias == 1 ? 'amanhã' : 'em $dias dias';
}
