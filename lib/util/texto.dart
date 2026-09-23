import 'package:flutter/widgets.dart' show StringCharacters;

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

const _conectivosSigla = {
  'de',
  'da',
  'do',
  'das',
  'dos',
  'e',
  'em',
  'a',
  'o',
  'as',
  'os',
  'ao',
  'aos',
  'à',
  'às',
  'na',
  'no',
  'nas',
  'nos',
  'para',
  'com',
  'por',
  'noções',
  'nocoes',
};

/// Sigla curta para caber na célula da grade:
/// "Língua Portuguesa" -> "LP", "Noções de Direito Constitucional" -> "DC",
/// "Noções de Informática" -> "INFO", "Legislação Aplicada ao MPU" -> "LAM".
String siglaMateria(String nome) {
  final palavras = nome
      .split(RegExp(r'[\s\-–/]+'))
      .where((p) => p.isNotEmpty && !_conectivosSigla.contains(p.toLowerCase()))
      .toList();
  if (palavras.isEmpty) {
    return nome.length <= 4
        ? nome.toUpperCase()
        : nome.substring(0, 4).toUpperCase();
  }
  if (palavras.length == 1) {
    final p = palavras.first;
    final ehSigla = p.length <= 5 && p == p.toUpperCase();
    if (ehSigla) return p;
    return (p.length <= 4 ? p : p.substring(0, 4)).toUpperCase();
  }
  final iniciais = palavras
      .take(4)
      .map((p) => p.characters.first.toUpperCase())
      .join();
  return chaveMateria(iniciais).toUpperCase();
}
