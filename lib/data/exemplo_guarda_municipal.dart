/// Modelo de exemplo para testar o app. Pode ser apagado a qualquer momento
/// em "Meus concursos". Conteúdo típico de editais de Guarda Municipal.
class ExemploMateria {
  const ExemploMateria(this.nome, this.cor, this.topicos);
  final String nome;
  final int cor;

  /// Uma linha por tópico; "- " indica subtópico.
  final String topicos;
}

class ExemploConcurso {
  const ExemploConcurso(this.nome, this.banca, this.cor, this.materias);
  final String nome;
  final String banca;
  final int cor;
  final List<ExemploMateria> materias;
}

const exemploGuardaMunicipal = ExemploConcurso(
  'Guarda Municipal (exemplo)',
  'Banca exemplo',
  0xFF2F7CF6,
  [
    ExemploMateria('Língua Portuguesa', 0xFF2F7CF6, '''
Compreensão e interpretação de textos
Tipologia e gêneros textuais
Ortografia oficial
Acentuação gráfica
Classes de palavras
- Substantivo e adjetivo
- Verbo: tempos e modos
- Pronomes
Sintaxe da oração e do período
Concordância nominal e verbal
Regência nominal e verbal
Crase
Pontuação
'''),
    ExemploMateria('Matemática e Raciocínio Lógico', 0xFFF5A524, '''
Operações com números reais
Razão e proporção
Regra de três simples e composta
Porcentagem
Juros simples
Equações de 1º e 2º grau
Proposições e conectivos lógicos
Sequências lógicas
'''),
    ExemploMateria('Noções de Direito Constitucional', 0xFFE5407A, '''
Princípios fundamentais
Direitos e garantias fundamentais
- Direitos e deveres individuais e coletivos
- Remédios constitucionais
Organização do Estado
Administração Pública (art. 37 a 41)
Segurança Pública (art. 144)
'''),
    ExemploMateria('Noções de Direito Administrativo', 0xFF8E5CF7, '''
Princípios da Administração Pública
Poderes administrativos
- Poder de polícia
Atos administrativos
Agentes públicos
Responsabilidade civil do Estado
'''),
    ExemploMateria('Legislação Específica', 0xFF34C759, '''
Estatuto Geral das Guardas Municipais (Lei 13.022/2014)
Estatuto do Desarmamento (Lei 10.826/2003)
Código de Trânsito Brasileiro: noções
Estatuto da Criança e do Adolescente: noções
Lei Maria da Penha (Lei 11.340/2006)
'''),
    ExemploMateria('Direitos Humanos', 0xFF14B8C4, '''
Declaração Universal dos Direitos Humanos
Direitos humanos na Constituição Federal
Uso progressivo da força
'''),
    ExemploMateria('Noções de Informática', 0xFF5E7C8C, '''
Sistema operacional Windows
Editor de textos e planilhas
Internet, navegadores e correio eletrônico
Segurança da informação
'''),
  ],
);
