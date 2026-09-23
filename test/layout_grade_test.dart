import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edital/data/database.dart';
import 'package:edital/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A grade do mês precisa caber na tela (sem vazar pela direita) e, no
/// retrato, ter células quadradas.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<List<Rect>> celulas(WidgetTester tester, Size tamanho) async {
    final db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    tester.view.physicalSize = tamanho * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.runAsync(db.carregarExemplo);
    await tester.pumpWidget(EditalApp(database: db));
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pumpAndSettle();
    }
    final achados = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('dia-'),
    );
    final rects = [
      for (final e in achados.evaluate())
        tester.getRect(find.byWidget(e.widget)),
    ];
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
    return rects;
  }

  testWidgets('1280x800 paisagem: nenhuma célula passa da borda direita', (
    tester,
  ) async {
    final r = await celulas(tester, const Size(1280, 800));
    expect(r.length, anyOf(35, 42, 28));
    for (final c in r) {
      expect(c.right, lessThanOrEqualTo(1280 - 24), reason: '$c');
      expect(c.bottom, lessThanOrEqualTo(800), reason: '$c');
      expect(
        c.left,
        greaterThanOrEqualTo(340),
        reason: 'grade começa depois da sidebar: $c',
      );
    }
  });

  testWidgets('800x1280 retrato: células quadradas e dentro da tela', (
    tester,
  ) async {
    final r = await celulas(tester, const Size(800, 1280));
    for (final c in r) {
      expect(c.right, lessThanOrEqualTo(800), reason: '$c');
      expect((c.width - c.height).abs(), lessThan(1), reason: 'quadrada: $c');
    }
  });
}
