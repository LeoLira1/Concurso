import 'package:flutter/foundation.dart';

/// Estado de navegação da tela principal (não persistido).
class AppState extends ChangeNotifier {
  bool _verTudo = false;
  String? _materiaFiltro;
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);

  /// `true` = grade e sidebar mostram todos os concursos juntos.
  bool get verTudo => _verTudo;
  String? get materiaFiltro => _materiaFiltro;
  DateTime get mes => _mes;

  set verTudo(bool v) {
    if (v == _verTudo) return;
    _verTudo = v;
    _materiaFiltro = null;
    notifyListeners();
  }

  void alternarFiltro(String materiaId) {
    _materiaFiltro = _materiaFiltro == materiaId ? null : materiaId;
    notifyListeners();
  }

  void limparFiltro() {
    if (_materiaFiltro == null) return;
    _materiaFiltro = null;
    notifyListeners();
  }

  void mudarMes(int delta) {
    _mes = DateTime(_mes.year, _mes.month + delta);
    notifyListeners();
  }

  void irParaHoje() {
    _mes = DateTime(DateTime.now().year, DateTime.now().month);
    notifyListeners();
  }
}
