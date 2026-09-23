import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/metodo.dart';
import '../screens/materia_screen.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'comuns.dart';

/// Dados do registro de uma sessão de estudo.
class RegistroSessao {
  RegistroSessao({
    this.materiaId,
    this.topicoId,
    required this.minutos,
    this.metodo,
    this.feitas = 0,
    this.acertos = 0,
    this.paginas = 0,
    this.pontoParada = '',
    this.marcarVisto = false,
    this.avancar = false,
    this.descartar = false,
  });

  String? materiaId;
  String? topicoId;
  int minutos;
  Metodo? metodo;
  int feitas;
  int acertos;
  int paginas;
  String pontoParada;
  bool marcarVisto;
  bool avancar;

  /// O usuário escolheu descartar a sessão (só no cronômetro).
  bool descartar;

  /// Salva no banco (sessão + tópico visto, se marcado).
  Future<void> salvar(AppDatabase db, DateTime dia) async {
    await db.registrarSessao(
      dia: dia,
      minutos: minutos,
      materiaId: materiaId,
      topicoId: topicoId,
      metodo: metodo?.chave,
      questoesFeitas: feitas,
      questoesAcertos: acertos,
      paginas: paginas,
      pontoParada: pontoParada,
    );
    if (marcarVisto && topicoId != null) await db.marcarVisto(topicoId!, true);
    // Uma sessão de revisão do tópico conta como revisão feita.
    if (metodo == Metodo.revisao && topicoId != null) {
      await db.concluirRevisoesDoTopico(topicoId!, soDia(dia));
    }
  }
}

/// Abre o formulário. Retorna `null` se o usuário cancelar/continuar.
Future<RegistroSessao?> abrirRegistro(
  BuildContext context, {
  required String titulo,
  required RegistroSessao inicial,
  required List<MateriaInfo> materias,
  Duration? liquido,
  bool podeAvancar = false,
  bool podeDescartar = false,
}) {
  return showModalBottomSheet<RegistroSessao>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    constraints: const BoxConstraints(maxWidth: 760),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => FormRegistro(
      titulo: titulo,
      inicial: inicial,
      materias: materias,
      liquido: liquido,
      podeAvancar: podeAvancar,
      podeDescartar: podeDescartar,
    ),
  );
}

class FormRegistro extends StatefulWidget {
  const FormRegistro({
    super.key,
    required this.titulo,
    required this.inicial,
    required this.materias,
    this.liquido,
    this.podeAvancar = false,
    this.podeDescartar = false,
  });

  final String titulo;
  final RegistroSessao inicial;
  final List<MateriaInfo> materias;

  /// Tempo do cronômetro (somente leitura). Sem ele, os minutos são editáveis.
  final Duration? liquido;
  final bool podeAvancar;
  final bool podeDescartar;

  @override
  State<FormRegistro> createState() => _FormRegistroState();
}

class _FormRegistroState extends State<FormRegistro> {
  late final RegistroSessao r = widget.inicial;
  late final _parada = TextEditingController(text: widget.inicial.pontoParada);
  List<Topico> _topicos = const [];
  Stream<List<Topico>>? _stream;

  @override
  void initState() {
    super.initState();
    _carregarTopicos();
  }

  void _carregarTopicos() {
    final id = r.materiaId;
    _stream = id == null ? null : context.read<AppDatabase>().watchTopicos(id);
    _stream?.first.then((l) {
      if (mounted) setState(() => _topicos = l);
    });
    if (id == null) _topicos = const [];
  }

  @override
  void dispose() {
    _parada.dispose();
    super.dispose();
  }

  Topico? get _topico {
    for (final t in _topicos) {
      if (t.id == r.topicoId) return t;
    }
    return null;
  }

  void _salvar() {
    r.pontoParada = _parada.text;
    Navigator.pop(context, r);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final topico = _topico;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(widget.titulo, style: t.headlineMedium),
                      ),
                      if (widget.liquido != null)
                        Text(
                          '${minutosFmt(r.minutos)} líquidos',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                  if (widget.liquido == null) ...[
                    const SizedBox(height: 16),
                    _Rotulo('Tempo'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Contador(
                          valor: r.minutos,
                          passo: 5,
                          minimo: 1,
                          sufixo: 'min',
                          aoMudar: (v) => setState(() => r.minutos = v),
                        ),
                        for (final m in const [25, 50, 90, 120])
                          ChoiceChip(
                            label: Text(minutosFmt(m)),
                            selected: r.minutos == m,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => r.minutos = m),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  _Rotulo('Matéria'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in widget.materias)
                        ChoiceChip(
                          avatar: Bolinha(Color(m.materia.cor)),
                          label: Text(m.materia.nome),
                          selected: r.materiaId == m.materia.id,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          onSelected: (_) => setState(() {
                            r.materiaId = m.materia.id;
                            r.topicoId = null;
                            r.marcarVisto = false;
                            _carregarTopicos();
                          }),
                        ),
                    ],
                  ),
                  if (r.materiaId != null) ...[
                    const SizedBox(height: 20),
                    _Rotulo('Tópico'),
                    Material(
                      color: Cores.fundoLateral,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _escolherTopico,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
                          child: Row(
                            children: [
                              Icon(
                                topico?.visto == true
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: Cores.tintaSuave,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  topico?.nome ?? 'Escolher tópico (opcional)',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: topico == null
                                        ? FontWeight.w400
                                        : FontWeight.w700,
                                    color: topico == null
                                        ? Cores.tintaSuave
                                        : Cores.tinta,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.unfold_more_rounded,
                                color: Cores.tintaSuave,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (topico != null && !topico.visto)
                      CheckboxListTile(
                        contentPadding: const EdgeInsets.only(left: 4),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: r.marcarVisto,
                        onChanged: (v) =>
                            setState(() => r.marcarVisto = v ?? false),
                        title: const Text(
                          'Marcar tópico como visto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Agenda revisões em 1, 7 e 30 dias',
                        ),
                      ),
                  ],
                  const SizedBox(height: 20),
                  _Rotulo('Método'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in Metodo.values)
                        ChoiceChip(
                          avatar: Icon(
                            m.icone,
                            size: 18,
                            color: r.metodo == m ? Colors.white : Cores.tinta,
                          ),
                          label: Text(m.rotulo),
                          selected: r.metodo == m,
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          onSelected: (_) => setState(
                            () => r.metodo = r.metodo == m ? null : m,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      _Campo(
                        rotulo: 'Questões feitas',
                        child: Contador(
                          valor: r.feitas,
                          aoMudar: (v) => setState(() {
                            r.feitas = v;
                            if (r.acertos > v) r.acertos = v;
                          }),
                        ),
                      ),
                      _Campo(
                        rotulo: r.feitas == 0
                            ? 'Acertos'
                            : 'Acertos · ${(r.acertos * 100 / r.feitas).round()}%',
                        child: Contador(
                          valor: r.acertos,
                          maximo: r.feitas,
                          aoMudar: (v) => setState(() => r.acertos = v),
                        ),
                      ),
                      _Campo(
                        rotulo: 'Páginas',
                        child: Contador(
                          valor: r.paginas,
                          aoMudar: (v) => setState(() => r.paginas = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _Rotulo('Ponto de parada'),
                  TextField(
                    controller: _parada,
                    maxLength: 140,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 17),
                    decoration: const InputDecoration(
                      hintText:
                          'Ex.: parei na pág. 42 — crase antes de pronomes',
                      prefixIcon: Icon(Icons.bookmark_border_rounded),
                    ),
                  ),
                  if (widget.podeAvancar)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: r.avancar,
                      onChanged: (v) => setState(() => r.avancar = v),
                      title: const Text(
                        'Avançar para a próxima do ciclo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                if (widget.podeDescartar)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Cores.acento),
                    onPressed: () => _confirmarDescarte(),
                    child: const Text('Descartar'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    widget.podeDescartar ? 'Continuar estudando' : 'Cancelar',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _salvar,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Salvar sessão'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarDescarte() async {
    final ok = await confirmar(
      context,
      titulo: 'Descartar a sessão?',
      mensagem: 'O tempo desta sessão não será salvo.',
      acao: 'Descartar',
    );
    if (ok && mounted) Navigator.pop(context, r..descartar = true);
  }

  Future<void> _escolherTopico() async {
    final arvore = ArvoreTopicos(_topicos);
    final linhas = <(Topico, int)>[];
    void percorrer(Topico t, int nivel) {
      linhas.add((t, nivel));
      for (final f in arvore.de(t.id)) {
        percorrer(f, nivel + 1);
      }
    }

    for (final t in arvore.raiz()) {
      percorrer(t, 0);
    }
    final escolhido = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 720),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            ListTile(
              minTileHeight: 52,
              leading: const Icon(Icons.block_rounded),
              title: const Text(
                'Nenhum tópico',
                style: TextStyle(fontSize: 17),
              ),
              onTap: () => Navigator.pop(ctx, ''),
            ),
            if (linhas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Esta matéria ainda não tem tópicos.',
                  style: TextStyle(color: Cores.tintaSuave),
                ),
              ),
            for (final (tp, nivel) in linhas)
              ListTile(
                minTileHeight: 52,
                contentPadding: EdgeInsets.only(
                  left: 16.0 + nivel * 24,
                  right: 16,
                ),
                leading: Icon(
                  tp.visto
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: tp.visto ? Cores.tintaSuave : Cores.tinta,
                ),
                title: Text(
                  tp.nome,
                  style: TextStyle(
                    fontSize: nivel == 0 ? 17 : 16,
                    fontWeight: nivel == 0 ? FontWeight.w700 : FontWeight.w500,
                    color: tp.visto ? Cores.tintaSuave : Cores.tinta,
                  ),
                ),
                trailing: tp.id == r.topicoId
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(ctx, tp.id),
              ),
          ],
        ),
      ),
    );
    if (escolhido == null) return;
    setState(() {
      r.topicoId = escolhido.isEmpty ? null : escolhido;
      r.marcarVisto = false;
    });
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      texto,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Cores.tintaSuave,
      ),
    ),
  );
}

class _Campo extends StatelessWidget {
  const _Campo({required this.rotulo, required this.child});
  final String rotulo;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [_Rotulo(rotulo), child],
  );
}

/// [ − ] valor [ + ] com botões grandes; tocar no número permite digitar.
class Contador extends StatelessWidget {
  const Contador({
    super.key,
    required this.valor,
    required this.aoMudar,
    this.passo = 1,
    this.minimo = 0,
    this.maximo,
    this.sufixo,
  });

  final int valor;
  final ValueChanged<int> aoMudar;
  final int passo;
  final int minimo;
  final int? maximo;
  final String? sufixo;

  int _limitar(int v) {
    var x = v < minimo ? minimo : v;
    if (maximo != null && x > maximo!) x = maximo!;
    return x;
  }

  Future<void> _digitar(BuildContext context) async {
    final ctrl = TextEditingController(text: '$valor');
    final r = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
          onSubmitted: (v) => Navigator.pop(ctx, int.tryParse(v)),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text)),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (r != null) aoMudar(_limitar(r));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Pilula(
          icone: Icons.remove_rounded,
          tooltip: 'Menos',
          aoTocar: () => aoMudar(_limitar(valor - passo)),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _digitar(context),
          child: SizedBox(
            width: sufixo == null ? 72 : 96,
            height: 48,
            child: Center(
              child: Text(
                sufixo == null ? '$valor' : '$valor $sufixo',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
        Pilula(
          icone: Icons.add_rounded,
          tooltip: 'Mais',
          aoTocar: () => aoMudar(_limitar(valor + passo)),
        ),
      ],
    );
  }
}
