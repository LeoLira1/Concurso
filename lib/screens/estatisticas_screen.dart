import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/estatisticas.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/assistir.dart';
import '../widgets/comuns.dart';
import '../widgets/grafico_colunas.dart';

const _verde = Color(0xFF1F9D55);

/// Estatísticas: horas por dia/semana/mês, horas e % de acerto por matéria,
/// sequência de dias e contagem regressiva para a prova.
/// Segue o mesmo escopo da tela inicial (concurso em foco ou tudo junto).
class EstatisticasScreen extends StatefulWidget {
  const EstatisticasScreen({super.key});

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen> {
  Periodo _periodo = Periodo.dias;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final estado = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 72),
      body: Assistir<List<Concurso>>(
        chave: 'concursos',
        stream: db.watchConcursos,
        builder: (context, concursos) {
          if (concursos == null || concursos.isEmpty) {
            return const SizedBox.shrink();
          }
          final foco = concursos.firstWhere(
            (c) => c.foco,
            orElse: () => concursos.first,
          );
          final escopo = estado.verTudo ? null : foco.id;
          return Assistir<List<MateriaInfo>>(
            chave: escopo,
            stream: () => db.watchMaterias(escopo),
            builder: (context, mats) => Assistir<List<Sessao>>(
              chave: 'sessoes',
              stream: db.watchTodasSessoes,
              builder: (context, sessoes) {
                if (mats == null || sessoes == null) {
                  return const SizedBox.shrink();
                }
                final ids = {for (final m in mats) m.materia.id};
                final e = Estatisticas([
                  for (final s in sessoes)
                    if (s.materiaId == null || ids.contains(s.materiaId))
                      SessaoResumo(
                        dia: s.dia,
                        minutos: s.minutos,
                        materiaId: s.materiaId,
                        feitas: s.questoesFeitas,
                        acertos: s.questoesAcertos,
                      ),
                ], hoje: DateTime.now());
                return _Corpo(
                  e: e,
                  materias: {for (final m in mats) m.materia.id: m.materia},
                  concursos: estado.verTudo ? concursos : [foco],
                  titulo: estado.verTudo ? 'Todos os concursos' : foco.nome,
                  periodo: _periodo,
                  aoMudarPeriodo: (p) => setState(() => _periodo = p),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Corpo extends StatelessWidget {
  const _Corpo({
    required this.e,
    required this.materias,
    required this.concursos,
    required this.titulo,
    required this.periodo,
    required this.aoMudarPeriodo,
  });

  final Estatisticas e;
  final Map<String, Materia> materias;
  final List<Concurso> concursos;
  final String titulo;
  final Periodo periodo;
  final ValueChanged<Periodo> aoMudarPeriodo;

  @override
  Widget build(BuildContext context) {
    final estado = context.read<AppState>();
    return LayoutBuilder(
      builder: (context, box) {
        final largo = box.maxWidth >= 1100;
        final pad = largo ? 36.0 : 24.0;
        // Linhas de cards que ocupam toda a largura (sem buracos).
        final linhasTiles = box.maxWidth >= 1100
            ? const [5]
            : box.maxWidth >= 700
            ? const [3, 2]
            : const [2, 2, 1];

        final semana = e.minutosSemana, semanaPassada = e.minutosSemanaPassada;
        final acertoGeral = e.totalFeitas == 0
            ? null
            : e.totalAcertos / e.totalFeitas;
        final tiles = [
          _Tile(
            rotulo: 'Hoje',
            valor: _h(e.minutosHoje),
            detalhe: 'média 30 dias: ${_h(e.mediaDiaria30)}',
          ),
          _Tile(
            rotulo: 'Esta semana',
            valor: _h(semana),
            delta: semanaPassada == 0
                ? null
                : (semana - semanaPassada) / semanaPassada,
            detalhe: 'vs semana passada',
          ),
          _Tile(
            rotulo: 'Este mês',
            valor: _h(e.minutosMes),
            detalhe: 'mês passado: ${_h(e.minutosMesPassado)}',
          ),
          _Tile(
            rotulo: 'Sequência',
            valor:
                '${e.sequenciaAtual} ${e.sequenciaAtual == 1 ? 'dia' : 'dias'}',
            detalhe: 'recorde: ${e.melhorSequencia}',
            icone: Icons.local_fire_department_rounded,
            iconeAtivo: e.sequenciaAtual > 0,
          ),
          _Tile(
            rotulo: 'Acerto geral',
            valor: acertoGeral == null
                ? '—'
                : '${(acertoGeral * 100).round()}%',
            detalhe: '${e.totalFeitas} questões',
          ),
        ];

        final cabecalho = Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 16,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estatísticas',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 16, color: Cores.tintaSuave),
                ),
              ],
            ),
            _Segmentado<bool>(
              valor: estado.verTudo,
              opcoes: const {false: 'Foco', true: 'Tudo junto'},
              aoMudar: (v) => estado.verTudo = v,
            ),
          ],
        );

        final horas = _Cartao(
          titulo: 'Horas estudadas',
          acao: _Segmentado<Periodo>(
            valor: periodo,
            opcoes: const {
              Periodo.dias: '30 dias',
              Periodo.semanas: 'Semanas',
              Periodo.meses: 'Meses',
            },
            aoMudar: aoMudarPeriodo,
            pequeno: true,
          ),
          child: GraficoColunas(
            barras: e.barras(periodo),
            series: [
              for (final m in materias.values)
                SerieGrafico(m.id, m.nome, Color(m.cor)),
            ],
            altura: largo ? 250 : 220,
          ),
        );
        final porMateria = _Cartao(
          titulo: 'Horas por matéria',
          subtitulo:
              'Total: ${_h(e.porMateria().fold(0, (a, x) => a + x.minutos))}',
          child: _HorasPorMateria(e: e, materias: materias),
        );
        final acerto = _Cartao(
          titulo: '% de acerto por matéria',
          child: _AcertoPorMateria(e: e, materias: materias),
        );
        final provas = _Cartao(
          titulo: 'Contagem regressiva',
          child: _Provas(concursos: concursos),
        );

        const gap = SizedBox(width: 20, height: 20);
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, 40),
          children: [
            cabecalho,
            const SizedBox(height: 24),
            for (final (i, n) in linhasTiles.indexed) ...[
              if (i > 0) const SizedBox(height: 16),
              Row(
                children: [
                  for (final (k, t)
                      in tiles
                          .skip(linhasTiles.take(i).fold(0, (a, b) => a + b))
                          .take(n)
                          .indexed) ...[
                    if (k > 0) const SizedBox(width: 16),
                    Expanded(child: t),
                  ],
                ],
              ),
            ],
            gap,
            if (largo) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: horas),
                  gap,
                  Expanded(flex: 2, child: porMateria),
                ],
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: acerto),
                  gap,
                  Expanded(flex: 2, child: provas),
                ],
              ),
            ] else ...[
              provas,
              gap,
              horas,
              gap,
              porMateria,
              gap,
              acerto,
            ],
          ],
        );
      },
    );
  }

  static String _h(int m) => m == 0 ? '0h' : minutosFmt(m);
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.rotulo,
    required this.valor,
    this.detalhe,
    this.delta,
    this.icone,
    this.iconeAtivo = false,
  });

  final String rotulo;
  final String valor;
  final String? detalhe;
  final double? delta;
  final IconData? icone;
  final bool iconeAtivo;

  @override
  Widget build(BuildContext context) {
    final d = delta;
    return Container(
      height: 132,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border.all(color: Cores.linha, width: 1.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rotulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Cores.tintaSuave,
                  ),
                ),
              ),
              if (icone != null)
                Icon(
                  icone,
                  size: 22,
                  color: iconeAtivo ? Cores.acento : Cores.tintaFraca,
                ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              if (d != null) ...[
                Icon(
                  d >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 15,
                  color: d >= 0 ? _verde : Cores.acento,
                ),
                Text(
                  '${d >= 0 ? '+' : '−'}${(d.abs() * 100).round()}% ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: d >= 0 ? _verde : Cores.acento,
                  ),
                ),
              ],
              if (detalhe != null)
                Flexible(
                  child: Text(
                    detalhe!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Cores.tintaSuave,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({
    required this.titulo,
    required this.child,
    this.subtitulo,
    this.acao,
  });
  final String titulo;
  final String? subtitulo;
  final Widget? acao;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
      decoration: BoxDecoration(
        border: Border.all(color: Cores.linha, width: 1.5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(titulo, style: Theme.of(context).textTheme.titleLarge),
                  if (subtitulo != null)
                    Text(
                      subtitulo!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Cores.tintaSuave,
                      ),
                    ),
                ],
              ),
              ?acao,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Segmentado<T> extends StatelessWidget {
  const _Segmentado({
    required this.valor,
    required this.opcoes,
    required this.aoMudar,
    this.pequeno = false,
  });

  final T valor;
  final Map<T, String> opcoes;
  final ValueChanged<T> aoMudar;
  final bool pequeno;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in opcoes.entries)
            GestureDetector(
              onTap: () => aoMudar(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: pequeno ? 36 : 44,
                padding: EdgeInsets.symmetric(horizontal: pequeno ? 12 : 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: e.key == valor ? Cores.fundo : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: e.key == valor
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
                  e.value,
                  style: TextStyle(
                    fontSize: pequeno ? 14 : 15,
                    fontWeight: FontWeight.w700,
                    color: e.key == valor ? Cores.tinta : Cores.tintaSuave,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Linha: bolinha + nome | barra | valor. A barra é de uma cor só (tinta);
/// a identidade da matéria fica na bolinha, como no resto do app.
class _LinhaBarra extends StatelessWidget {
  const _LinhaBarra({
    required this.materia,
    required this.fracao,
    required this.valor,
    this.detalhe,
    this.trilho = false,
    this.naCorDaMateria = false,
  });

  /// Barra na cor da matéria (horas); senão, em tinta (acerto).
  final bool naCorDaMateria;

  final Materia? materia;
  final double fracao;
  final String valor;
  final String? detalhe;

  /// Mostra o trilho (medidor de 0 a 100%).
  final bool trilho;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Bolinha(
            materia == null ? Cores.tintaFraca : Color(materia!.cor),
            tamanho: 10,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 170,
            child: Text(
              materia?.nome ?? '—',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                children: [
                  if (trilho)
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  Container(
                    height: 12,
                    width: box.maxWidth * fracao.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: naCorDaMateria && materia != null
                          ? Color(materia!.cor)
                          : Cores.tinta,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (detalhe != null)
                  Text(
                    detalhe!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Cores.tintaSuave,
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

class _HorasPorMateria extends StatelessWidget {
  const _HorasPorMateria({required this.e, required this.materias});
  final Estatisticas e;
  final Map<String, Materia> materias;

  @override
  Widget build(BuildContext context) {
    final l = e.porMateria().where((x) => x.minutos > 0).toList();
    if (l.isEmpty) return const _Vazio('Nenhuma sessão registrada ainda.');
    final max = l.first.minutos;
    final total = l.fold<int>(0, (a, x) => a + x.minutos);
    return Column(
      children: [
        for (final x in l)
          _LinhaBarra(
            naCorDaMateria: true,
            materia: materias[x.materiaId],
            fracao: x.minutos / max,
            valor: minutosFmt(x.minutos),
            detalhe: '${(x.minutos * 100 / total).round()}%',
          ),
      ],
    );
  }
}

class _AcertoPorMateria extends StatelessWidget {
  const _AcertoPorMateria({required this.e, required this.materias});
  final Estatisticas e;
  final Map<String, Materia> materias;

  @override
  Widget build(BuildContext context) {
    final l = e.porMateria().where((x) => x.feitas > 0).toList()
      ..sort((a, b) => b.acerto!.compareTo(a.acerto!));
    if (l.isEmpty) {
      return const _Vazio(
        'Registre questões feitas e acertos ao finalizar uma sessão.',
      );
    }
    return Column(
      children: [
        for (final x in l)
          _LinhaBarra(
            materia: materias[x.materiaId],
            fracao: x.acerto!,
            valor: '${(x.acerto! * 100).round()}%',
            detalhe: '${x.acertos}/${x.feitas}',
            trilho: true,
          ),
      ],
    );
  }
}

class _Provas extends StatelessWidget {
  const _Provas({required this.concursos});
  final List<Concurso> concursos;

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final comData = [
      for (final c in concursos)
        if (diasAteProva(c.dataProva, hoje) case final d? when d >= 0) (c, d),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    if (comData.isEmpty) {
      return const _Vazio(
        'Cadastre a data da prova em "Meus concursos" para ver a contagem.',
      );
    }
    final (primeiro, dias) = comData.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$dias',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                height: 0.95,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                dias == 1 ? 'dia' : 'dias',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Bolinha(Color(primeiro.cor)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${primeiro.nome} · ${dataCurta(primeiro.dataProva!)}',
                style: const TextStyle(fontSize: 15, color: Cores.tintaSuave),
              ),
            ),
          ],
        ),
        if (comData.length > 1) ...[
          const SizedBox(height: 16),
          const Divider(),
          for (final (c, d) in comData.skip(1))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Bolinha(Color(c.cor)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$d dias',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      texto,
      style: const TextStyle(fontSize: 15, color: Cores.tintaSuave),
    ),
  );
}
