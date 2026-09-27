import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../data/pedido_db.dart';
import '../logic/pedido_questoes.dart';
import '../theme.dart';

/// "Pedir mais questões" (etapa 10): escolhe quantidade, tipo e foco, e
/// mostra o texto do pedido (editável) para copiar ou compartilhar com o
/// app do Claude. A resposta volta pelo "Colar questões"/"Colar flashcards".
class PedirQuestoesScreen extends StatefulWidget {
  const PedirQuestoesScreen({
    super.key,
    required this.materia,
    this.topico,
    this.concursoId,
  });

  final Materia materia;

  /// Nulo = pedido para a matéria inteira.
  final Topico? topico;
  final String? concursoId;

  @override
  State<PedirQuestoesScreen> createState() => _PedirQuestoesScreenState();
}

class _PedirQuestoesScreenState extends State<PedirQuestoesScreen> {
  final _texto = TextEditingController();
  ContextoPedido? _contexto;
  int _quantidade = quantidadesPedido.first;
  TipoPedido _tipo = TipoPedido.questoes;
  FocoPedido _foco = FocoPedido.equilibrado;

  @override
  void initState() {
    super.initState();
    context
        .read<AppDatabase>()
        .contextoPedido(
          materia: widget.materia,
          topico: widget.topico,
          concursoId: widget.concursoId,
        )
        .then((c) {
          if (!mounted) return;
          _contexto = c;
          _montar();
        });
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _montar() => setState(() {
    final c = _contexto;
    if (c == null) return;
    _texto.text = montarPedido(
      c,
      quantidade: _quantidade,
      tipo: _tipo,
      foco: _foco,
    );
  });

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: _texto.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Pedido copiado. Cole no chat do Claude e traga a resposta em '
          '"Colar questões".',
        ),
      ),
    );
  }

  Future<void> _compartilhar() async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: _texto.text,
        subject: 'Pedido de questões · ${widget.materia.nome}',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Widget _grupo<T>(
    String titulo,
    List<(T, String)> opcoes,
    T atual,
    ValueChanged<T> aoEscolher,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        titulo,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (v, rotulo) in opcoes)
            ChoiceChip(
              key: ValueKey('pedido-$v'),
              label: Text(rotulo),
              selected: v == atual,
              labelStyle: TextStyle(
                color: v == atual ? Colors.white : Cores.tinta,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) {
                aoEscolher(v);
                _montar();
              },
            ),
        ],
      ),
      const SizedBox(height: 18),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final alvo = widget.topico?.nome ?? '${widget.materia.nome} (inteira)';
    final opcoes = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Monte o pedido, copie e cole no chat do Claude. A resposta vem '
          'no formato do "Colar questões".',
          style: const TextStyle(fontSize: 15, color: Cores.tintaSuave),
        ),
        const SizedBox(height: 18),
        _grupo<int>(
          'Quantidade',
          [for (final n in quantidadesPedido) (n, '$n')],
          _quantidade,
          (v) => _quantidade = v,
        ),
        _grupo<TipoPedido>(
          'O que pedir',
          const [
            (TipoPedido.questoes, 'Questões'),
            (TipoPedido.flashcards, 'Flashcards'),
            (TipoPedido.ambos, 'Os dois'),
          ],
          _tipo,
          (v) => _tipo = v,
        ),
        _grupo<FocoPedido>(
          'Foco',
          const [
            (FocoPedido.equilibrado, 'Equilibrado'),
            (FocoPedido.erros, 'Reforçar meus erros'),
          ],
          _foco,
          (v) => _foco = v,
        ),
        const Text(
          'Mudar uma opção refaz o texto.',
          style: TextStyle(fontSize: 13, color: Cores.tintaSuave),
        ),
      ],
    );
    final botoes = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          key: const ValueKey('compartilhar-pedido'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: _contexto == null ? null : _compartilhar,
          icon: const Icon(Icons.share_rounded),
          label: const Text('Compartilhar'),
        ),
        FilledButton.icon(
          key: const ValueKey('copiar-pedido'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: _contexto == null ? null : _copiar,
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copiar'),
        ),
      ],
    );
    final campo = _contexto == null
        ? const Center(child: CircularProgressIndicator())
        : TextField(
            key: const ValueKey('texto-pedido'),
            controller: _texto,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(fontSize: 14, height: 1.35),
            decoration: InputDecoration(
              labelText: 'Texto do pedido',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text('Pedir mais questões · $alvo'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final largo = box.maxWidth >= 1000;
            if (largo) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(36, 8, 36, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 360,
                      child: SingleChildScrollView(child: opcoes),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: campo),
                          const SizedBox(height: 12),
                          botoes,
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                opcoes,
                const SizedBox(height: 16),
                SizedBox(height: 420, child: campo),
                const SizedBox(height: 12),
                botoes,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Abre o "Pedir mais questões" de um tópico ou da matéria inteira.
Future<void> abrirPedirQuestoes(
  BuildContext context, {
  required Materia materia,
  Topico? topico,
  String? concursoId,
}) => Navigator.push(
  context,
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => PedirQuestoesScreen(
      materia: materia,
      topico: topico,
      concursoId: concursoId,
    ),
  ),
);
