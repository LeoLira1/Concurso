import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/cronometro.dart';

/// Guarda o cronômetro em andamento (no máximo um) e as preferências do
/// pomodoro. Sobrevive a fechar o app: o estado vai para SharedPreferences.
class SessaoAtiva extends ChangeNotifier with WidgetsBindingObserver {
  SessaoAtiva() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const _chave = 'cronometro_ativo';

  Cronometro? _atual;
  Cronometro? get atual => _atual;

  int focoPadrao = 25;
  int pausaPadrao = 5;
  ModoCronometro modoPadrao = ModoCronometro.livre;

  /// Último aviso de alarme (a tela do cronômetro mostra).
  final avisos = ValueNotifier<String?>(null);

  AudioPlayer? _player;

  Future<void> restaurar() async {
    try {
      final p = await SharedPreferences.getInstance();
      focoPadrao = p.getInt('pomodoro_foco') ?? 25;
      pausaPadrao = p.getInt('pomodoro_pausa') ?? 5;
      modoPadrao = ModoCronometro.values.byName(
        p.getString('modo_padrao') ?? 'livre',
      );
      final s = p.getString(_chave);
      if (s != null && _atual == null) {
        _ligar(Cronometro.deJson(jsonDecode(s) as Map<String, Object?>));
      }
    } catch (_) {
      // Estado corrompido: ignora.
    }
    notifyListeners();
  }

  Cronometro iniciar({
    String? materiaId,
    String? topicoId,
    int? metaMin,
    String? cicloConcursoId,
    bool comecarRodando = true,
  }) {
    _atual?.dispose();
    final c = Cronometro(
      materiaId: materiaId,
      topicoId: topicoId,
      metaMin: metaMin,
      cicloConcursoId: cicloConcursoId,
      modo: modoPadrao,
      focoMin: focoPadrao,
      pausaMin: pausaPadrao,
    );
    _ligar(c);
    if (comecarRodando) c.iniciar();
    _salvar();
    notifyListeners();
    return c;
  }

  /// Usado nas capturas de tela / testes.
  void definir(Cronometro c) {
    _atual?.dispose();
    _ligar(c);
    notifyListeners();
  }

  void _ligar(Cronometro c) {
    _atual = c
      ..aoMudarEstado = _salvar
      ..aoAlarmar = _alarmar;
  }

  Future<void> encerrar() async {
    _atual?.dispose();
    _atual = null;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_chave);
    } catch (_) {}
  }

  Future<void> salvarPreferencias(Cronometro c) async {
    focoPadrao = c.focoMin;
    pausaPadrao = c.pausaMin;
    modoPadrao = c.modo;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt('pomodoro_foco', focoPadrao);
      await p.setInt('pomodoro_pausa', pausaPadrao);
      await p.setString('modo_padrao', modoPadrao.name);
    } catch (_) {}
  }

  Future<void> _salvar() async {
    final c = _atual;
    if (c == null) return;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_chave, jsonEncode(c.paraJson()));
    } catch (_) {}
  }

  Future<void> _alarmar(String motivo) async {
    avisos.value = motivo;
    try {
      HapticFeedback.vibrate();
      _player ??= AudioPlayer();
      await _player!.play(AssetSource('som/alarme.wav'));
    } catch (_) {
      // Sem áudio (ex.: testes) — o aviso visual continua.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _salvar();
    } else if (state == AppLifecycleState.resumed) {
      _atual?.atualizar();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _atual?.dispose();
    _player?.dispose();
    super.dispose();
  }
}
