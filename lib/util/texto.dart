const _acentos = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};

/// Chave usada para reconhecer a mesma matéria entre concursos:
/// "Língua Portuguesa " e "lingua  portuguesa" viram "lingua portuguesa".
String chaveMateria(String nome) {
  final buf = StringBuffer();
  for (final r in nome.trim().toLowerCase().runes) {
    final c = String.fromCharCode(r);
    buf.write(_acentos[c] ?? c);
  }
  return buf.toString().replaceAll(RegExp(r'\s+'), ' ');
}

DateTime soDia(DateTime d) => DateTime(d.year, d.month, d.day);

const mesesPt = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

const diasSemanaCurto = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB'];

const diasSemanaLongo = [
  'Domingo',
  'Segunda',
  'Terça',
  'Quarta',
  'Quinta',
  'Sexta',
  'Sábado',
];

String dataLonga(DateTime d) =>
    '${diasSemanaLongo[d.weekday % 7]}, ${d.day} de ${mesesPt[d.month - 1].toLowerCase()}';

String dataCurta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String minutosFmt(int m) {
  if (m < 60) return '${m}min';
  final h = m ~/ 60, r = m % 60;
  return r == 0 ? '${h}h' : '${h}h${r.toString().padLeft(2, '0')}';
}
