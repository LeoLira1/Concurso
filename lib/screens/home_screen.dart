import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import '../widgets/grade_mes.dart';
import '../widgets/sidebar.dart';
import 'concurso_form.dart';

/// Tela principal. Tablet em paisagem: sidebar + grade do mês.
/// Retrato / celular: grade em tela cheia, matérias no menu lateral.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static bool telaLarga(BuildContext context) {
    final s = MediaQuery.sizeOf(context);
    return s.width >= 900 && s.width > s.height;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final estado = context.watch<AppState>();
    return Assistir<List<Concurso>>(
      chave: 'concursos',
      stream: db.watchConcursos,
      builder: (context, concursos) {
        if (concursos == null) return const Scaffold();
        if (concursos.isEmpty) return const _BoasVindas();
        final foco = concursos.firstWhere(
          (c) => c.foco,
          orElse: () => concursos.first,
        );
        final escopo = estado.verTudo ? null : foco.id;
        return Assistir<List<MateriaInfo>>(
          chave: escopo,
          stream: () => db.watchMaterias(escopo),
          builder: (context, materias) {
            final mats = materias ?? const <MateriaInfo>[];
            final filtro = mats.any((m) => m.materia.id == estado.materiaFiltro)
                ? estado.materiaFiltro
                : null;
            final painel = Painel(
              concursos: concursos,
              foco: foco,
              materias: mats,
              filtro: filtro,
            );
            if (telaLarga(context)) {
              return Scaffold(
                body: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 340, child: Sidebar(painel: painel)),
                      Expanded(
                        child: GradeMes(painel: painel, compacta: false),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Scaffold(
              drawer: Drawer(
                width: 340,
                backgroundColor: Cores.fundoLateral,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(28),
                  ),
                ),
                child: SafeArea(child: Sidebar(painel: painel)),
              ),
              body: SafeArea(child: GradeMes(painel: painel, compacta: true)),
            );
          },
        );
      },
    );
  }
}

/// Dados compartilhados entre sidebar e grade.
class Painel {
  const Painel({
    required this.concursos,
    required this.foco,
    required this.materias,
    required this.filtro,
  });

  final List<Concurso> concursos;
  final Concurso foco;
  final List<MateriaInfo> materias;
  final String? filtro;

  MateriaInfo? get materiaFiltrada {
    for (final m in materias) {
      if (m.materia.id == filtro) return m;
    }
    return null;
  }
}

class _BoasVindas extends StatelessWidget {
  const _BoasVindas();

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  const Marca(tamanho: 72),
                  const SizedBox(height: 24),
                  const Text(
                    'Seu planner de estudos para concursos.\nComece cadastrando o primeiro.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Cores.tintaSuave,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => abrirFormConcurso(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Novo concurso'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: db.carregarExemplo,
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: const Text('Carregar exemplo (Guarda Municipal)'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'O exemplo pode ser apagado depois em "Meus concursos".',
                    style: TextStyle(color: Cores.tintaSuave),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
