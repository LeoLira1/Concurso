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

  group('modo estruturado', () {
    test(
      'edital de Guarda Municipal: 10 matérias, 110 tópicos, 30 subtópicos',
      () {
        expect(modoEstruturado(_editalEstruturado), isTrue);
        final r = separarEdital(_editalEstruturado);
        expect(r.map((m) => m.nome), [
          'Língua Portuguesa',
          'Noções de Informática',
          'Matemática e Raciocínio Lógico',
          'Atualidades de Caldas Novas',
          'Direitos e Deveres Individuais e Coletivos',
          'Cidadania e Segurança Pública',
          'Ética no Serviço Público',
          'Legislação de Trânsito',
          'Crimes contra a Administração Pública',
          'Leis Penais Especiais',
        ]);
        final topicos = r.fold<int>(0, (a, m) => a + m.topicos.length);
        final subtopicos = r.fold<int>(
          0,
          (a, m) => a + m.topicos.fold<int>(0, (b, t) => b + t.filhos.length),
        );
        expect(topicos, 110);
        expect(subtopicos, 30);
        // Nenhum subtópico tem filhos: só dois níveis.
        for (final m in r) {
          for (final t in m.topicos) {
            for (final f in t.filhos) {
              expect(f.filhos, isEmpty);
            }
          }
        }

        final porNome = {for (final m in r) m.nome: m.topicos};
        expect(
          {for (final e in porNome.entries) e.key: e.value.length},
          {
            'Língua Portuguesa': 19,
            'Noções de Informática': 14,
            'Matemática e Raciocínio Lógico': 18,
            'Atualidades de Caldas Novas': 10,
            'Direitos e Deveres Individuais e Coletivos': 16,
            'Cidadania e Segurança Pública': 9,
            'Ética no Serviço Público': 6,
            'Legislação de Trânsito': 1,
            'Crimes contra a Administração Pública': 11,
            'Leis Penais Especiais': 6,
          },
        );
        TopicoImportado topico(String materia, String nome) =>
            porNome[materia]!.firstWhere((t) => t.nome == nome);

        final classes = topico(
          'Língua Portuguesa',
          'Classificação e flexão das palavras',
        );
        expect(classes.filhos, hasLength(10));
        expect(classes.filhos.first.nome, 'Substantivo');
        expect(classes.filhos.last.nome, 'Interjeição');
        expect(
          topico(
            'Língua Portuguesa',
            'Termos essenciais, integrantes e acessórios da oração',
          ).filhos,
          hasLength(12),
        );
        final ctb = porNome['Legislação de Trânsito']!.single;
        expect(ctb.nome, 'Código de Trânsito Brasileiro (Lei 9.503/1997)');
        expect(ctb.filhos, hasLength(4));
        expect(ctb.filhos.last.nome, 'Capítulo XIX — Crimes de trânsito');
        expect(
          topico(
            'Leis Penais Especiais',
            'Estatuto da Criança e do Adolescente (Lei 8.069/1990)',
          ).filhos,
          hasLength(4),
        );

        // Linhas que antes viravam matéria agora são tópicos, inteiras.
        expect(
          nomes(porNome['Noções de Informática']!),
          containsAll([
            'Conceitos básicos de informática',
            'Noções de redes de computadores',
            'Segurança da informação — vírus, malwares, phishing, antivírus e firewall',
          ]),
        );
        expect(
          nomes(porNome['Matemática e Raciocínio Lógico']!),
          containsAll([
            'Progressões aritméticas e geométricas',
            'Lógica proposicional e estruturas lógicas',
          ]),
        );
        expect(
          nomes(porNome['Atualidades de Caldas Novas']!),
          containsAll(['História de Caldas Novas', 'Economia do município']),
        );
        // Artigos, leis e parágrafos não viram numeração nem quebram a linha.
        expect(
          porNome['Direitos e Deveres Individuais e Coletivos']![1].nome,
          'Direito à liberdade (art. 5º, caput)',
        );
        expect(
          nomes(porNome['Cidadania e Segurança Pública']!),
          containsAll([
            'Guardas Municipais na CF (art. 144, § 8º)',
            'Estatuto Geral das Guardas Municipais (Lei 13.022/2014)',
          ]),
        );
        expect(
          porNome['Leis Penais Especiais']![4].nome,
          'Lei Maria da Penha (Lei 11.340/2006) — medidas protetivas e crime de descumprimento',
        );
      },
    );

    test('só cabeçalhos "MAIÚSCULAS:" viram matéria; o resto é tópico', () {
      const texto = '''
Tópico antes de qualquer matéria
CONHECIMENTOS BÁSICOS:
LÍNGUA PORTUGUESA:
- Subtópico sem tópico vira tópico
Língua Portuguesa
Crase. Pontuação; Regência
1.2 Concordância
- Verbal
''';
      expect(modoEstruturado(texto), isTrue);
      final r = separarEdital(texto);
      expect(r.map((m) => m.nome), [
        'Nova matéria',
        'Conhecimentos Básicos', // nunca é ignorado como grupo
        'Língua Portuguesa',
      ]);
      expect(nomes(r[0].topicos), ['Tópico antes de qualquer matéria']);
      expect(r[1].topicos, isEmpty);
      expect(nomes(r[2].topicos), [
        'Subtópico sem tópico vira tópico',
        'Língua Portuguesa',
        'Crase. Pontuação; Regência',
        '1.2 Concordância',
      ]);
      expect(nomes(r[2].topicos.last.filhos), ['Verbal']);
    });

    test(
      'sem cabeçalho "MAIÚSCULAS:" em linha própria, segue a heurística',
      () {
        expect(
          modoEstruturado('LÍNGUA PORTUGUESA: 1 Crase. 2 Pontuação.'),
          isFalse,
        );
        expect(modoEstruturado('Língua Portuguesa:\nCrase'), isFalse);
        expect(
          modoEstruturado('DIREITO CONSTITUCIONAL\n1. Constituição.'),
          isFalse,
        );
      },
    );
  });
}

const _editalEstruturado = '''
LÍNGUA PORTUGUESA:
Compreensão textual
Sílabas
Encontros vocálicos e consonantais
Dígrafos
Tonicidade
Reforma ortográfica de 2009
Acentuação
Prosódia
Estrutura e formação das palavras
Classificação e flexão das palavras
- Substantivo
- Artigo
- Adjetivo
- Numeral
- Pronome
- Verbo
- Advérbio
- Preposição
- Conjunção
- Interjeição
Emprego de tempos e modos verbais
Significação das palavras
Sinonímia, antonímia, polissemia, parônimos, homônimos, denotação e conotação
Termos essenciais, integrantes e acessórios da oração
- Sujeito
- Predicado
- Predicativo do sujeito
- Predicativo do objeto
- Transitividade verbal
- Objeto direto
- Objeto indireto
- Complemento nominal
- Agente da passiva
- Adjunto adnominal
- Adjunto adverbial
- Aposto
Vocativo
Crase
Pronomes — emprego, formas de tratamento e colocação
Pontuação
Coesão e coerência textual

NOÇÕES DE INFORMÁTICA:
Conceitos básicos de informática
Hardware e software
Sistema operacional Windows
Arquivos, pastas e atalhos
Dispositivos de entrada, saída e armazenamento
Editores de texto — Word e LibreOffice Writer
Planilhas — Excel e LibreOffice Calc
Apresentações — PowerPoint e LibreOffice Impress
Internet e navegadores
Correio eletrônico (e-mail)
Noções de redes de computadores
Segurança da informação — vírus, malwares, phishing, antivírus e firewall
Backup e proteção de dados
Boas práticas no uso da internet

MATEMÁTICA E RACIOCÍNIO LÓGICO:
Conjuntos numéricos (naturais, inteiros, racionais, irracionais e reais)
Razão e proporção
Grandezas diretamente e inversamente proporcionais
Regra de três simples e composta
Sistema monetário brasileiro
Porcentagem
Juros simples e compostos
Equações e inequações de primeiro e segundo graus
Sequências e padrões
Progressões aritméticas e geométricas
Análise combinatória e princípios de contagem
Probabilidade
Resolução de situações-problema
Sistemas de medidas
Cálculo de áreas e volumes
Lógica proposicional e estruturas lógicas
Lógica de argumentação — analogias, inferências, deduções e conclusões
Diagramas lógicos

ATUALIDADES DE CALDAS NOVAS:
História de Caldas Novas
Formação histórica, política e administrativa do município
Aspectos geográficos
Aspectos demográficos
Economia do município
Turismo
Organização político-administrativa
Poder Executivo e Poder Legislativo municipal
Símbolos oficiais do município
Atualidades de Caldas Novas

DIREITOS E DEVERES INDIVIDUAIS E COLETIVOS:
Direito à vida (art. 5º, caput)
Direito à liberdade (art. 5º, caput)
Princípio da igualdade (art. 5º, I)
Legalidade e anterioridade penal (art. 5º, II e XXXIX)
Liberdade de manifestação do pensamento (art. 5º, IV)
Intimidade, vida privada, honra e imagem (art. 5º, X)
Inviolabilidade do domicílio (art. 5º, XI)
Sigilo da correspondência e das comunicações (art. 5º, XII)
Liberdade de locomoção (art. 5º, XV)
Direito de reunião e liberdade de associação (art. 5º, XVI a XXI)
Direito de propriedade e função social (art. 5º, XXII e XXIII)
Vedação ao racismo (art. 5º, XLII)
Integridade física e moral do preso (art. 5º, XLIX)
Provas ilícitas (art. 5º, LVI)
Presunção de inocência (art. 5º, LVII)
Direito ao silêncio e não autoincriminação (art. 5º, LXIII)

CIDADANIA E SEGURANÇA PÚBLICA:
Cidadania — conceito, fundamentos e exercício
Direitos políticos na Constituição Federal
Cidadania e meio ambiente
Segurança pública na CF (art. 144)
Órgãos e atribuições da segurança pública
Guardas Municipais na CF (art. 144, § 8º)
Estatuto Geral das Guardas Municipais (Lei 13.022/2014)
Princípios, competências, atribuições e limites das Guardas Municipais
Direitos humanos e atuação das Guardas Municipais

ÉTICA NO SERVIÇO PÚBLICO:
Ética e moral
Princípios e valores éticos
Ética e democracia
Ética e cidadania
Ética na função pública
Conduta ética, responsabilidade e atendimento ao cidadão

LEGISLAÇÃO DE TRÂNSITO:
Código de Trânsito Brasileiro (Lei 9.503/1997)
- Capítulo I — Disposições preliminares
- Capítulo II — Sistema Nacional de Trânsito
- Capítulo III — Normas gerais de circulação e conduta
- Capítulo XIX — Crimes de trânsito

CRIMES CONTRA A ADMINISTRAÇÃO PÚBLICA:
Funcionário público para fins penais (arts. 327 e 328)
Peculato (arts. 312 e 313)
Concussão (art. 316)
Corrupção passiva (art. 317)
Prevaricação (art. 319)
Condescendência criminosa (art. 320)
Corrupção ativa (art. 333)
Tráfico de influência (art. 332)
Resistência (art. 329)
Desobediência (art. 330)
Desacato (art. 331)

LEIS PENAIS ESPECIAIS:
Abuso de Autoridade (Lei 13.869/2019)
Crimes Hediondos (Lei 8.072/1990)
Crimes de Tortura (Lei 9.455/1997)
Estatuto da Criança e do Adolescente (Lei 8.069/1990)
- Disposições preliminares (arts. 1º a 6º)
- Medidas de proteção (arts. 98 a 102)
- Prática de ato infracional (arts. 103 a 128)
- Medidas pertinentes aos pais ou responsável (arts. 129 e 130)
Lei Maria da Penha (Lei 11.340/2006) — medidas protetivas e crime de descumprimento
Estatuto do Desarmamento (Lei 10.826/2003)
''';
