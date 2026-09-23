import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/ciclo.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/comuns.dart';

/// Configuração do ciclo de estudos de um concurso: peso e dificuldade de
/// cada matéria, duração da volta e a fila resultante.
class CicloScreen extends StatelessWidget {
  const CicloScreen({super.key, required this.concursoId});
  final String concursoId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(toolbarHeight: 72),
      body: StreamBuilder<EstadoCiclo>(
        stream: db.watchCiclo(concursoId),
        builder: (context, snap) {
          final e = snap.data;
          final c = e?.concurso;
          if (e == null || c == null) return const SizedBox.shrink();
          final dist = distribuirCiclo(
            [
              for (final m in e.materias.values)
                if (m.noCiclo)
                  EntradaCiclo(
                    materiaId: m.materia.id,
                    peso: m.peso,
                    dificuldade: m.dificuldade,
                  ),
            ],
            minutosTotais: c.cicloMinutos,
            blocoMin: c.cicloBlocoMin,
          );
          final materias = e.materias.values.toList()
            ..sort((a, b) => a.ordem.compareTo(b.ordem));

          final config = _Configuracao(concurso: c, estado: e);
          final lista = [
            for (final m in materias)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LinhaMateria(
                  concursoId: c.id,
                  info: m,
                  resumo: dist[m.materia.id],
                ),
              ),
          ];
          final fila = _Fila(estado: e);

          return LayoutBuilder(
            builder: (context, box) {
              final largo = box.maxWidth >= 1000;
              final cabecalho = Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Bolinha(Color(c.cor), tamanho: 14),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            c.nome.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: Cores.tintaSuave,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ciclo de estudos',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Uma fila que se repete. Cada matéria ganha tempo proporcional a peso + dificuldade. '
                      'Pulou um dia? Nada atrasa: é só seguir de onde parou.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Cores.tintaSuave,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
              if (largo) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(36, 0, 20, 40),
                        children: [
                          cabecalho,
                          config,
                          const SizedBox(height: 24),
                          ...lista,
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 36, 24),
                        child: fila,
                      ),
                    ),
                  ],
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                children: [
                  cabecalho,
                  config,
                  const SizedBox(height: 24),
                  ...lista,
                  const SizedBox(height: 16),
                  SizedBox(height: 520, child: fila),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Configuracao extends StatelessWidget {
  const _Configuracao({required this.concurso, required this.estado});
  final Concurso concurso;
  final EstadoCiclo estado;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final horas = (concurso.cicloMinutos / 60).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Cores.fundoLateral,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        spacing: 32,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uma volta do ciclo',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Cores.tintaSuave,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Pilula(
                    icone: Icons.remove_rounded,
                    tooltip: 'Menos horas',
                    aoTocar: () => db.configurarCiclo(
                      concurso.id,
                      minutosTotais: (horas - 1) * 60,
                    ),
                  ),
                  SizedBox(
                    width: 96,
                    child: Text(
                      '${horas}h',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Pilula(
                    icone: Icons.add_rounded,
                    tooltip: 'Mais horas',
                    aoTocar: () => db.configurarCiclo(
                      concurso.id,
                      minutosTotais: (horas + 1) * 60,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sessões de cerca de',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Cores.tintaSuave,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final b in const [30, 45, 60, 90, 120])
                    ChoiceChip(
                      label: Text(
                        minutosFmt(b),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      selected: concurso.cicloBlocoMin == b,
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      onSelected: (_) =>
                          db.configurarCiclo(concurso.id, blocoMin: b),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinhaMateria extends StatelessWidget {
  const _LinhaMateria({
    required this.concursoId,
    required this.info,
    required this.resumo,
  });
  final String concursoId;
  final MateriaInfo info;
  final ResumoMateriaCiclo? resumo;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final cor = Color(info.materia.cor);
    final ativa = info.noCiclo;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: ativa ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 12, 16),
        decoration: BoxDecoration(
          border: Border.all(color: Cores.linha, width: 1.5),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Bolinha(cor, tamanho: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    info.materia.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (resumo != null && ativa)
                  Text(
                    '${resumo!.sessoes}× ${minutosFmt(resumo!.minutosPorSessao)} = ${minutosFmt(resumo!.minutos)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                Switch(
                  value: ativa,
                  activeTrackColor: Cores.tinta,
                  onChanged: (v) => db.definirPesoDificuldade(
                    concursoId,
                    info.materia.id,
                    noCiclo: v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 28,
              runSpacing: 10,
              children: [
                _Nivel(
                  rotulo: 'Peso',
                  valor: info.peso,
                  cor: cor,
                  aoMudar: ativa
                      ? (v) => db.definirPesoDificuldade(
                          concursoId,
                          info.materia.id,
                          peso: v,
                        )
                      : null,
                ),
                _Nivel(
                  rotulo: 'Dificuldade',
                  valor: info.dificuldade,
                  cor: cor,
                  aoMudar: ativa
                      ? (v) => db.definirPesoDificuldade(
                          concursoId,
                          info.materia.id,
                          dificuldade: v,
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Seletor 1–5 com quadradinhos grandes (fácil de tocar).
class _Nivel extends StatelessWidget {
  const _Nivel({
    required this.rotulo,
    required this.valor,
    required this.cor,
    this.aoMudar,
  });
  final String rotulo;
  final int valor;
  final Color cor;
  final ValueChanged<int>? aoMudar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            rotulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Cores.tintaSuave,
            ),
          ),
        ),
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: aoMudar == null ? null : () => aoMudar!(i),
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i <= valor ? cor : Cores.fundo,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: i <= valor ? cor : Cores.linha,
                  width: 1.5,
                ),
              ),
              child: Text(
                '$i',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: i <= valor ? Colors.white : Cores.tintaFraca,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.estado});
  final EstadoCiclo estado;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final c = estado.concurso!;
    final total = estado.fila.fold<int>(0, (s, it) => s + it.minutos);
    return Container(
      decoration: BoxDecoration(
        color: Cores.fundoLateral,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fila',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      estado.vazio
                          ? 'Nenhuma matéria no ciclo'
                          : '${estado.fila.length} sessões · ${minutosFmt(total)} · volta ${c.cicloVoltas + 1}',
                      style: const TextStyle(
                        color: Cores.tintaSuave,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final ok = await confirmar(
                    context,
                    titulo: 'Reiniciar o ciclo?',
                    mensagem: 'Volta para a primeira sessão e zera a contagem de voltas.',
                    acao: 'Reiniciar',
                  );
                  if (ok) await db.reiniciarCiclo(c.id);
                },
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reiniciar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: estado.fila.length,
              itemBuilder: (context, i) {
                final it = estado.fila[i];
                final m = estado.materiaDe(it);
                final atual = i == estado.posicao;
                final feita = i < estado.posicao;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6, right: 8),
                  child: Material(
                    color: atual ? Cores.tinta : Cores.fundo,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => db.irParaEtapa(c.id, i),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: atual
                                        ? Colors.white70
                                        : Cores.tintaFraca,
                                  ),
                                ),
                              ),
                              Bolinha(
                                m == null ? Cores.tintaFraca : Color(m.cor),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  m?.nome ?? '—',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: atual
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: atual
                                        ? Colors.white
                                        : feita
                                        ? Cores.tintaSuave
                                        : Cores.tinta,
                                    decoration: feita
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: Cores.tintaFraca,
                                  ),
                                ),
                              ),
                              if (it.partes > 1)
                                Text(
                                  '${it.parte}/${it.partes}  ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: atual
                                        ? Colors.white70
                                        : Cores.tintaSuave,
                                  ),
                                ),
                              Text(
                                minutosFmt(it.minutos),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: atual ? Colors.white : Cores.tinta,
                                ),
                              ),
                              if (atual) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
