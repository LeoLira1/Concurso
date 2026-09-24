import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/importar_edital.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/comuns.dart';

const _exemplo = '''CONHECIMENTOS BÁSICOS
LÍNGUA PORTUGUESA: 1 Compreensão e interpretação de textos de gêneros variados. 2 Reconhecimento de tipos e gêneros textuais. 3 Domínio da ortografia oficial. 4 Domínio dos mecanismos de coesão textual. 4.1 Emprego de elementos de referenciação, substituição e repetição. 4.2 Emprego de tempos e modos verbais. 5 Emprego do sinal indicativo de crase.
RACIOCÍNIO LÓGICO: 1 Proposições e conectivos. 2 Tabelas-verdade. 3 Equivalências lógicas.
NOÇÕES DE DIREITO CONSTITUCIONAL: 1 Direitos e garantias fundamentais. 1.1 Direitos e deveres individuais e coletivos. 1.2 Direitos sociais. 2 Segurança pública (art. 144).''';

/// Colar o conteúdo programático do edital e separar em matérias e tópicos.
class ImportarScreen extends StatefulWidget {
  const ImportarScreen({
    super.key,
    required this.concursoId,
    this.textoInicial = '',
  });
  final String concursoId;

  /// Usado nas capturas de tela.
  final String textoInicial;

  @override
  State<ImportarScreen> createState() => _ImportarScreenState();
}

class _ImportarScreenState extends State<ImportarScreen> {
  late final _texto = TextEditingController(text: widget.textoInicial);
  late List<MateriaImportada> _itens = separarEdital(widget.textoInicial);

  /// Matérias que já existem: chave -> cor.
  Map<String, int> _existentes = {};
  Timer? _debounce;
  bool _verPrevia = false;
  bool _importando = false;

  @override
  void initState() {
    super.initState();
    context.read<AppDatabase>().todasMaterias().then((l) {
      if (mounted) {
        setState(() => _existentes = {for (final m in l) m.chave: m.cor});
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _texto.dispose();
    super.dispose();
  }

  void _aoDigitar(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _itens = separarEdital(_texto.text));
    });
  }

  void _definirTexto(String t) {
    _texto.text = t;
    setState(() => _itens = separarEdital(t));
  }

  Future<void> _colar() async {
    final d = await Clipboard.getData(Clipboard.kTextPlain);
    final t = d?.text ?? '';
    if (t.trim().isEmpty) {
      if (mounted) avisar(context, 'A área de transferência está vazia');
      return;
    }
    _definirTexto(_texto.text.trim().isEmpty ? t : '${_texto.text}\n$t');
  }

  Future<void> _importar() async {
    final incluidos = _itens.where((m) => m.incluir).toList();
    if (incluidos.isEmpty) return;
    setState(() => _importando = true);
    final (nm, nt) = await context.read<AppDatabase>().importarConteudo(
      widget.concursoId,
      incluidos,
    );
    if (!mounted) return;
    Navigator.pop(context);
    avisar(
      context,
      '$nm ${nm == 1 ? 'matéria' : 'matérias'} e $nt ${nt == 1 ? 'tópico novo' : 'tópicos novos'} importados',
    );
  }

  @override
  Widget build(BuildContext context) {
    final incluidos = _itens.where((m) => m.incluir).toList();
    final nTopicos = incluidos.fold<int>(0, (a, m) => a + m.topicos.length);
    final nSub =
        incluidos.fold<int>(0, (a, m) => a + m.totalTopicos) - nTopicos;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Text('Colar conteúdo programático'),
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          final largo = box.maxWidth >= 1000;
          final editor = _Editor(
            controller: _texto,
            aoDigitar: _aoDigitar,
            aoColar: _colar,
            aoLimpar: () => _definirTexto(''),
            aoExemplo: () => _definirTexto(_exemplo),
          );
          final previa = _Previa(
            itens: _itens,
            estruturado: modoEstruturado(_texto.text),
            existentes: _existentes,
            aoMudar: () => setState(() {}),
          );
          return Column(
            children: [
              if (!largo)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: _Abas(
                    previa: _verPrevia,
                    nMaterias: _itens.length,
                    aoMudar: (v) {
                      FocusScope.of(context).unfocus();
                      setState(() => _verPrevia = v);
                    },
                  ),
                ),
              Expanded(
                child: largo
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(28, 0, 12, 0),
                              child: editor,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 28, 0),
                              child: previa,
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _verPrevia ? previa : editor,
                      ),
              ),
              const Divider(),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _itens.isEmpty
                              ? 'Cole o texto do edital para ver a separação.'
                              : '${incluidos.length} ${incluidos.length == 1 ? 'matéria' : 'matérias'} · ${contagemTopicos(nTopicos, nSub)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!largo && !_verPrevia && _itens.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: OutlinedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() => _verPrevia = true);
                            },
                            child: const Text('Ver prévia'),
                          ),
                        ),
                      FilledButton.icon(
                        onPressed: incluidos.isEmpty || _importando
                            ? null
                            : _importar,
                        icon: const Icon(Icons.download_done_rounded),
                        label: const Text('Importar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Abas extends StatelessWidget {
  const _Abas({
    required this.previa,
    required this.nMaterias,
    required this.aoMudar,
  });
  final bool previa;
  final int nMaterias;
  final ValueChanged<bool> aoMudar;

  @override
  Widget build(BuildContext context) {
    Widget aba(String rotulo, bool valor) => Expanded(
      child: GestureDetector(
        onTap: () => aoMudar(valor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: previa == valor ? Cores.fundo : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: previa == valor
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            rotulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: previa == valor ? Cores.tinta : Cores.tintaSuave,
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          aba('Texto', false),
          aba(nMaterias == 0 ? 'Prévia' : 'Prévia ($nMaterias)', true),
        ],
      ),
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({
    required this.controller,
    required this.aoDigitar,
    required this.aoColar,
    required this.aoLimpar,
    required this.aoExemplo,
  });

  final TextEditingController controller;
  final ValueChanged<String> aoDigitar;
  final VoidCallback aoColar;
  final VoidCallback aoLimpar;
  final VoidCallback aoExemplo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Pilula(
              icone: Icons.content_paste_rounded,
              rotulo: 'Colar',
              aoTocar: aoColar,
            ),
            Pilula(
              icone: Icons.backspace_outlined,
              rotulo: 'Limpar',
              aoTocar: aoLimpar,
            ),
            Pilula(
              icone: Icons.lightbulb_outline_rounded,
              rotulo: 'Exemplo',
              aoTocar: aoExemplo,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: aoDigitar,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(fontSize: 15, height: 1.45),
            decoration: const InputDecoration(
              hintText:
                  'Cole aqui o conteúdo programático copiado do PDF do edital.\n\n'
                  'Ex.:\nLÍNGUA PORTUGUESA: 1 Compreensão de textos. 2 Ortografia. 2.1 Acentuação...\n'
                  'RACIOCÍNIO LÓGICO: 1 Proposições. 2 Tabelas-verdade...',
              hintMaxLines: 8,
              alignLabelWithHint: true,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Dica: matérias em MAIÚSCULAS ou "Nome:" e tópicos numerados (1, 1.1) ou separados por ponto.',
          style: TextStyle(fontSize: 13, color: Cores.tintaSuave),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Previa extends StatelessWidget {
  const _Previa({
    required this.itens,
    required this.estruturado,
    required this.existentes,
    required this.aoMudar,
  });
  final List<MateriaImportada> itens;

  /// Texto com cabeçalhos "MATÉRIA:" em linha própria (ver
  /// [modoEstruturado]): mostra o aviso no topo da prévia.
  final bool estruturado;
  final Map<String, int> existentes;
  final VoidCallback aoMudar;

  @override
  Widget build(BuildContext context) {
    // Mesma regra de cores da importação: existentes mantêm a sua,
    // novas recebem a próxima cor livre da paleta.
    final usadas = {...existentes.values};
    final cores = [
      for (final m in itens)
        existentes[chaveMateria(m.nome)] ??
            () {
              final c = Cores.proximaCor(usadas);
              usadas.add(c);
              return c;
            }(),
    ];
    if (itens.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'A prévia aparece aqui: cada matéria com seus tópicos.\nVocê pode renomear ou desmarcar antes de importar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Cores.tintaSuave,
              height: 1.5,
            ),
          ),
        ),
      );
    }
    final extra = estruturado ? 1 : 0;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: itens.length + extra,
      itemBuilder: (context, i) {
        if (i < extra) return _AvisoEstruturado(itens: itens);
        i -= extra;
        return _CartaoMateria(
          m: itens[i],
          cor: Color(cores[i]),
          existe: existentes.containsKey(chaveMateria(itens[i].nome)),
          aoMudar: aoMudar,
        );
      },
    );
  }
}

/// "19 tópicos + 22 subtópicos" (ou só "14 tópicos").
String contagemTopicos(int topicos, int sub) {
  final t = '$topicos ${topicos == 1 ? 'tópico' : 'tópicos'}';
  if (sub == 0) return t;
  return '$t + $sub ${sub == 1 ? 'subtópico' : 'subtópicos'}';
}

class _AvisoEstruturado extends StatelessWidget {
  const _AvisoEstruturado({required this.itens});
  final List<MateriaImportada> itens;

  @override
  Widget build(BuildContext context) {
    final topicos = itens.fold<int>(0, (a, m) => a + m.topicos.length);
    final sub = itens.fold<int>(0, (a, m) => a + m.totalTopicos) - topicos;
    String n(int v, String um, String varios) => '$v ${v == 1 ? um : varios}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Cores.fundoLateral,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Cores.linha, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_list_bulleted_rounded, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modo estruturado',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Só as linhas em MAIÚSCULAS terminando com ":" viram '
                  'matéria. Cada linha é um tópico, e as que começam com '
                  '"-" são subtópicos.\n'
                  '${n(itens.length, 'matéria', 'matérias')}, '
                  '${n(topicos, 'tópico', 'tópicos')} e '
                  '${n(sub, 'subtópico', 'subtópicos')}.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Cores.tintaSuave,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoMateria extends StatefulWidget {
  const _CartaoMateria({
    required this.m,
    required this.cor,
    required this.existe,
    required this.aoMudar,
  });
  final MateriaImportada m;
  final Color cor;
  final bool existe;
  final VoidCallback aoMudar;

  @override
  State<_CartaoMateria> createState() => _CartaoMateriaState();
}

class _CartaoMateriaState extends State<_CartaoMateria> {
  bool _aberta = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.m;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: m.incluir ? 1 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Cores.linha, width: 1.5),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => setState(() => _aberta = !_aberta),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: Row(
                  children: [
                    Checkbox(
                      value: m.incluir,
                      activeColor: Cores.tinta,
                      onChanged: (v) {
                        m.incluir = v ?? true;
                        widget.aoMudar();
                      },
                    ),
                    Bolinha(widget.cor, tamanho: 12),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.nome,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            [
                              contagemTopicos(
                                m.topicos.length,
                                m.totalTopicos - m.topicos.length,
                              ),
                              if (widget.existe)
                                'já existe · só entram os tópicos novos',
                            ].join('  ·  '),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Cores.tintaSuave,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Renomear',
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Cores.tintaSuave,
                      ),
                      onPressed: () async {
                        final nome = await pedirTexto(
                          context,
                          titulo: 'Nome da matéria',
                          inicial: m.nome,
                        );
                        if (nome != null) {
                          m.nome = nome;
                          widget.aoMudar();
                        }
                      },
                    ),
                    AnimatedRotation(
                      turns: _aberta ? 0.25 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Cores.tintaSuave,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            if (_aberta)
              Padding(
                padding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final t in m.topicos) _LinhaTopico(t, 0)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LinhaTopico extends StatelessWidget {
  const _LinhaTopico(this.t, this.nivel);
  final TopicoImportado t;
  final int nivel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: nivel * 22.0, top: 5, bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  width: nivel == 0 ? 7 : 5,
                  height: nivel == 0 ? 7 : 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nivel == 0 ? Cores.tinta : Cores.tintaFraca,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.nome,
                  style: TextStyle(
                    fontSize: nivel == 0 ? 15 : 14,
                    fontWeight: nivel == 0 ? FontWeight.w600 : FontWeight.w400,
                    color: nivel == 0 ? Cores.tinta : Cores.tintaSuave,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final f in t.filhos) _LinhaTopico(f, nivel + 1),
      ],
    );
  }
}
