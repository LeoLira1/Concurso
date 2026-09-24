import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../state/app_state.dart';
import 'assistir.dart';

/// Entrega o concurso cujo edital define os tópicos mostrados: o concurso
/// em foco, ou nulo no modo "Tudo junto" (mesmo escopo da tela inicial).
class ComEscopo extends StatelessWidget {
  const ComEscopo({super.key, required this.builder});
  final Widget Function(BuildContext context, String? escopo) builder;

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().verTudo) return builder(context, null);
    final db = context.read<AppDatabase>();
    return Assistir<Concurso?>(
      chave: 'foco',
      stream: db.watchFoco,
      builder: (context, foco) => builder(context, foco?.id),
    );
  }
}

/// O mesmo escopo como stream, para quem lê os dados fora do build.
Stream<String?> escopoAtual(BuildContext context) {
  if (context.read<AppState>().verTudo) return Stream.value(null);
  return context.read<AppDatabase>().watchFoco().map((c) => c?.id);
}
