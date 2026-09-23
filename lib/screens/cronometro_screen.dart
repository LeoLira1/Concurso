import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/database.dart';
import '../logic/cronometro.dart';
import '../state/sessao_ativa.dart';
import '../theme.dart';
import '../util/texto.dart';
import '../widgets/comuns.dart';

const _corPausa = Color(0xFFEAF6EE);
const _verdePausa = Color(0xFF1F9D55);

String formatarRelogio(Duration d, {bool horas = true}) {
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  String dd(int v) => v.toString().padLeft(2, '0');
  return horas || h > 0 ? '${dd(h)}:${dd(m)}:${dd(s)}' : '${dd(m)}:${dd(s)}';
}

/// Abre o cronômetro. Se já existe uma sessão em andamento, abre ela.
Future<void> abrirCronometro(
  BuildContext context, {
  String? materiaId,
  int? metaMin,
  String? cicloConcursoId,
}) {
  final sessao = context.read<SessaoAtiva>();
  if (sessao.atual == null) {
    sessao.iniciar(
      materiaId: materiaId,
      metaMin: metaMin,
      cicloConcursoId: cicloConcursoId,
    );
  }
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CronometroScreen(),
      fullscreenDialog: true,
    ),
  );
}

/// Cronômetro em tela cheia. Conta só horas líquidas; modo pomodoro opcional;
/// alarme ao bater a meta da sessão.
class CronometroScreen extends StatefulWidget {
  const CronometroScreen({super.key, this.telaCheia = true});

  /// Desligado nas capturas de tela (não há sistema para esconder barras).
  final bool telaCheia;

  @override
  State<CronometroScreen> createState() => _CronometroScreenState();
}

class _CronometroScreenState extends State<CronometroScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.telaCheia) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      WakelockPlus.enable().catchError((_) {});
    }
  }

  @override
  void dispose() {
    if (widget.telaCheia) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      WakelockPlus.disable().catchError((_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessao = context.watch<SessaoAtiva>();
    final c = sessao.atual;
    if (c == null) return const Scaffold();
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => _Corpo(c: c, sessao: sessao),
    );
  }
}

class _Corpo extends StatelessWidget {
  const _Corpo({required this.c, required this.sessao});
  final Cronometro c;
  final SessaoAtiva sessao;

  bool get _pomodoro => c.modo == ModoCronometro.pomodoro;
  bool get _emPausa => _pomodoro && c.fase == Fase.pausa;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final retrato = MediaQuery.orientationOf(context) == Orientation.portrait;
    return Scaffold(
      backgroundColor: _emPausa ? _corPausa : Cores.fundo,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, retrato ? 40 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Topo(c: c, sessao: sessao),
              _Aviso(sessao: sessao),
              Expanded(
                child: StreamBuilder<Materia?>(
                  stream: c.materiaId == null
                      ? null
                      : db.watchMateria(c.materiaId!),
                  builder: (context, snap) =>
                      _Centro(c: c, materia: snap.data, retrato: retrato),
                ),
              ),
              _Controles(c: c, sessao: sessao),
            ],
          ),
        ),
      ),
    );
  }
}

class _Topo extends StatelessWidget {
  const _Topo({required this.c, required this.sessao});
  final Cronometro c;
  final SessaoAtiva sessao;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Pilula(
          icone: Icons.keyboard_arrow_down_rounded,
          tooltip: 'Minimizar (continua contando)',
          aoTocar: () => Navigator.pop(context),
        ),
        const Spacer(),
        _SeletorModo(
          modo: c.modo,
          aoMudar: (m) {
            c.mudarModo(m);
            sessao.salvarPreferencias(c);
          },
        ),
        const SizedBox(width: 8),
        Pilula(
          icone: Icons.tune_rounded,
          tooltip: 'Ajustar pomodoro',
          aoTocar: () => _ajustarPomodoro(context, c, sessao),
        ),
      ],
    );
  }
}

class _SeletorModo extends StatelessWidget {
  const _SeletorModo({required this.modo, required this.aoMudar});
  final ModoCronometro modo;
  final ValueChanged<ModoCronometro> aoMudar;

  @override
  Widget build(BuildContext context) {
    Widget opcao(String rotulo, ModoCronometro m) {
      final ativo = modo == m;
      return GestureDetector(
        onTap: () => aoMudar(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ativo ? Cores.tinta : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            rotulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ativo ? Colors.white : Cores.tintaSuave,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Cores.linha, width: 1.5),
        borderRadius: BorderRadius.circular(14),
        color: Cores.fundo,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          opcao('Livre', ModoCronometro.livre),
          opcao('Pomodoro', ModoCronometro.pomodoro),
        ],
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.sessao});
  final SessaoAtiva sessao;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: sessao.avisos,
      builder: (context, aviso, _) => AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: aviso == null
            ? const SizedBox(width: double.infinity)
            : Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                decoration: BoxDecoration(
                  color: Cores.tinta,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        aviso,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => sessao.avisos.value = null,
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Centro extends StatelessWidget {
  const _Centro({
    required this.c,
    required this.materia,
    required this.retrato,
  });
  final Cronometro c;
  final Materia? materia;
  final bool retrato;

  @override
  Widget build(BuildContext context) {
    final pomodoro = c.modo == ModoCronometro.pomodoro;
    final emPausa = pomodoro && c.fase == Fase.pausa;
    final cor = materia == null ? Cores.tinta : Color(materia!.cor);

    final rotulo = !c.rodando
        ? (c.liquido == Duration.zero ? 'PRONTO' : 'PAUSADO')
        : emPausa
        ? 'PAUSA'
        : 'FOCO';
    final principal = pomodoro
        ? formatarRelogio(c.restanteFase, horas: false)
        : formatarRelogio(c.liquido);

    return LayoutBuilder(
      builder: (context, box) {
        final tamanho = math.min(
          box.maxWidth / (pomodoro ? 2.9 : 4.1),
          box.maxHeight / 2.4,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Matéria da sessão.
            GestureDetector(
              onTap: () => _escolherMateria(context, c),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Cores.fundo,
                  border: Border.all(color: Cores.linha, width: 1.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Bolinha(
                      materia == null ? Cores.tintaFraca : cor,
                      tamanho: 14,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        materia?.nome ?? 'Escolher matéria',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.expand_more_rounded,
                      color: Cores.tintaSuave,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: retrato ? 40 : 16),
            Text(
              rotulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: emPausa
                    ? _verdePausa
                    : (c.rodando ? Cores.acento : Cores.tintaSuave),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                principal,
                style: TextStyle(
                  fontSize: tamanho,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -tamanho * 0.03,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: c.rodando ? Cores.tinta : Cores.tintaSuave,
                ),
              ),
            ),
            if (pomodoro)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Líquido ${formatarRelogio(c.liquido)}  ·  '
                  '${c.pomodoros} ${c.pomodoros == 1 ? 'pomodoro' : 'pomodoros'}  ·  '
                  '${c.focoMin}/${c.pausaMin}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Cores.tintaSuave,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            SizedBox(height: retrato ? 40 : 20),
            _Meta(c: c, cor: cor),
          ],
        );
      },
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.c, required this.cor});
  final Cronometro c;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final meta = c.meta;
    if (meta == null) {
      return TextButton.icon(
        onPressed: () => _definirMeta(context, c),
        icon: const Icon(Icons.flag_outlined),
        label: const Text('Definir meta da sessão'),
      );
    }
    final falta = meta - c.liquido;
    final atingida = falta <= Duration.zero;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: c.progressoMeta,
              minHeight: 14,
              color: cor,
              backgroundColor: cor.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _definirMeta(context, c),
            child: Text(
              atingida
                  ? 'Meta de ${minutosFmt(c.metaMin!)} atingida ✓'
                  : 'Meta ${minutosFmt(c.metaMin!)}  ·  faltam ${minutosFmt((falta.inSeconds / 60).ceil())}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: atingida ? _verdePausa : Cores.tinta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Controles extends StatelessWidget {
  const _Controles({required this.c, required this.sessao});
  final Cronometro c;
  final SessaoAtiva sessao;

  @override
  Widget build(BuildContext context) {
    final emPausa = c.modo == ModoCronometro.pomodoro && c.fase == Fase.pausa;
    const lateral = 180.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: lateral,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 64)),
            onPressed: () => finalizarSessao(context, c, sessao),
            child: const Text('Finalizar'),
          ),
        ),
        const SizedBox(width: 28),
        Semantics(
          button: true,
          label: c.rodando ? 'Pausar' : 'Iniciar',
          child: Material(
            color: emPausa ? _verdePausa : Cores.tinta,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: c.alternar,
              child: SizedBox.square(
                dimension: 120,
                child: Icon(
                  c.rodando ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
        SizedBox(
          width: lateral,
          child: c.modo == ModoCronometro.pomodoro
              ? OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 64),
                  ),
                  onPressed: c.pularFase,
                  child: Text(emPausa ? 'Pular pausa' : 'Pausar agora'),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Diálogos
// -----------------------------------------------------------------------------

Future<void> _definirMeta(BuildContext context, Cronometro c) async {
  final opcoes = [25, 30, 45, 50, 60, 90, 120];
  final r = await showDialog<int>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Meta da sessão'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in opcoes)
                ChoiceChip(
                  label: Text(
                    minutosFmt(m),
                    style: const TextStyle(fontSize: 16),
                  ),
                  selected: c.metaMin == m,
                  showCheckmark: false,
                  onSelected: (_) => Navigator.pop(ctx, m),
                ),
              ActionChip(
                label: const Text('Sem meta', style: TextStyle(fontSize: 16)),
                onPressed: () => Navigator.pop(ctx, 0),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  if (r == null) return;
  c.definirMeta(r == 0 ? null : r);
}

Future<void> _ajustarPomodoro(
  BuildContext context,
  Cronometro c,
  SessaoAtiva sessao,
) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) {
        Widget linha(
          String rotulo,
          int valor,
          List<int> opcoes,
          ValueChanged<int> f,
        ) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in opcoes)
                  ChoiceChip(
                    label: Text('$m min', style: const TextStyle(fontSize: 16)),
                    selected: valor == m,
                    showCheckmark: false,
                    onSelected: (_) => setLocal(() => f(m)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
        return AlertDialog(
          title: const Text('Pomodoro'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                linha('Foco', c.focoMin, [
                  15,
                  20,
                  25,
                  30,
                  40,
                  50,
                  60,
                  90,
                ], (v) => c.configurarPomodoro(foco: v)),
                linha('Pausa', c.pausaMin, [
                  3,
                  5,
                  10,
                  15,
                  20,
                ], (v) => c.configurarPomodoro(pausa: v)),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                sessao.salvarPreferencias(c);
                Navigator.pop(ctx);
              },
              child: const Text('Pronto'),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> _escolherMateria(BuildContext context, Cronometro c) async {
  final db = context.read<AppDatabase>();
  final foco = await db.watchFoco().first;
  final mats = await db.watchMaterias(foco?.id).first;
  if (!context.mounted) return;
  final id = await showModalBottomSheet<String>(
    context: context,
    constraints: const BoxConstraints(maxWidth: 640),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (ctx) => ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        for (final m in mats)
          ListTile(
            minTileHeight: 56,
            leading: Bolinha(Color(m.materia.cor), tamanho: 14),
            title: Text(
              m.materia.nome,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            trailing: c.materiaId == m.materia.id
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () => Navigator.pop(ctx, m.materia.id),
          ),
      ],
    ),
  );
  if (id == null) return;
  c.definirMateria(id);
}

/// Pergunta como finalizar e salva a sessão (marca o dia na grade).
Future<void> finalizarSessao(
  BuildContext context,
  Cronometro c,
  SessaoAtiva sessao,
) async {
  final estavaRodando = c.rodando;
  c.pausar();
  final db = context.read<AppDatabase>();
  final r = await showDialog<_Final>(
    context: context,
    builder: (_) => _FinalizarDialog(c: c),
  );
  if (r == null) {
    if (estavaRodando) c.iniciar();
    return;
  }
  if (r.salvar) {
    await db.registrarSessao(
      dia: soDia(c.inicio),
      minutos: math.max(1, (c.liquido.inSeconds / 60).round()),
      materiaId: c.materiaId,
      topicoId: c.topicoId,
    );
    if (r.avancar && c.cicloConcursoId != null) {
      final ciclo = await db.watchCiclo(c.cicloConcursoId!).first;
      await db.avancarCiclo(c.cicloConcursoId!, ciclo.fila.length);
    }
  }
  await sessao.encerrar();
  if (context.mounted) {
    Navigator.pop(context);
    if (r.salvar) {
      avisar(
        context,
        'Sessão salva: ${minutosFmt(math.max(1, (c.liquido.inSeconds / 60).round()))}',
      );
    }
  }
}

class _Final {
  const _Final(this.salvar, this.avancar);
  final bool salvar;
  final bool avancar;
}

class _FinalizarDialog extends StatefulWidget {
  const _FinalizarDialog({required this.c});
  final Cronometro c;

  @override
  State<_FinalizarDialog> createState() => _FinalizarDialogState();
}

class _FinalizarDialogState extends State<_FinalizarDialog> {
  late bool _avancar = widget.c.cicloConcursoId != null;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final curta = c.liquido < const Duration(minutes: 1);
    return AlertDialog(
      title: Text(
        'Finalizar sessão',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatarRelogio(c.liquido),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const Text(
              'de estudo líquido',
              style: TextStyle(fontSize: 16, color: Cores.tintaSuave),
            ),
            if (curta)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Menos de 1 minuto — será salvo como 1 min.',
                  style: TextStyle(color: Cores.tintaSuave),
                ),
              ),
            if (c.cicloConcursoId != null) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _avancar,
                onChanged: (v) => setState(() => _avancar = v),
                title: const Text(
                  'Avançar para a próxima do ciclo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Cores.acento),
          onPressed: () => Navigator.pop(context, const _Final(false, false)),
          child: const Text('Descartar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Continuar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _Final(true, _avancar)),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
