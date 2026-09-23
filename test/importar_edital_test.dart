import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/logic/importar_edital.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> nomes(List<TopicoImportado> l) => [for (final t in l) t.nome];

void main() {
  test('Cebraspe: tudo num parágrafo, numeração decimal e grupo ignorado', () {
    const texto = '''
CONHECIMENTOS BÁSICOS: LÍNGUA PORTUGUESA: 1 Compreensão e interpretação de textos de gêneros variados. 2 Reconhecimento de tipos e gêneros textuais. 3 Domínio da ortografia oficial. 4 Domínio dos mecanismos de coesão textual. 4.1 Emprego de elementos de referenciação, substituição e repetição, de conectores e de outros elementos de sequenciação textual. 4.2 Emprego de tempos e modos verbais. 5 Domínio da estrutura morfossintática do período. 5.1 Emprego das classes de palavras. 5.2 Relações de coordenação entre orações e entre termos da oração. 6 Reescrita de frases e parágrafos do texto. ÉTICA NO SERVIÇO PÚBLICO: 1 Ética e moral. 2 Ética, princípios e valores. 3 Lei nº 8.112/1990 e alterações: regime disciplinar. NOÇÕES DE DIREITO ADMINISTRATIVO: 1 Noções de organização administrativa. 1.1 Centralização, descentralização, concentração e desconcentração. 2 Ato administrativo. 2.1 Conceito, requisitos, atributos, classificação e espécies.
''';
    final r = separarEdital(texto);
    expect(r.map((m) => m.nome), [
      'Língua Portuguesa',
      'Ética no Serviço Público',
      'Noções de Direito Administrativo',
    ]);
    final port = r[0].topicos;
    expect(port, hasLength(6));
    expect(
      port[0].nome,
      'Compreensão e interpretação de textos de gêneros variados',
    );
    expect(port[3].nome, 'Domínio dos mecanismos de coesão textual');
    expect(nomes(port[3].filhos), [
      'Emprego de elementos de referenciação, substituição e repetição, de conectores e de outros elementos de sequenciação textual',
      'Emprego de tempos e modos verbais',
    ]);
    expect(port[4].filhos, hasLength(2));
    // "Lei nº 8.112/1990" não vira numeração.
    expect(
      r[1].topicos.last.nome,
      'Lei nº 8.112/1990 e alterações: regime disciplinar',
    );
    expect(
      r[2].topicos[1].filhos.single.nome,
      'Conceito, requisitos, atributos, classificação e espécies',
    );
  });

  test('Vunesp: nomes em linha própria e tópicos sem numeração', () {
    const texto = '''
Língua Portuguesa
Leitura e interpretação de diversos tipos de textos (literários e não literários). Sinônimos e antônimos. Sentido próprio e figurado das palavras. Pontuação. Classes de palavras: substantivo, adjetivo, numeral, artigo, pronome, verbo, advérbio, preposição e conjunção: emprego e sentido que imprimem às relações que estabelecem. Concordância verbal e nominal. Regência verbal e nominal. Colocação pronominal. Crase.
Matemática
Resolução de situações-problema, envolvendo: adição, subtração, multiplicação, divisão, potenciação ou radiciação com números racionais, nas suas representações fracionária ou decimal; Mínimo múltiplo comum; Máximo divisor comum; Porcentagem; Razão e proporção; Regra de três simples ou composta.
''';
    final r = separarEdital(texto);
    expect(r.map((m) => m.nome), ['Língua Portuguesa', 'Matemática']);
    expect(r[0].topicos.map((t) => t.nome).take(4), [
      'Leitura e interpretação de diversos tipos de textos (literários e não literários)',
      'Sinônimos e antônimos',
      'Sentido próprio e figurado das palavras',
      'Pontuação',
    ]);
    expect(r[0].topicos.last.nome, 'Crase');
    expect(r[0].topicos, hasLength(9));
    expect(r[1].topicos, hasLength(6));
    expect(r[1].topicos[1].nome, 'Mínimo múltiplo comum');
  });

  test('FGV: itens numerados em linhas, quebras de linha do PDF', () {
    const texto = '''
DIREITO CONSTITUCIONAL
1. Constituição: conceito, classificação e aplicabilidade das normas
constitucionais.
2. Direitos e garantias funda-
mentais.
3. Organização do Estado.
3.1. União, Estados, Distrito Federal e Municípios.
INFORMÁTICA
1. Conceitos de internet e intranet.
2. Segurança da informação.
''';
    final r = separarEdital(texto);
    expect(r.map((m) => m.nome), ['Direito Constitucional', 'Informática']);
    expect(
      r[0].topicos[0].nome,
      'Constituição: conceito, classificação e aplicabilidade das normas constitucionais',
    );
    expect(r[0].topicos[1].nome, 'Direitos e garantias fundamentais');
    expect(
      r[0].topicos[2].filhos.single.nome,
      'União, Estados, Distrito Federal e Municípios',
    );
    expect(r[1].topicos, hasLength(2));
  });

  test('cabeçalho "Nome: conteúdo" e algarismos romanos', () {
    const texto = '''
Raciocínio Lógico: I - Proposições e conectivos. II - Tabelas-verdade. III - Equivalências lógicas.
Legislação Específica: Estatuto Geral das Guardas Municipais (Lei 13.022/2014); Estatuto do Desarmamento.
''';
    final r = separarEdital(texto);
    expect(r.map((m) => m.nome), [
      'Raciocínio Lógico',
      'Legislação Específica',
    ]);
    expect(nomes(r[0].topicos), [
      'Proposições e conectivos',
      'Tabelas-verdade',
      'Equivalências lógicas',
    ]);
    expect(nomes(r[1].topicos), [
      'Estatuto Geral das Guardas Municipais (Lei 13.022/2014)',
      'Estatuto do Desarmamento',
    ]);
  });

  test('números dentro do texto não viram tópicos', () {
    final t = separarTopicos(
      '1 Direitos e garantias (art. 5 da CF). 2 Lei 8.112 de 1990 e o art. 37 Caput. 3 Emenda 19 de 1998.',
    );
    expect(nomes(t), [
      'Direitos e garantias (art. 5 da CF)',
      'Lei 8.112 de 1990 e o art. 37 Caput',
      'Emenda 19 de 1998',
    ]);
  });

  test('marcadores (•) e texto sem nenhum cabeçalho', () {
    const texto = '''
• Crase
• Pontuação
• Concordância verbal e nominal
''';
    final r = separarEdital(texto);
    expect(r.single.nome, 'Nova matéria');
    expect(nomes(r.single.topicos), [
      'Crase',
      'Pontuação',
      'Concordância verbal e nominal',
    ]);
  });

  test('abreviações não cortam o tópico', () {
    final t = separarTopicos(
      'Direitos sociais: arts. 6º a 11. Dec. Lei nº 200. Crase.',
    );
    expect(nomes(t), [
      'Direitos sociais: arts. 6º a 11',
      'Dec. Lei nº 200',
      'Crase',
    ]);
  });

  test('nomes de matéria: maiúsculas viram título, siglas ficam', () {
    expect(
      nomeDeMateria('NOÇÕES DE DIREITO CONSTITUCIONAL:'),
      'Noções de Direito Constitucional',
    );
    expect(
      nomeDeMateria('LEGISLAÇÃO APLICADA AO MPU'),
      'Legislação Aplicada ao MPU',
    );
    expect(
      nomeDeMateria('LEI GERAL DE PROTEÇÃO DE DADOS - LGPD'),
      'Lei Geral de Proteção de Dados - LGPD',
    );
    expect(nomeDeMateria('2. INFORMÁTICA'), 'Informática');
    expect(nomeDeMateria('Língua Portuguesa'), 'Língua Portuguesa');
  });

  test('mesma matéria repetida no texto é unida', () {
    const texto =
        'PORTUGUÊS: 1 Crase. 2 Pontuação.\nPORTUGUÊS: 1 Regência. 2 Concordância.';
    final r = separarEdital(texto);
    expect(r.single.topicos, hasLength(4));
  });

  test('três níveis de numeração', () {
    final t = separarTopicos(
      '1 Atos. 1.1 Elementos. 1.1.1 Competência. 1.1.2 Forma. 1.2 Atributos. 2 Poderes.',
    );
    expect(t, hasLength(2));
    expect(t[0].filhos[0].filhos.map((x) => x.nome), ['Competência', 'Forma']);
    expect(t[0].folhas, 3);
  });

  test(
    'importar no banco: reaproveita matéria e não duplica tópicos',
    () async {
      final db = AppDatabase(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );
      final c = await db.criarConcurso(nome: 'A', cor: 1);
      final port = await db.adicionarMateria(c, 'Língua Portuguesa', 1);
      await db.adicionarTopico(port, 'Crase');

      final itens = separarEdital(
        'LÍNGUA PORTUGUESA: 1 Crase. 2 Pontuação. 2.1 Vírgula.\nINFORMÁTICA: 1 Internet. 2 Segurança.',
      );
      itens[1].incluir = true;
      final (nm, nt) = await db.importarConteudo(c, itens);
      expect(nm, 2);
      expect(
        nt,
        4,
      ); // Pontuação, Vírgula, Internet, Segurança (Crase já existia)
      final mats = await db.watchMaterias(c).first;
      expect(mats.map((m) => m.materia.nome), [
        'Língua Portuguesa',
        'Informática',
      ]);
      expect(mats.first.total, 2); // Crase + Vírgula (folhas)

      // Importar de novo não duplica nada.
      final (_, nt2) = await db.importarConteudo(
        c,
        separarEdital('LÍNGUA PORTUGUESA: 1 Crase. 2 Pontuação.'),
      );
      expect(nt2, 0);

      // Matéria desmarcada não entra.
      final so = separarEdital('HISTÓRIA: 1 Brasil Colônia. 2 Império.')
        ..first.incluir = false;
      final (nm3, _) = await db.importarConteudo(c, so);
      expect(nm3, 0);
      await db.close();
    },
  );
}
