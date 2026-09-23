import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../screens/concursos_screen.dart';
import '../screens/home_screen.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'assistir.dart';
import 'comuns.dart';
import 'dia_sheet.dart';
import 'botao_revisoes.dart';
import 'proxima_ciclo.dart';

/// Grade do mês (referência: pocket cal). Dias estudados ficam preenchidos
/// com borda escura; dias sem estudo ficam vazios.
class GradeMes extends StatelessWidget {
  const GradeMes({super.key, required this.painel, required this.compacta});
  final Painel painel;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final estado = context.watch<AppState>();
    final mes = estado.mes;
    final inicio = mes.subtract(Duration(days: mes.weekday % 7));
    final diasNoMes = DateTime(mes.year, mes.month + 1, 0).day;
    final semanas = ((mes.weekday % 7 + diasNoMes) / 7).ceil();
    final fim = inicio.add(Duration(days: semanas * 7 - 1));

    final mapaMaterias = {
      for (final m in painel.materias) m.materia.id: m.materia,
    };

    return Assistir<List<Sessao>>(
      chave: (inicio, fim),
      stream: () => db.watchSessoes(inicio, fim),
      builder: (context, sessoes) {
        final visiveis = (sessoes ?? const <Sessao>[]).where((s) {
          if (s.materiaId == null) return painel.filtro == null;
          if (!mapaMaterias.containsKey(s.materiaId)) return false;
          return painel.filtro == null || s.materiaId == painel.filtro;
        });
        final porDia = <DateTime, List<Sessao>>{};
        for (final s in visiveis) {
          (porDia[soDia(s.dia)] ??= []).add(s);
        }
        final doMes = porDia.entries.where((e) => e.key.month == mes.month);
        final diasEstudados = doMes.length;
        final minutosMes = doMes.fold<int>(
          0,
          (a, e) => a + e.value.fold<int>(0, (b, s) => b + s.minutos),
        );

        // Contagem de sessões do mês por matéria (chips no modo compacto).
        final porMateria = <String, int>{};
        for (final s in sessoes ?? const <Sessao>[]) {
          if (s.dia.month != mes.month || s.materiaId == null) continue;
          if (!mapaMaterias.containsKey(s.materiaId)) continue;
          porMateria[s.materiaId!] = (porMateria[s.materiaId!] ?? 0) + 1;
        }

        final pad = compacta ? 16.0 : 36.0;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            pad,
            compacta ? 8 : 20,
            pad,
            compacta ? 8 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BarraTopo(compacta: compacta, concursoId: painel.foco.id),
              if (compacta) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: ProximaDoCiclo(concursoId: painel.foco.id)),
                    const SizedBox(width: 8),
                    const BotaoRevisoes(compacto: true),
                  ],
                ),
              ],
              SizedBox(height: compacta ? 8 : 12),
              _Titulo(
                mes: mes,
                compacta: compacta,
                diasEstudados: diasEstudados,
                minutos: minutosMes,
                filtrada: painel.materiaFiltrada,
              ),
              SizedBox(height: compacta ? 16 : 24),
              Row(
                children: [
                  for (final d in diasSemanaCurto)
                    Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: compacta ? 11 : 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Cores.tintaSuave,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (d) {
                    final v = d.primaryVelocity ?? 0;
                    if (v.abs() < 300) return;
                    estado.mudarMes(v < 0 ? 1 : -1);
                  },
                  child: Column(
                    children: [
                      for (var w = 0; w < semanas; w++)
                        Expanded(
                          child: Row(
                            children: [
                              for (var d = 0; d < 7; d++)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(compacta ? 2.5 : 5),
                                    child: Builder(
                                      builder: (context) {
                                        final dia = DateTime(
                                          inicio.year,
                                          inicio.month,
                                          inicio.day + w * 7 + d,
                                        );
                                        return _Celula(
                                          dia: dia,
                                          doMes: dia.month == mes.month,
                                          sessoes: porDia[dia] ?? const [],
                                          materias: mapaMaterias,
                                          compacta: compacta,
                                          aoTocar: () =>
                                              abrirDia(context, dia, painel),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (compacta && painel.materias.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Chips(painel: painel, porMateria: porMateria),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BarraTopo extends StatelessWidget {
  const _BarraTopo({required this.compacta, required this.concursoId});
  final bool compacta;
  final String concursoId;

  @override
  Widget build(BuildContext context) {
    final estado = context.read<AppState>();
    return Row(
      children: [
        if (compacta) ...[
          Pilula(
            icone: Icons.menu_rounded,
            tooltip: 'Matérias',
            aoTocar: () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 12),
          const Marca(tamanho: 26),
        ] else
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: ProximaDoCiclo(concursoId: concursoId),
            ),
          ),
        if (!compacta) ...[const SizedBox(width: 12), const BotaoRevisoes()],
        const Spacer(flex: 1),
        Pilula(rotulo: 'Hoje', aoTocar: estado.irParaHoje),
        const SizedBox(width: 8),
        Pilula(
          icone: Icons.chevron_left_rounded,
          tooltip: 'Mês anterior',
          aoTocar: () => estado.mudarMes(-1),
        ),
        const SizedBox(width: 8),
        Pilula(
          icone: Icons.chevron_right_rounded,
          tooltip: 'Próximo mês',
          aoTocar: () => estado.mudarMes(1),
        ),
        if (compacta) ...[
          const SizedBox(width: 8),
          Pilula(
            icone: Icons.folder_open_rounded,
            tooltip: 'Meus concursos',
            aoTocar: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConcursosScreen()),
            ),
          ),
        ],
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo({
    required this.mes,
    required this.compacta,
    required this.diasEstudados,
    required this.minutos,
    required this.filtrada,
  });

  final DateTime mes;
  final bool compacta;
  final int diasEstudados;
  final int minutos;
  final MateriaInfo? filtrada;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final estado = context.read<AppState>();
    final resumo = diasEstudados == 0
        ? 'Nenhum dia estudado'
        : '$diasEstudados ${diasEstudados == 1 ? 'dia estudado' : 'dias estudados'} · ${minutosFmt(minutos)}';
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: mesesPt[mes.month - 1]),
              if (mes.year != DateTime.now().year)
                TextSpan(
                  text: ' ${mes.year}',
                  style: const TextStyle(color: Cores.tintaFraca),
                ),
            ],
          ),
          style: (compacta ? t.displaySmall : t.displayMedium)?.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            Text(
              resumo,
              style: const TextStyle(fontSize: 15, color: Cores.tintaSuave),
            ),
            if (filtrada != null)
              InputChip(
                avatar: Bolinha(Color(filtrada!.materia.cor)),
                label: Text(
                  filtrada!.materia.nome,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onDeleted: estado.limparFiltro,
                deleteIcon: const Icon(Icons.close_rounded, size: 18),
                backgroundColor: Cores.fundo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Cores.tinta, width: 1.5),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Celula extends StatelessWidget {
  const _Celula({
    required this.dia,
    required this.doMes,
    required this.sessoes,
    required this.materias,
    required this.compacta,
    required this.aoTocar,
  });

  final DateTime dia;
  final bool doMes;
  final List<Sessao> sessoes;
  final Map<String, Materia> materias;
  final bool compacta;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final estudado = sessoes.isNotEmpty;
    final minutos = sessoes.fold<int>(0, (a, s) => a + s.minutos);
    final hoje = soDia(DateTime.now()) == dia;
    final raio = BorderRadius.circular(compacta ? 12 : 18);

    // Borda mais escura para dias com mais estudo (como no pocket cal).
    final borda = estudado
        ? BorderSide(
            color: minutos >= 60 ? Cores.tinta : const Color(0xFF7A7A7A),
            width: 2.2,
          )
        : const BorderSide(color: Cores.linha, width: 1.2);

    // Matérias distintas do dia, na ordem em que foram estudadas.
    final nomes = <String, Color>{};
    for (final s in sessoes) {
      final m = materias[s.materiaId];
      nomes[m?.nome ?? 'Estudo livre'] = m == null
          ? Cores.tintaSuave
          : Color(m.cor);
    }

    return Opacity(
      opacity: doMes ? 1 : 0.4,
      child: Material(
        color: estudado ? Cores.celulaCheia : Cores.fundo,
        shape: RoundedRectangleBorder(borderRadius: raio, side: borda),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: EdgeInsets.all(compacta ? 6 : 10),
            child: LayoutBuilder(
              builder: (context, c) {
                final tamNum = compacta ? 15.0 : 20.0;
                final altLinha = compacta ? 13.0 : 17.0;
                final cabem = ((c.maxHeight - tamNum - 6) / altLinha)
                    .floor()
                    .clamp(0, 8);
                final lista = nomes.entries.toList();
                final mostrar = lista.length > cabem
                    ? (cabem - 1).clamp(0, 8)
                    : lista.length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${dia.day}',
                          style: TextStyle(
                            fontSize: tamNum,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            color: hoje
                                ? Cores.acento
                                : doMes
                                ? Cores.tinta
                                : Cores.tintaFraca,
                          ),
                        ),
                        if (hoje) ...[
                          const SizedBox(width: 4),
                          const Bolinha(Cores.acento, tamanho: 6),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Célula estreita (celular): só barrinhas coloridas.
                    if (c.maxWidth < 72)
                      Wrap(
                        spacing: 3,
                        runSpacing: 3,
                        children: [
                          for (final cor in nomes.values)
                            Container(
                              width: 14,
                              height: 5,
                              decoration: BoxDecoration(
                                color: cor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      )
                    else ...[
                      for (final e in lista.take(mostrar))
                        SizedBox(
                          height: altLinha,
                          child: Row(
                            children: [
                              Container(
                                width: compacta ? 3 : 4,
                                height: compacta ? 9 : 11,
                                decoration: BoxDecoration(
                                  color: e.value,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  e.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: compacta ? 9.5 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: Cores.tinta,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (mostrar < lista.length && cabem > 0)
                        Text(
                          '+${lista.length - mostrar}',
                          style: TextStyle(
                            fontSize: compacta ? 9.5 : 12,
                            fontWeight: FontWeight.w700,
                            color: Cores.tintaSuave,
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Filtros em pílulas (modo compacto), como no rodapé do pocket cal.
class _Chips extends StatelessWidget {
  const _Chips({required this.painel, required this.porMateria});
  final Painel painel;
  final Map<String, int> porMateria;

  @override
  Widget build(BuildContext context) {
    final estado = context.read<AppState>();
    final total = porMateria.values.fold<int>(0, (a, b) => a + b);
    Widget chip(
      String rotulo,
      int n,
      bool ativo,
      VoidCallback aoTocar, [
      Color? cor,
    ]) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: ativo ? const Color(0xFFEDEDED) : Cores.fundo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: ativo ? Cores.tinta : Cores.linha,
              width: 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: aoTocar,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cor != null) ...[
                    Bolinha(cor, tamanho: 9),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    rotulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: ativo ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E4E4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$n',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip('Todas', total, painel.filtro == null, estado.limparFiltro),
          for (final m in painel.materias)
            chip(
              m.materia.nome,
              porMateria[m.materia.id] ?? 0,
              painel.filtro == m.materia.id,
              () => estado.alternarFiltro(m.materia.id),
              Color(m.materia.cor),
            ),
        ],
      ),
    );
  }
}
