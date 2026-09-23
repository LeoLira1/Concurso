import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../data/sync/cliente_turso.dart';
import '../data/sync/infra.dart';
import '../data/sync/sincronizador.dart';

/// Como juntar os dados na primeira conexão.
enum ModoConexao {
  /// Nuvem vazia: envia tudo deste aparelho.
  enviarTudo,

  /// Os dois têm dados: envia os deste aparelho e recebe os da nuvem.
  juntar,

  /// Apaga os dados deste aparelho e baixa os da nuvem.
  usarNuvem,
}

class InfoConexao {
  const InfoConexao({required this.remoto, required this.local});
  final int remoto;
  final int local;
}

/// Sincronização com o Turso: guarda a configuração, sincroniza sozinha
/// (ao abrir, ao voltar para o app e alguns segundos depois de cada
/// alteração) e expõe o estado para a tela.
class Sincronizacao extends ChangeNotifier with WidgetsBindingObserver {
  Sincronizacao({required this.db});

  final AppDatabase db;

  String url = '';
  String token = '';
  String dispositivo = '';
  int versao = 0;
  DateTime? ultima;
  bool automatica = true;
  bool sincronizando = false;
  String? erro;
  int pendentes = 0;

  bool get configurado => url.isNotEmpty && token.isNotEmpty;

  StreamSubscription<int>? _contagem;
  Timer? _debounce;
  Timer? _periodico;
  bool _iniciado = false;

  Future<void> iniciar() async {
    try {
      final p = await SharedPreferences.getInstance();
      url = p.getString('sync_url') ?? '';
      token = p.getString('sync_token') ?? '';
      versao = p.getInt('sync_versao') ?? 0;
      automatica = p.getBool('sync_auto') ?? true;
      final u = p.getString('sync_ultima');
      ultima = u == null ? null : DateTime.tryParse(u);
      dispositivo = p.getString('sync_dispositivo') ?? '';
      if (dispositivo.isEmpty) {
        dispositivo = novoId();
        await p.setString('sync_dispositivo', dispositivo);
      }
    } catch (_) {}
    _iniciado = true;
    notifyListeners();
    if (configurado) {
      _ligarAutomatico();
      unawaited(sincronizar());
    }
  }

  void _ligarAutomatico() {
    if (_contagem != null) return;
    WidgetsBinding.instance.addObserver(this);
    _contagem = db
        .customSelect(
          'SELECT COUNT(*) AS n FROM sync_pendentes',
          readsFrom: {
            for (final t in db.allTables)
              if (tabelaSinc(t.actualTableName) != null) t,
          },
        )
        .watch()
        .map((r) => r.first.read<int>('n'))
        .listen((n) {
          final mudou = n != pendentes;
          pendentes = n;
          if (mudou) notifyListeners();
          if (n > 0 && automatica) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(seconds: 8), sincronizar);
          }
        });
    _periodico = Timer.periodic(const Duration(minutes: 5), (_) {
      if (automatica) sincronizar();
    });
  }

  void _desligarAutomatico() {
    if (_contagem == null) return;
    WidgetsBinding.instance.removeObserver(this);
    _contagem?.cancel();
    _contagem = null;
    _debounce?.cancel();
    _periodico?.cancel();
  }

  Sincronizador _sincronizador(String u, String t) => Sincronizador(
    db: db,
    remoto: ClienteTurso(url: u, token: t),
    dispositivo: dispositivo,
  );

  /// Testa a URL/token e conta o que há na nuvem e neste aparelho.
  Future<InfoConexao> testar(String u, String t) async {
    final s = _sincronizador(u, t);
    await s.prepararServidor();
    return InfoConexao(
      remoto: await s.contarRemoto(),
      local: await s.contarLocal(),
    );
  }

  Future<void> conectar(String u, String t, ModoConexao modo) async {
    final s = _sincronizador(u, t);
    switch (modo) {
      case ModoConexao.usarNuvem:
        await s.apagarLocal();
      case ModoConexao.enviarTudo || ModoConexao.juntar:
        await s.marcarTudoPendente();
    }
    url = u.trim();
    token = t.trim();
    versao = 0;
    erro = null;
    await _salvar();
    _ligarAutomatico();
    await sincronizar();
  }

  Future<void> desconectar() async {
    _desligarAutomatico();
    url = '';
    token = '';
    versao = 0;
    ultima = null;
    erro = null;
    await _salvar();
    notifyListeners();
  }

  Future<void> definirAutomatica(bool v) async {
    automatica = v;
    await _salvar();
    notifyListeners();
    if (v) unawaited(sincronizar());
  }

  Future<void> sincronizar() async {
    if (!_iniciado || !configurado || sincronizando) return;
    sincronizando = true;
    notifyListeners();
    try {
      final r = await _sincronizador(
        url,
        token,
      ).sincronizar(desdeVersao: versao);
      versao = r.versao;
      ultima = DateTime.now();
      erro = null;
      await _salvar();
    } on ErroTurso catch (e) {
      erro = e.mensagem;
    } catch (e) {
      erro = 'Falha ao sincronizar: $e';
    } finally {
      sincronizando = false;
      notifyListeners();
      // Alterações feitas durante a sincronização vão na próxima rodada.
      if (erro == null && automatica) {
        final n = await _sincronizador(url, token).contarPendentes();
        if (n > 0) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(seconds: 8), sincronizar);
        }
      }
    }
  }

  Future<void> _salvar() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('sync_url', url);
      await p.setString('sync_token', token);
      await p.setInt('sync_versao', versao);
      await p.setBool('sync_auto', automatica);
      if (ultima == null) {
        await p.remove('sync_ultima');
      } else {
        await p.setString('sync_ultima', ultima!.toIso8601String());
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && automatica) sincronizar();
  }

  @override
  void dispose() {
    _desligarAutomatico();
    super.dispose();
  }
}
