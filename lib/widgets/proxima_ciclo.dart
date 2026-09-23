import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../logic/cronometro.dart';
import '../screens/ciclo_screen.dart';
import '../screens/cronometro_screen.dart';
import '../state/sessao_ativa.dart';
import '../theme.dart';
import '../util/texto.dart';
import 'assistir.dart';
import 'comuns.dart';

/// Botão "Próxima do ciclo" da tela inicial. Se há um cronômetro rodando,
/// vira "Sessão em andamento" com o tempo ao vivo.
class ProximaDoCiclo extends StatelessWidget {
  const ProximaDoCiclo({super.key, required this.concursoId});
  final String concursoId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final sessao = context.watch<SessaoAtiva>();
    final ativo = sessao.atual;
    if (ativo != null) return _EmAndamento(c: ativo);

    return Assistir<EstadoCiclo>(
      chave: concursoId,
      stream: () => db.watchCiclo(concursoId),
      builder: (context, e) {
        final atual = e?.atual;
        if (e == null) return const SizedBox(height: 72);
        if (atual == null) {
          return _Cartao(
            escuro: false,
            rotulo: 'CICLO DE ESTUDOS',
            titulo: 'Monte seu ciclo',
            direita: const Icon(Icons.arrow_forward_rounded),
            aoTocar: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CicloScreen(concursoId: concursoId),
              ),
            ),
          );
        }
        final m = e.materiaDe(atual);
        return _Cartao(
          escuro: true,
          rotulo: 'PRÓXIMA DO CICLO',
          cor: m == null ? null : Color(m.cor),
          titulo: m?.nome ?? '—',
          direita: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                minutosFmt(atual.minutos),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Cores.tinta,
                  size: 28,
                ),
              ),
            ],
          ),
          aoTocar: () => abrirProxima(context, concursoId),
        );
      },
    );
  }
}

class _EmAndamento extends StatelessWidget {
  const _EmAndamento({required this.c});
  final Cronometro c;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => StreamBuilder<Materia?>(
        stream: c.materiaId == null ? null : db.watchMateria(c.materiaId!),
        builder: (context, snap) => _Cartao(
          escuro: true,
          rotulo: c.rodando ? 'SESSÃO EM ANDAMENTO' : 'SESSÃO PAUSADA',
          cor: snap.data == null ? null : Color(snap.data!.cor),
          titulo: snap.data?.nome ?? 'Estudo livre',
          direita: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatarRelogio(c.liquido),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Cores.acento,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  c.rodando ? Icons.timer_outlined : Icons.pause_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          aoTocar: () => abrirCronometro(context),
        ),
      ),
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({
    required this.escuro,
    required this.rotulo,
    required this.titulo,
    required this.direita,
    required this.aoTocar,
    this.cor,
  });

  final bool escuro;
  final String rotulo;
  final String titulo;
  final Widget direita;
  final VoidCallback aoTocar;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: escuro ? Cores.tinta : Cores.fundo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: escuro
            ? BorderSide.none
            : const BorderSide(color: Cores.linha, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rotulo,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: escuro ? Colors.white60 : Cores.tintaSuave,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (cor != null) ...[
                          Bolinha(cor!, tamanho: 12),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: escuro ? Colors.white : Cores.tinta,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              direita,
            ],
          ),
        ),
      ),
    );
  }
}

/// Folha com a próxima etapa do ciclo: começar, pular ou ver a fila.
Future<void> abrirProxima(BuildContext context, String concursoId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 640),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => FolhaProxima(concursoId: concursoId),
  );
}

class FolhaProxima extends StatelessWidget {
  const FolhaProxima({super.key, required this.concursoId});
  final String concursoId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Assistir<EstadoCiclo>(
      chave: concursoId,
      stream: () => db.watchCiclo(concursoId),
      builder: (context, e) {
        final atual = e?.atual;
        if (e == null || atual == null) return const SizedBox(height: 200);
        final m = e.materiaDe(atual);
        final cor = m == null ? Cores.tinta : Color(m.cor);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PRÓXIMA DO CICLO  ·  ETAPA ${e.posicao + 1} DE ${e.fila.length}  ·  VOLTA ${(e.concurso?.cicloVoltas ?? 0) + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Cores.tintaSuave,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Bolinha(cor, tamanho: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      m?.nome ?? '—',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Meta de ${minutosFmt(atual.minutos)}'
                '${atual.partes > 1 ? '  ·  sessão ${atual.parte} de ${atual.partes} desta matéria na volta' : ''}',
                style: const TextStyle(fontSize: 16, color: Cores.tintaSuave),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 64)),
                onPressed: () {
                  Navigator.pop(context);
                  abrirCronometro(
                    context,
                    materiaId: atual.materiaId,
                    metaMin: atual.minutos,
                    cicloConcursoId: concursoId,
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: const Text(
                  'Começar agora',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          db.avancarCiclo(concursoId, e.fila.length),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('Pular'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CicloScreen(concursoId: concursoId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.autorenew_rounded),
                      label: const Text('Ver ciclo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Depois',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Cores.tintaSuave,
                ),
              ),
              const SizedBox(height: 8),
              for (final it in e.proximas(3))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Bolinha(
                        e.materiaDe(it) == null
                            ? Cores.tintaFraca
                            : Color(e.materiaDe(it)!.cor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          e.materiaDe(it)?.nome ?? '—',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        minutosFmt(it.minutos),
                        style: const TextStyle(color: Cores.tintaSuave),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  abrirCronometro(context);
                },
                child: const Text('Estudar outra coisa (sem ciclo)'),
              ),
            ],
          ),
        );
      },
    );
  }
}
