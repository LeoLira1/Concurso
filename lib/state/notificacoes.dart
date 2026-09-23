import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../logic/lembretes.dart';
import '../util/texto.dart';

/// Notificações locais: lembrete diário de estudo, revisões do dia e alarme
/// do cronômetro com o app em segundo plano.
///
/// Sem o plugin (testes, capturas) tudo vira no-op: [disponivel] fica false.
class Notificacoes extends ChangeNotifier with WidgetsBindingObserver {
  Notificacoes({required this.db});

  final AppDatabase db;

  static const _chaveConfig = 'lembretes_config';

  ConfigLembretes _config = const ConfigLembretes();
  ConfigLembretes get config => _config;

  bool disponivel = false;

  /// null = ainda não sabemos.
  bool? permitido;

  /// Toque numa notificação: a tela inicial consome e navega.
  String? payloadPendente;

  FlutterLocalNotificationsPlugin? _plugin;
  AndroidFlutterLocalNotificationsPlugin? _android;
  StreamSubscription<void>? _mudancas;
  Timer? _debounce;

  static const _canalLembretes = AndroidNotificationDetails(
    'lembretes',
    'Lembretes de estudo',
    channelDescription: 'Lembrete diário de estudo e revisões do dia',
    importance: Importance.high,
    priority: Priority.high,
    icon: 'ic_notificacao',
  );

  static const _canalCronometro = AndroidNotificationDetails(
    'cronometro',
    'Cronômetro',
    channelDescription: 'Meta da sessão e fim do foco/pausa do pomodoro',
    importance: Importance.max,
    priority: Priority.max,
    category: AndroidNotificationCategory.alarm,
    icon: 'ic_notificacao',
  );

  Future<void> iniciar() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = p.getString(_chaveConfig);
      if (s != null) {
        _config = ConfigLembretes.deJson(jsonDecode(s) as Map<String, Object?>);
      }
    } catch (_) {}

    try {
      tzdata.initializeTimeZones();
      final fuso = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(fuso.identifier));

      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notificacao'),
        ),
        onDidReceiveNotificationResponse: (r) => _abrir(r.payload),
      );
      final lancamento = await plugin.getNotificationAppLaunchDetails();
      if (lancamento?.didNotificationLaunchApp ?? false) {
        payloadPendente = lancamento!.notificationResponse?.payload;
      }
      _plugin = plugin;
      _android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      permitido = await _android?.areNotificationsEnabled();
      disponivel = true;
    } catch (e) {
      debugPrint('Notificações indisponíveis: $e');
      disponivel = false;
    }
    notifyListeners();
    if (!disponivel) return;

    WidgetsBinding.instance.addObserver(this);
    // Refaz o plano quando revisões, sessões ou o ciclo mudam.
    _mudancas = db.watchMudancasLembretes().listen(
      (_) => _agendarReplanejamento(),
    );
    await reagendar();
  }

  void _agendarReplanejamento() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), reagendar);
  }

  void _abrir(String? payload) {
    payloadPendente = payload;
    notifyListeners();
  }

  String? consumirPayload() {
    final p = payloadPendente;
    payloadPendente = null;
    return p;
  }

  Future<bool> pedirPermissao() async {
    if (!disponivel) return false;
    try {
      permitido = await _android?.requestNotificationsPermission() ?? permitido;
    } catch (_) {}
    notifyListeners();
    if (permitido == true) await reagendar();
    return permitido ?? false;
  }

  Future<void> salvarConfig(ConfigLembretes c) async {
    _config = c;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_chaveConfig, jsonEncode(c.paraJson()));
    } catch (_) {}
    // Ao ligar um lembrete pela primeira vez, pede a permissão do Android 13+.
    if ((c.estudoAtivo || c.revisoesAtivo) && permitido == false) {
      await pedirPermissao();
    }
    await reagendar();
  }

  /// Recalcula e reagenda os lembretes dos próximos dias.
  Future<void> reagendar() async {
    final plugin = _plugin;
    if (!disponivel || plugin == null) return;
    try {
      final agora = DateTime.now();
      final ate = soDia(agora).add(const Duration(days: diasAgendados));
      final pendentes = await db.revisoesPendentes(ate);
      final plano = planejarLembretes(
        agora: agora,
        config: _config,
        revisoes: [
          for (final r in pendentes)
            RevisaoPendente(r.revisao.dataPrevista, r.topico.nome),
        ],
        estudouHoje: await db.estudouNoDia(agora),
        proximaDoCiclo: await _proximaDoCiclo(),
      );
      for (var d = 0; d < diasAgendados; d++) {
        await plugin.cancel(id: idBaseEstudo + d);
        await plugin.cancel(id: idBaseRevisoes + d);
      }
      for (final l in plano) {
        await plugin.zonedSchedule(
          id: l.id,
          scheduledDate: tz.TZDateTime.from(l.quando, tz.local),
          notificationDetails: const NotificationDetails(
            android: _canalLembretes,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: l.titulo,
          body: l.corpo,
          payload: l.payload,
        );
      }
    } catch (e) {
      debugPrint('Falha ao agendar lembretes: $e');
    }
  }

  Future<String?> _proximaDoCiclo() async {
    final foco = await db.watchFoco().first;
    if (foco == null) return null;
    final ciclo = await db.watchCiclo(foco.id).first;
    final atual = ciclo.atual;
    if (atual == null) return null;
    final m = ciclo.materiaDe(atual);
    return m == null ? null : '${m.nome} · ${minutosFmt(atual.minutos)}';
  }

  /// Alarme do cronômetro para quando o app está em segundo plano.
  Future<void> agendarCronometro(
    DateTime quando,
    String titulo,
    String corpo,
  ) async {
    final plugin = _plugin;
    if (!disponivel || plugin == null) return;
    final data = tz.TZDateTime.from(quando, tz.local);
    for (final modo in [
      AndroidScheduleMode.exactAllowWhileIdle,
      AndroidScheduleMode.inexactAllowWhileIdle,
    ]) {
      try {
        await plugin.zonedSchedule(
          id: idCronometro,
          scheduledDate: data,
          notificationDetails: const NotificationDetails(
            android: _canalCronometro,
          ),
          androidScheduleMode: modo,
          title: titulo,
          body: corpo,
          payload: payloadCronometro,
        );
        return;
      } catch (_) {
        // Sem permissão de alarme exato: tenta o modo aproximado.
      }
    }
  }

  Future<void> cancelarCronometro() async {
    try {
      await _plugin?.cancel(id: idCronometro);
    } catch (_) {}
  }

  Future<void> testar() async {
    final plugin = _plugin;
    if (!disponivel || plugin == null) return;
    await plugin.show(
      id: 999,
      title: 'Notificações ativadas',
      body: 'É assim que os lembretes do Edital vão aparecer.',
      notificationDetails: const NotificationDetails(android: _canalLembretes),
      payload: payloadEstudo,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _android?.areNotificationsEnabled().then((v) {
        if (v != permitido) {
          permitido = v;
          notifyListeners();
        }
      });
      _agendarReplanejamento();
    }
  }

  @override
  void dispose() {
    if (disponivel) WidgetsBinding.instance.removeObserver(this);
    _mudancas?.cancel();
    _debounce?.cancel();
    super.dispose();
  }
}
