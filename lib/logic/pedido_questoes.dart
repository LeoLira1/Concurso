/// "Pedir mais questões" (etapa 10): monta o texto do pedido para colar no
/// chat do Claude, que devolve questões (e flashcards) novas no formato do
/// "Colar questões" (etapa 8) e do "Colar flashcards" (etapa 9). Não usa
/// API: é só texto.
library;

import 'dart:convert';

import 'mapa_conteudo.dart';

/// O que pedir.
enum TipoPedido {
  questoes,
  flashcards,
  ambos,

  /// Mapa do conteúdo (etapa 12): só no pedido de um tópico.
  mapa,
}

/// "equilibrado" ou "reforçar meus erros" (metade vai para os erros).
enum FocoPedido { equilibrado, erros }

/// Quantidades oferecidas na tela.
const quantidadesPedido = [10, 20, 30];

/// Limites da lista "Já existem" e dos erros.
const limiteExistentesTopico = 60;
const limiteExistentesMateria = 15;
const limiteErros = 10;
const limiteResumo = 120;

/// Uma questão que já está no banco.
class QuestaoExistente {
  const QuestaoExistente({
    required this.enunciado,
    required this.gabarito,
    required this.respostaCerta,
    required this.acertos,
    required this.erros,
    required this.criadoEm,
    this.subtopico,
    this.suspeito = false,
  });

  final String enunciado;
  final String gabarito;

  /// Texto da alternativa certa.
  final String respostaCerta;
  final int acertos;
  final int erros;
  final DateTime criadoEm;

  /// Nulo = a questão está no próprio tópico.
  final String? subtopico;
  final bool suspeito;
}

/// Um flashcard que já está no banco.
class FlashcardExistente {
  const FlashcardExistente({required this.frente, required this.criadoEm});
  final String frente;
  final DateTime criadoEm;
}

/// Um tópico do edital com o que já existe nele (inclui os subtópicos).
class TopicoPedido {
  const TopicoPedido({
    required this.nome,
    this.subtopicos = const [],
    this.questoes = const [],
    this.flashcards = const [],
  });

  final String nome;
  final List<String> subtopicos;
  final List<QuestaoExistente> questoes;
  final List<FlashcardExistente> flashcards;

  int get acertos => questoes.fold(0, (s, q) => s + q.acertos);
  int get respostas => questoes.fold(0, (s, q) => s + q.acertos + q.erros);

  /// % de acerto nas questões do banco (nulo = nenhuma resposta ainda).
  int? get pctAcerto =>
      respostas == 0 ? null : (acertos * 100 / respostas).round();
}

/// Tudo o que o pedido precisa saber.
class ContextoPedido {
  const ContextoPedido({
    required this.materia,
    required this.topicos,
    this.concurso,
    this.banca,
    this.materiaInteira = false,
    this.subtopicoAberto,
    this.mapaAtual,
  });

  /// Nome do concurso em foco (nulo = "Tudo junto").
  final String? concurso;
  final String? banca;
  final String materia;

  /// Pedido da tela do tópico: um só. Da matéria: todos os do edital.
  final List<TopicoPedido> topicos;
  final bool materiaInteira;

  /// A tela aberta era um subtópico: as questões vão para ele.
  final String? subtopicoAberto;

  /// Mapa do conteúdo que o tópico aberto já tem (etapa 12).
  final ({String titulo, List<NoConteudo> nos})? mapaAtual;
}

/// Enunciado numa linha, com no máximo [max] caracteres (com "…").
String resumir(String texto, [int max = limiteResumo]) {
  final t = texto.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.length <= max) return t;
  return '${t.substring(0, max - 1).trimRight()}…';
}

/// Mais recentes primeiro, até [limite].
List<T> _recentes<T>(List<T> l, DateTime Function(T) data, int limite) {
  final o = [...l]..sort((a, b) => data(b).compareTo(data(a)));
  return o.take(limite).toList();
}

/// Até [limiteErros] questões com mais erros que acertos, as piores primeiro.
List<(TopicoPedido, QuestaoExistente)> questoesComMaisErros(
  List<TopicoPedido> topicos,
) {
  final l = [
    for (final t in topicos)
      for (final q in t.questoes)
        if (q.erros > q.acertos) (t, q),
  ];
  l.sort((a, b) {
    final c = (b.$2.erros - b.$2.acertos).compareTo(a.$2.erros - a.$2.acertos);
    if (c != 0) return c;
    final e = b.$2.erros.compareTo(a.$2.erros);
    return e != 0 ? e : b.$2.criadoEm.compareTo(a.$2.criadoEm);
  });
  return l.take(limiteErros).toList();
}

String _plural(int n, String um, String varios) => '$n ${n == 1 ? um : varios}';

String _situacao(TopicoPedido t, {required bool comFlashcards}) => [
  _plural(t.questoes.length, 'questão', 'questões'),
  if (t.pctAcerto case final p?)
    '$p% de acerto (${_plural(t.respostas, 'resposta', 'respostas')})'
  else
    'sem respostas ainda',
  if (comFlashcards) _plural(t.flashcards.length, 'flashcard', 'flashcards'),
].join(' · ');

/// Monta o texto do pedido, na ordem: instruções, contexto, nomes exatos,
/// situação, "Já existem" e "Onde eu mais erro".
String montarPedido(
  ContextoPedido c, {
  required int quantidade,
  TipoPedido tipo = TipoPedido.questoes,
  FocoPedido foco = FocoPedido.equilibrado,
}) {
  if (tipo == TipoPedido.mapa) return montarPedidoMapa(c);
  final comQuestoes = tipo != TipoPedido.flashcards;
  final comFlashcards = tipo != TipoPedido.questoes;
  final n = quantidade;
  final o = StringBuffer();
  void linha([String s = '']) => o.writeln(s);

  // Exemplos com os nomes de verdade: reforçam o "copie assim".
  final t0 = c.topicos.isEmpty ? null : c.topicos.first;
  final sub0 =
      c.subtopicoAberto ??
      ((t0 == null || t0.subtopicos.isEmpty) ? null : t0.subtopicos.first);
  final exQuestao = jsonEncode([
    {
      'materia': c.materia,
      'topico': t0?.nome ?? '',
      'subtopico': ?sub0,
      'dificuldade': 3,
      'enunciado': '...',
      'alternativas': {
        'A': '...',
        'B': '...',
        'C': '...',
        'D': '...',
        'E': '...',
      },
      'gabarito': 'C',
      'explicacao': '...',
    },
  ]);
  final exFlashcard = jsonEncode([
    {
      'materia': c.materia,
      'topico': t0?.nome ?? '',
      'subtopico': ?sub0,
      'frente': '...',
      'verso': '...',
    },
  ]);

  // a) Instruções fixas ------------------------------------------------------
  final oQue = [
    if (comQuestoes) '$n questões inéditas de múltipla escolha',
    if (comFlashcards) '$n flashcards inéditos',
  ].join(' e ');
  linha('Gere $oQue para o meu banco de estudos para concurso.');
  linha();
  linha('REGRAS');
  if (comQuestoes) {
    linha(
      '- Cada questão tem 5 alternativas (A a E), só uma correta, com o '
      'gabarito e uma explicação curta (1 a 3 frases).',
    );
    linha(
      '- Dificuldade de 1 (fácil) a 5 (difícil), bem distribuída entre as '
      'questões.',
    );
  }
  if (comFlashcards) {
    linha(
      '- Cada flashcard tem uma frente curta (pergunta) e um verso com a '
      'resposta direta.',
    );
  }
  if (tipo == TipoPedido.ambos) {
    linha(
      '- Responda só com duas listas JSON, cada uma no seu bloco de código '
      '```json: primeiro as questões, depois os flashcards. Nada de texto '
      'antes, entre ou depois dos blocos.',
    );
  } else {
    linha(
      '- Responda só com a lista JSON, dentro de um bloco de código ```json, '
      'sem texto antes ou depois.',
    );
  }
  if (comQuestoes) {
    linha('- Formato exato de cada questão (mesmas chaves):');
    linha('  $exQuestao');
  }
  if (comFlashcards) {
    linha('- Formato exato de cada flashcard (mesmas chaves):');
    linha('  $exFlashcard');
  }
  linha(
    '- Use os nomes de matéria, tópico e subtópico EXATAMENTE como estão '
    'escritos neste pedido (mesmas letras, acentos e maiúsculas). Não invente '
    'tópicos nem subtópicos. Se o item for do tópico em geral, deixe a chave '
    '"subtopico" de fora.',
  );
  linha(
    '- Não repita o conceito dos itens que já existem (lista "Já existem"), '
    'nem reescritos com outras palavras.',
  );
  if (comQuestoes) {
    linha(
      '- Cada questão precisa ter um enunciado diferente: não repita o '
      'enunciado de outra questão deste lote nem os da lista "Já existem".',
    );
    linha(
      '- Evite enunciados genéricos como "Assinale a alternativa correta": '
      'inclua no enunciado o assunto específico que está sendo cobrado.',
    );
  }
  linha();

  _contextoENomes(o, c, t0);

  // d) Situação -----------------------------------------------------------------
  final todasQuestoes = [for (final t in c.topicos) ...t.questoes];
  final suspeitas = todasQuestoes.where((q) => q.suspeito).length;
  linha(c.materiaInteira ? 'SITUAÇÃO DA MATÉRIA' : 'SITUAÇÃO DO TÓPICO');
  if (c.materiaInteira) {
    final geral = TopicoPedido(
      nome: c.materia,
      questoes: todasQuestoes,
      flashcards: [for (final t in c.topicos) ...t.flashcards],
    );
    linha('Total: ${_situacao(geral, comFlashcards: comFlashcards)}');
    linha(
      'Gabarito suspeito: ${_plural(suspeitas, 'questão marcada', 'questões marcadas')}',
    );
    linha('Por tópico:');
    for (final t in c.topicos) {
      linha('- ${t.nome}: ${_situacao(t, comFlashcards: comFlashcards)}');
    }
    linha(
      'Distribua os itens entre esses tópicos, priorizando os que têm menos '
      'questões e os de menor % de acerto.',
    );
  } else if (t0 != null) {
    linha('Total: ${_situacao(t0, comFlashcards: comFlashcards)}');
    linha(
      'Gabarito suspeito: ${_plural(suspeitas, 'questão marcada', 'questões marcadas')}',
    );
  }
  linha();

  // e) Já existem ---------------------------------------------------------------
  final limite = c.materiaInteira
      ? limiteExistentesMateria
      : limiteExistentesTopico;
  linha('JÁ EXISTEM (não repita estes conceitos)');
  void listar<T>(
    String titulo,
    List<T> itens,
    DateTime Function(T) data,
    String Function(T) texto,
    String? Function(T) sub, {
    String antigas = 'mais antigas',
  }) {
    final l = _recentes(itens, data, limite);
    if (l.isEmpty) return;
    linha(titulo);
    for (final x in l) {
      final s = sub(x);
      linha('- ${s == null ? '' : '[$s] '}${resumir(texto(x))}');
    }
    if (itens.length > l.length) {
      linha('  (e mais ${itens.length - l.length} $antigas)');
    }
  }

  var algum = false;
  for (final t in c.topicos) {
    final prefixo = c.materiaInteira ? '${t.nome} · ' : '';
    if (comQuestoes && t.questoes.isNotEmpty) {
      algum = true;
      listar<QuestaoExistente>(
        '${prefixo}Questões (${t.questoes.length}):',
        t.questoes,
        (q) => q.criadoEm,
        (q) => q.enunciado,
        (q) => q.subtopico,
      );
    }
    if (comFlashcards && t.flashcards.isNotEmpty) {
      algum = true;
      listar<FlashcardExistente>(
        '${prefixo}Flashcards (${t.flashcards.length}):',
        t.flashcards,
        (f) => f.criadoEm,
        (f) => f.frente,
        (_) => null,
        antigas: 'mais antigos',
      );
    }
  }
  if (!algum) linha('Nada ainda: pode começar do básico.');
  linha();

  // f) Onde eu mais erro --------------------------------------------------------
  final erradas = questoesComMaisErros(c.topicos);
  linha('ONDE EU MAIS ERRO');
  if (erradas.isEmpty) {
    linha('Nenhuma questão com mais erros que acertos ainda.');
    if (foco == FocoPedido.erros) {
      linha('Então distribua os itens de forma equilibrada.');
    }
  } else {
    linha(
      'Questões em que errei mais do que acertei. Crie itens novos que '
      'cobrem o mesmo conceito de outro jeito (outro exemplo, outra '
      'pegadinha), sem copiar o enunciado.',
    );
    for (final (i, (t, q)) in erradas.indexed) {
      final onde = [if (c.materiaInteira) t.nome, ?q.subtopico].join(' › ');
      final enunciado = q.enunciado.trim();
      linha('${i + 1}. ${onde.isEmpty ? '' : '[$onde] '}$enunciado');
      linha(
        '   Resposta certa: ${q.gabarito}) ${q.respostaCerta.trim()} '
        '(errei ${q.erros}, acertei ${q.acertos})',
      );
    }
    if (foco == FocoPedido.erros) {
      final metade = (n / 2).ceil();
      final oQueMetade = [
        if (comQuestoes) '$metade das $n questões',
        if (comFlashcards) '$metade dos $n flashcards',
      ].join(' e ');
      linha(
        'Foco em reforçar meus erros: pelo menos $oQueMetade devem ir para '
        'esses conceitos.',
      );
    }
  }
  return o.toString().trimRight();
}

/// b) Contexto e c) nomes exatos (também usados no pedido do mapa).
void _contextoENomes(StringBuffer o, ContextoPedido c, TopicoPedido? t0) {
  void linha([String s = '']) => o.writeln(s);

  // b) Contexto ----------------------------------------------------------------
  linha('CONTEXTO');
  final banca = (c.banca ?? '').trim();
  linha(
    c.concurso == null
        ? 'Concurso: nenhum em foco (vale para todos os meus concursos)'
        : 'Concurso em foco: ${c.concurso}',
  );
  linha(
    banca.isEmpty
        ? 'Banca: não informada'
        : 'Banca: $banca (siga o estilo de cobrança dessa banca)',
  );
  linha();

  // c) Nomes exatos -------------------------------------------------------------
  linha('NOMES EXATOS (copie assim)');
  linha('Matéria: ${c.materia}');
  if (c.materiaInteira) {
    linha('Tópicos do edital:');
    for (final t in c.topicos) {
      linha('- ${t.nome}');
      for (final s in t.subtopicos) {
        linha('  - subtópico: $s');
      }
    }
    if (c.topicos.isEmpty) linha('- (nenhum tópico no edital)');
  } else if (t0 != null) {
    linha('Tópico: ${t0.nome}');
    if (t0.subtopicos.isEmpty) {
      linha('Subtópicos existentes: nenhum (use só o tópico)');
    } else {
      linha('Subtópicos existentes:');
      for (final s in t0.subtopicos) {
        linha('- $s');
      }
    }
    if (c.subtopicoAberto case final s?) {
      linha('Todos os itens devem usar o subtópico: $s');
    }
  }
  linha();
}

/// Pedido do mapa do conteúdo (formato edital-mapa-v1): regras e limites,
/// contexto, nomes exatos, o mapa atual (para ampliar sem repetir) e os
/// conceitos em que eu mais erro.
String montarPedidoMapa(ContextoPedido c) {
  final o = StringBuffer();
  void linha([String s = '']) => o.writeln(s);
  final t0 = c.topicos.isEmpty ? null : c.topicos.first;
  final sub = c.subtopicoAberto;
  final alvo = sub == null ? t0?.nome ?? '' : '$sub (${t0?.nome})';
  final atual = c.mapaAtual;
  final exemplo = jsonEncode({
    'formato': formatoMapa,
    'materia': c.materia,
    'topico': t0?.nome ?? '',
    'subtopico': sub ?? '',
    'titulo': '...',
    'nos': [
      {
        'texto': '...',
        'detalhe': '...',
        'tipo': 'conceito',
        'filhos': [
          {'texto': '...', 'tipo': 'exemplo', 'filhos': []},
        ],
      },
    ],
  });

  linha(
    atual == null
        ? 'Monte o mapa do conteúdo de "$alvo" para o meu estudo para '
              'concurso, no formato $formatoMapa.'
        : 'Amplie o mapa do conteúdo de "$alvo" que já tenho, no formato '
              '$formatoMapa.',
  );
  linha();
  linha('REGRAS');
  linha(
    '- Responda só com o JSON, dentro de um bloco de código ```json, sem '
    'texto antes ou depois.',
  );
  linha('- Formato exato (mesmas chaves):');
  linha('  $exemplo');
  linha(
    '- "tipo" de cada nó: conceito, artigo, exemplo, pegadinha ou dica '
    '(sem tipo = conceito). Use "pegadinha" para o que a banca costuma '
    'trocar e "artigo" para dispositivos de lei.',
  );
  linha(
    '- "texto" com no máximo $limiteTextoNo caracteres, curto como num mapa '
    'mental. A explicação vai em "detalhe" (opcional, 1 ou 2 frases).',
  );
  linha(
    '- No máximo $limiteNiveis níveis abaixo do título e $limiteNos nós no '
    'total. "filhos" pode ficar vazio.',
  );
  linha(
    '- Use os nomes de matéria, tópico e subtópico EXATAMENTE como estão '
    'escritos neste pedido (mesmas letras, acentos e maiúsculas). Não '
    'invente tópicos nem subtópicos.',
  );
  if (atual != null) {
    linha(
      '- O app troca o mapa atual pelo que você mandar. Então devolva o mapa '
      'inteiro: mantenha os nós atuais (mesmos textos, lista "Mapa atual") e '
      'acrescente nós novos, sem repetir o que já está lá, dentro do limite '
      'de $limiteNos nós.',
    );
  }
  linha();

  _contextoENomes(o, c, t0);

  if (atual != null) {
    final total = percorrer(atual.nos).length;
    linha('MAPA ATUAL ("${atual.titulo}", $total nós; não repita, amplie)');
    for (final (n, nivel) in percorrer(atual.nos)) {
      linha(
        '${'  ' * (nivel - 1)}- [${n.tipo.chave}] ${n.texto}'
        '${n.detalhe.isEmpty ? '' : ' (detalhe: ${resumir(n.detalhe)})'}',
      );
    }
    linha();
  }

  final erradas = questoesComMaisErros(c.topicos);
  linha('ONDE EU MAIS ERRO');
  if (erradas.isEmpty) {
    linha('Nenhuma questão com mais erros que acertos ainda.');
  } else {
    linha(
      'Questões em que errei mais do que acertei. Cubra esses conceitos no '
      'mapa, de preferência com nós "pegadinha" ou "dica":',
    );
    for (final (i, (_, q)) in erradas.indexed) {
      linha(
        '${i + 1}. ${resumir(q.enunciado)} Resposta certa: ${q.gabarito}) '
        '${resumir(q.respostaCerta, 80)}',
      );
    }
  }
  return o.toString().trimRight();
}
