import 'dart:async';

/// Emite [f](a, b) sempre que qualquer um dos streams emitir, depois que
/// ambos já emitiram pelo menos uma vez (equivalente a combineLatest).
Stream<R> combinarUltimos<A, B, R>(
  Stream<A> sa,
  Stream<B> sb,
  R Function(A a, B b) f,
) {
  late StreamController<R> ctrl;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  A? a;
  B? b;
  var temA = false, temB = false;

  void emitir() {
    if (temA && temB) ctrl.add(f(a as A, b as B));
  }

  ctrl = StreamController<R>(
    onListen: () {
      subA = sa.listen((v) {
        a = v;
        temA = true;
        emitir();
      }, onError: ctrl.addError);
      subB = sb.listen((v) {
        b = v;
        temB = true;
        emitir();
      }, onError: ctrl.addError);
    },
    onPause: () {
      subA?.pause();
      subB?.pause();
    },
    onResume: () {
      subA?.resume();
      subB?.resume();
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );
  return ctrl.stream;
}
