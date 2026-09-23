import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/flashcards.dart';
import '../theme.dart';
import '../widgets/comuns.dart';

/// Abre o estudo dos flashcards que vencem hoje (de um tópico, de uma matéria
/// ou de tudo). Com [todos], pratica todos os cartões mesmo sem vencer.
Future<void> abrirEstudoFlashcards(
  BuildContext context, {
  required String titulo,
  String? topicoId,
  String? materiaId,
  bool todos = false,
}) async {
  final db = context.read<AppDatabase>();
  final fila = await db
      .watchCartoesParaRevisar(
        topicoId: topicoId,
        materiaId: materiaId,
        ate: todos ? DateTime(9999) : null,
      )
      .first;
  if (!context.mounted) return;
  if (fila.isEmpty) {
    avisar(context, 'Nenhum cartão para revisar agora');
    return;
  }
  await Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => EstudoFlashcardsScreen(titulo: titulo, fila: fila),
    ),
  );
}

class EstudoFlashcardsScreen extends StatefulWidget {
  const EstudoFlashcardsScreen({
    super.key,
    required this.titulo,
    required this.fila,
    this.mostrarVersoInicial = false,
  });

  final String titulo;
  final List<CartaoInfo> fila;

  /// Só para capturas de tela.
  final bool mostrarVersoInicial;

  @override
  State<EstudoFlashcardsScreen> createState() => _EstudoFlashcardsScreenState();
}

class _EstudoFlashcardsScreenState extends State<EstudoFlashcardsScreen> {
  late final List<CartaoInfo> _fila = [...widget.fila];
  late final int _total = widget.fila.length;
  late bool _verso = widget.mostrarVersoInicial;
  int _feitos = 0;
  int _acertos = 0;
  int _erros = 0;

  Future<void> _responder(bool acertou) async {
    final atual = _fila.removeAt(0);
    await context.read<AppDatabase>().responderFlashcard(
      atual.cartao,
      acertou: acertou,
    );
    setState(() {
      _verso = false;
      if (acertou) {
        _acertos++;
        _feitos++;
      } else {
        _erros++;
        // Errou: volta para o fim da fila desta sessão (com a caixa zerada).
        _fila.add(
          CartaoInfo(
            atual.cartao.copyWith(caixa: 0),
            atual.topico,
            atual.materia,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leading: IconButton(
          tooltip: 'Fechar',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.titulo, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: _fila.isEmpty ? _fim(context) : _cartao(context, _fila.first),
        ),
      ),
    );
  }

  Widget _fim(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.done_all_rounded, size: 72),
        const SizedBox(height: 16),
        Text('Pronto!', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          '$_total ${_total == 1 ? 'cartão' : 'cartões'} · $_acertos acertos · $_erros erros',
          style: const TextStyle(fontSize: 18, color: Cores.tintaSuave),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Concluir'),
        ),
      ],
    ),
  );

  Widget _cartao(BuildContext context, CartaoInfo c) {
    final cor = Color(c.materia.cor);
    return Column(
      children: [
        // Progresso da sessão.
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _total == 0 ? 0 : _feitos / _total,
                  minHeight: 10,
                  color: Cores.tinta,
                  backgroundColor: Cores.linha,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '$_feitos de $_total',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: GestureDetector(
                onTap: _verso ? null : () => setState(() => _verso = true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(36, 28, 36, 32),
                  decoration: BoxDecoration(
                    color: Cores.fundo,
                    border: Border.all(color: Cores.tinta, width: 2.5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Bolinha(cor, tamanho: 12),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${c.materia.nome} · ${c.topico.nome}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Cores.tintaSuave,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          c.cartao.frente,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (_verso) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Divider(),
                          ),
                          Text(
                            c.cartao.verso,
                            style: const TextStyle(fontSize: 22, height: 1.4),
                          ),
                        ] else ...[
                          const SizedBox(height: 32),
                          const Text(
                            'Toque para ver a resposta',
                            style: TextStyle(
                              fontSize: 15,
                              color: Cores.tintaFraca,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: _verso
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 72),
                          foregroundColor: Cores.acento,
                          side: const BorderSide(color: Cores.acento, width: 2),
                        ),
                        onPressed: () => _responder(false),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Errei'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 72),
                        ),
                        onPressed: () => _responder(true),
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          'Acertei · ${proximoIntervalo(c.cartao.caixa)}',
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 72),
                    ),
                    onPressed: () => setState(() => _verso = true),
                    child: const Text('Mostrar resposta'),
                  ),
                ),
        ),
      ],
    );
  }
}
