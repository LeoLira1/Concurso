import 'dart:async';

import 'package:flutter/foundation.dart';

enum ModoCronometro { livre, pomodoro }

enum Fase { foco, pausa }

/// Cronômetro de estudo. Conta só o tempo líquido (rodando e em foco).
///
/// Não depende de "ticks": guarda o horário da última atualização e soma a
/// diferença. Assim o tempo continua certo com o app em segundo plano ou até
/// se o Android fechar o app (o estado é salvo e restaurado).
class Cronometro extends ChangeNotifier {
  Cronometro({
    this.materiaId,
    this.topicoId,
    this.metaMin,
    this.cicloConcursoId,
    this.modo = ModoCronometro.livre,
    this.focoMin = 25,
    this.pausaMin = 5,
    DateTime? inicio,
    this.liquido = Duration.zero,
    this.faseDecorrido = Duration.zero,
    this.fase = Fase.foco,
    this.metaAvisada = false,
    this.pomodoros = 0,
    DateTime Function()? relogio,
  }) : _relogio = relogio ?? DateTime.now,
       inicio = inicio ?? (relogio ?? DateTime.now)();

  final DateTime Function() _relogio;

  String? materiaId;
  String? topicoId;
  int? metaMin;

  /// Se a sessão veio do ciclo, o concurso cujo ciclo avança ao finalizar.
  final String? cicloConcursoId;
  final DateTime inicio;

  ModoCronometro modo;
  int focoMin;
  int pausaMin;

  Duration liquido;
  Duration faseDecorrido;
  Fase fase;
  bool metaAvisada;
  int pomodoros;

  bool _rodando = false;
  DateTime? _ultimo;
  Timer? _tick;

  bool get rodando => _rodando;

  /// Chamado quando algo merece alarme (meta atingida, fim de foco/pausa).
  void Function(String motivo)? aoAlarmar;

  /// Chamado a cada mudança relevante de estado (para salvar).
  VoidCallback? aoMudarEstado;

  Duration get duracaoFase =>
      Duration(minutes: fase == Fase.foco ? focoMin : pausaMin);

  Duration get restanteFase {
    final r = duracaoFase - faseDecorrido;
    return r.isNegative ? Duration.zero : r;
  }

  Duration? get meta => metaMin == null ? null : Duration(minutes: metaMin!);

  double? get progressoMeta => meta == null
      ? null
      : (liquido.inSeconds / meta!.inSeconds).clamp(0.0, 1.0);

  void iniciar() {
    if (_rodando) return;
    _rodando = true;
    _ultimo = _relogio();
    _ligarTick();
    _mudou();
  }

  void pausar() {
    if (!_rodando) return;
    atualizar();
    _rodando = false;
    _tick?.cancel();
    _mudou();
  }

  void alternar() => _rodando ? pausar() : iniciar();

  void mudarModo(ModoCronometro m) {
    atualizar();
    modo = m;
    fase = Fase.foco;
    faseDecorrido = Duration.zero;
    _mudou();
  }

  void configurarPomodoro({int? foco, int? pausa}) {
    atualizar();
    if (foco != null) focoMin = foco.clamp(5, 180);
    if (pausa != null) pausaMin = pausa.clamp(1, 60);
    _mudou();
  }

  void definirMeta(int? minutos) {
    atualizar();
    metaMin = minutos;
    metaAvisada = minutos != null && liquido >= Duration(minutes: minutos);
    _mudou();
  }

  void definirMateria(String? id) {
    materiaId = id;
    topicoId = null;
    _mudou();
  }

  /// Encerra a fase atual do pomodoro (ex.: pular a pausa).
  void pularFase() {
    atualizar();
    fase = fase == Fase.foco ? Fase.pausa : Fase.foco;
    faseDecorrido = Duration.zero;
    _mudou();
  }

  /// Soma o tempo decorrido desde a última atualização.
  void atualizar() {
    if (!_rodando || _ultimo == null) return;
    final agora = _relogio();
    var delta = agora.difference(_ultimo!);
    _ultimo = agora;
    if (delta.isNegative) return;

    String? alarme;
    if (modo == ModoCronometro.livre) {
      liquido += delta;
      faseDecorrido += delta;
    } else {
      while (delta > Duration.zero) {
        final restante = duracaoFase - faseDecorrido;
        if (delta < restante) {
          faseDecorrido += delta;
          if (fase == Fase.foco) liquido += delta;
          delta = Duration.zero;
        } else {
          if (fase == Fase.foco) {
            liquido += restante;
            pomodoros++;
          }
          delta -= restante;
          fase = fase == Fase.foco ? Fase.pausa : Fase.foco;
          faseDecorrido = Duration.zero;
          alarme = fase == Fase.pausa
              ? 'Hora da pausa'
              : 'Pausa encerrada — de volta ao foco';
        }
      }
    }
    if (meta != null && !metaAvisada && liquido >= meta!) {
      metaAvisada = true;
      alarme = 'Meta da sessão atingida';
    }
    if (alarme != null) {
      aoAlarmar?.call(alarme);
      aoMudarEstado?.call();
    }
  }

  void _ligarTick() {
    _tick?.cancel();
    var n = 0;
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      atualizar();
      notifyListeners();
      if (++n % 120 == 0) aoMudarEstado?.call(); // salva a cada ~30 s
    });
  }

  void _mudou() {
    aoMudarEstado?.call();
    notifyListeners();
  }

  Map<String, Object?> paraJson() {
    atualizar();
    return {
      'materiaId': materiaId,
      'topicoId': topicoId,
      'metaMin': metaMin,
      'cicloConcursoId': cicloConcursoId,
      'modo': modo.name,
      'focoMin': focoMin,
      'pausaMin': pausaMin,
      'inicio': inicio.toIso8601String(),
      'liquido': liquido.inMilliseconds,
      'faseDecorrido': faseDecorrido.inMilliseconds,
      'fase': fase.name,
      'metaAvisada': metaAvisada,
      'pomodoros': pomodoros,
      'rodando': _rodando,
      'ultimo': _ultimo?.toIso8601String(),
    };
  }

  /// Restaura um cronômetro salvo. Se estava rodando, o tempo em que o app
  /// ficou fechado também conta.
  factory Cronometro.deJson(
    Map<String, Object?> j, {
    DateTime Function()? relogio,
  }) {
    final c = Cronometro(
      materiaId: j['materiaId'] as String?,
      topicoId: j['topicoId'] as String?,
      metaMin: j['metaMin'] as int?,
      cicloConcursoId: j['cicloConcursoId'] as String?,
      modo: ModoCronometro.values.byName(j['modo'] as String? ?? 'livre'),
      focoMin: j['focoMin'] as int? ?? 25,
      pausaMin: j['pausaMin'] as int? ?? 5,
      inicio: DateTime.tryParse(j['inicio'] as String? ?? ''),
      liquido: Duration(milliseconds: j['liquido'] as int? ?? 0),
      faseDecorrido: Duration(milliseconds: j['faseDecorrido'] as int? ?? 0),
      fase: Fase.values.byName(j['fase'] as String? ?? 'foco'),
      metaAvisada: j['metaAvisada'] as bool? ?? false,
      pomodoros: j['pomodoros'] as int? ?? 0,
      relogio: relogio,
    );
    if (j['rodando'] == true) {
      c._rodando = true;
      c._ultimo =
          DateTime.tryParse(j['ultimo'] as String? ?? '') ?? c._relogio();
      c.atualizar();
      c._ligarTick();
    }
    return c;
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }
}
