import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../screens/concursos_screen.dart';
import '../screens/home_screen.dart';
import '../screens/materia_screen.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'assistir.dart';
import 'comuns.dart';
import 'dia_sheet.dart';
import 'botao_revisoes.dart';
import 'botao_treino.dart';
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

        // Minutos do mês por matéria (cards do modo retrato).
        final minutosPorMateria = <String, int>{};
        for (final s in sessoes ?? const <Sessao>[]) {
          if (s.dia.month != mes.month || s.materiaId == null) continue;
          minutosPorMateria[s.materiaId!] =
              (minutosPorMateria[s.materiaId!] ?? 0) + s.minutos;
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
                    const SizedBox(width: 8),
                    const BotaoTreinoRapido(compacto: true),
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
                child: LayoutBuilder(
                  builder: (context, box) {
                    Widget grade(double? lado) => GestureDetector(
                      onHorizontalDragEnd: (d) {
                        final v = d.primaryVelocity ?? 0;
                        if (v.abs() < 300) return;
                        estado.mudarMes(v < 0 ? 1 : -1);
                      },
                      child: Column(
                        mainAxisSize: lado == null
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                        children: [
                          for (var w = 0; w < semanas; w++)
                            _linha(
                              lado,
                              Row(
                                children: [
                                  for (var d = 0; d < 7; d++)
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          compacta ? 2.5 : 5,
                                        ),
                                        child: () {
                                          final dia = DateTime(
                                            inicio.year,
                                            inicio.month,
                                            inicio.day + w * 7 + d,
                                          );
                                          return _Celula(
                                            key: ValueKey(
                                              'dia-${dia.year}-${dia.month}-${dia.day}',
                                            ),
                                            dia: dia,
                                            doMes: dia.month == mes.month,
                                            sessoes: porDia[dia] ?? const [],
                                            materias: mapaMaterias,
                                            compacta: compacta,
                                            aoTocar: () =>
                                                abrirDia(context, dia, painel),
                                          );
                                        }(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );

                    if (!compacta) return grade(null);
                    // Retrato/celular: células quadradas (sem esticar) e,
                    // logo abaixo, os cards das matérias.
                    final temCards = painel.materias.isNotEmpty;
                    final alturaCards = temCards
                        ? _CardsMaterias.altura + 14
                        : 0.0;
                    final lado = [
                      box.maxWidth / 7,
                      (box.maxHeight - alturaCards) / semanas,
                    ].reduce((a, b) => a < b ? a : b);
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: SizedBox(
                              width: lado * 7,
                              child: grade(lado),
                            ),
                          ),
                          if (temCards) ...[
                            const SizedBox(height: 14),
                            _CardsMaterias(
                              painel: painel,
                              minutos: minutosPorMateria,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _linha(double? lado, Widget filho) => lado == null
    ? Expanded(child: filho)
    : SizedBox(height: lado, child: filho);

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
        if (!compacta) ...[
          const SizedBox(width: 12),
          const BotaoRevisoes(),
          const SizedBox(width: 8),
          const BotaoTreinoRapido(compacto: true),
        ],
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
    super.key,
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
    final itens = <String, (String, Color)>{};
    for (final s in sessoes) {
      final m = materias[s.materiaId];
      final chave = m?.id ?? '-';
      itens[chave] = (
        m?.nome ?? 'Estudo livre',
        m == null ? Cores.tintaSuave : Color(m.cor),
      );
    }
    final lista = itens.values.toList();

    return Opacity(
      opacity: doMes ? 1 : 0.4,
      child: Material(
        color: Cores.fundo,
        shape: RoundedRectangleBorder(borderRadius: raio, side: borda),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fundo suave na cor da matéria; uma faixa por matéria.
              if (estudado)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (_, cor) in lista)
                      Expanded(
                        child: ColoredBox(color: cor.withValues(alpha: 0.2)),
                      ),
                  ],
                ),
              Padding(
                padding: EdgeInsets.all(compacta ? 6 : 10),
                child: LayoutBuilder(
                  builder: (context, c) => _conteudo(c, hoje, lista),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conteudo(BoxConstraints c, bool hoje, List<(String, Color)> lista) {
    final tamNum = compacta ? 15.0 : 20.0;
    final fonte = compacta ? 9.5 : 12.0;
    final altLinha = compacta ? 13.0 : 17.0;
    final larguraBarra = compacta ? 3.0 : 4.0;
    final cabem = ((c.maxHeight - tamNum - 6) / altLinha).floor().clamp(0, 8);
    final mostrar = lista.length > cabem
        ? (cabem - 1).clamp(0, 8)
        : lista.length;
    final estilo = TextStyle(
      fontFamily: 'Roboto',
      fontSize: fonte,
      fontWeight: FontWeight.w700,
      color: Cores.tinta,
    );
    final larguraTexto = c.maxWidth - larguraBarra - 4;

    // Nome inteiro se couber; senão a sigla da matéria.
    String rotulo(String nome) {
      final tp = TextPainter(
        text: TextSpan(text: nome, style: estilo),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.width <= larguraTexto ? nome : siglaMateria(nome);
    }

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
        // Só cabe uma linha e há várias matérias: uma bolinha por matéria.
        if (cabem == 1 && lista.length > 1)
          Wrap(
            spacing: 3,
            runSpacing: 3,
            children: [
              for (final (_, cor) in lista)
                Bolinha(cor, tamanho: compacta ? 8 : 10),
            ],
          )
        else ...[
          for (final (nome, cor) in lista.take(mostrar))
            SizedBox(
              height: altLinha,
              child: Row(
                children: [
                  Container(
                    width: larguraBarra,
                    height: compacta ? 9 : 11,
                    decoration: BoxDecoration(
                      color: cor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      rotulo(nome),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      softWrap: false,
                      style: estilo,
                    ),
                  ),
                ],
              ),
            ),
          if (mostrar < lista.length && cabem > 0)
            Text(
              '+${lista.length - mostrar}',
              style: TextStyle(
                fontSize: fonte,
                fontWeight: FontWeight.w700,
                color: Cores.tintaSuave,
              ),
            ),
        ],
      ],
    );
  }
}

/// Cards das matérias no retrato (referência: biblioteca): fundo suave na
/// cor da matéria, anel de progresso e tópicos vistos/total. Tocar filtra a
/// grade; segurar abre a matéria.
class _CardsMaterias extends StatelessWidget {
  const _CardsMaterias({required this.painel, required this.minutos});
  final Painel painel;
  final Map<String, int> minutos;

  static const altura = 146.0;

  @override
  Widget build(BuildContext context) {
    final estado = context.read<AppState>();
    final total = painel.materias.fold<int>(0, (a, m) => a + m.total);
    final vistos = painel.materias.fold<int>(0, (a, m) => a + m.vistos);
    return SizedBox(
      height: altura,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CardMateria(
            titulo: 'Todas as matérias',
            detalhe: '${painel.materias.length} matérias',
            vistos: vistos,
            total: total,
            cor: Cores.tinta,
            fundo: Cores.fundoLateral,
            selecionado: painel.filtro == null,
            aoTocar: estado.limparFiltro,
          ),
          for (final m in painel.materias)
            _CardMateria(
              titulo: m.materia.nome,
              detalhe: (minutos[m.materia.id] ?? 0) == 0
                  ? 'sem estudo no mês'
                  : '${minutosFmt(minutos[m.materia.id]!)} no mês',
              vistos: m.vistos,
              total: m.total,
              cor: Color(m.materia.cor),
              fundo: Color(m.materia.cor).withValues(alpha: 0.14),
              selecionado: painel.filtro == m.materia.id,
              aoTocar: () => estado.alternarFiltro(m.materia.id),
              aoSegurar: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MateriaScreen(
                    materiaId: m.materia.id,
                    concursoId: painel.escopo,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardMateria extends StatelessWidget {
  const _CardMateria({
    required this.titulo,
    required this.detalhe,
    required this.vistos,
    required this.total,
    required this.cor,
    required this.fundo,
    required this.selecionado,
    required this.aoTocar,
    this.aoSegurar,
  });

  final String titulo;
  final String detalhe;
  final int vistos;
  final int total;
  final Color cor;
  final Color fundo;
  final bool selecionado;
  final VoidCallback aoTocar;
  final VoidCallback? aoSegurar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: fundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selecionado ? Cores.tinta : cor.withValues(alpha: 0.25),
            width: selecionado ? 2.5 : 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: aoTocar,
          onLongPress: aoSegurar,
          child: SizedBox(
            width: 184,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detalhe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Cores.tintaSuave,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      AnelProgresso(
                        valor: total == 0 ? 0 : vistos / total,
                        cor: cor,
                        tamanho: 40,
                        espessura: 5,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$vistos/$total tópicos',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
