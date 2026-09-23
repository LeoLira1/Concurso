import 'package:flutter/widgets.dart';

/// StreamBuilder que só recria o stream quando [chave] muda
/// (evita refazer a consulta a cada rebuild).
class Assistir<T> extends StatefulWidget {
  const Assistir({
    super.key,
    required this.chave,
    required this.stream,
    required this.builder,
  });

  final Object? chave;
  final Stream<T> Function() stream;
  final Widget Function(BuildContext context, T? dados) builder;

  @override
  State<Assistir<T>> createState() => _AssistirState<T>();
}

class _AssistirState<T> extends State<Assistir<T>> {
  late Stream<T> _stream = widget.stream();

  @override
  void didUpdateWidget(Assistir<T> old) {
    super.didUpdateWidget(old);
    if (old.chave != widget.chave) _stream = widget.stream();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
    stream: _stream,
    builder: (context, snap) => widget.builder(context, snap.data),
  );
}
