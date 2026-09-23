import 'package:flutter/material.dart';

/// Paleta neutra inspirada no pocket cal: fundo claro, preto forte e um
/// único acento vermelho. As cores fortes ficam só para as matérias.
abstract final class Cores {
  static const fundo = Color(0xFFFFFFFF);
  static const fundoLateral = Color(0xFFF8F7F4);
  static const tinta = Color(0xFF111111);
  static const tintaSuave = Color(0xFF6B6B6B);
  static const tintaFraca = Color(0xFFB5B5B5);
  static const linha = Color(0xFFE6E6E6);
  static const celulaCheia = Color(0xFFEDEDED);
  static const acento = Color(0xFFE5322D);

  /// Cores por matéria/concurso (ideia de categoria do calendário do iPad).
  static const paleta = <int>[
    0xFF2F7CF6, // azul
    0xFFE5407A, // rosa
    0xFFF5A524, // laranja
    0xFF34C759, // verde
    0xFF8E5CF7, // roxo
    0xFF14B8C4, // ciano
    0xFFEF5B3B, // vermelho-coral
    0xFFB8892F, // mostarda
    0xFF5E7C8C, // ardósia
    0xFFD04CC9, // magenta
    0xFF7DBB2D, // lima
    0xFF3D4DB7, // índigo
  ];

  static int proximaCor(Iterable<int> usadas) {
    for (final c in paleta) {
      if (!usadas.contains(c)) return c;
    }
    return paleta[usadas.length % paleta.length];
  }
}

ThemeData temaEdital() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Cores.tinta,
      brightness: Brightness.light,
      surface: Cores.fundo,
      primary: Cores.tinta,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: Cores.fundo,
  );
  final t = base.textTheme.apply(
    bodyColor: Cores.tinta,
    displayColor: Cores.tinta,
  );
  return base.copyWith(
    textTheme: t.copyWith(
      displayLarge: t.displayLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -2,
      ),
      displayMedium: t.displayMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
      ),
      displaySmall: t.displaySmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
      ),
      headlineLarge: t.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
      headlineMedium: t.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineSmall: t.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: t.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Cores.fundo,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Cores.tinta,
      elevation: 0,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(
      color: Cores.linha,
      space: 1,
      thickness: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Cores.tinta,
        foregroundColor: Colors.white,
        minimumSize: const Size(56, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Cores.tinta,
        minimumSize: const Size(56, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        side: const BorderSide(color: Cores.linha, width: 1.5),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Cores.tinta,
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Cores.fundoLateral,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Cores.tinta, width: 1.5),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Cores.fundo,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Cores.fundo,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Cores.fundo,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Cores.fundo,
      selectedColor: Cores.tinta,
      checkmarkColor: Colors.white,
      labelStyle: const TextStyle(fontFamily: 'Roboto', color: Cores.tinta),
      secondaryLabelStyle: const TextStyle(
        fontFamily: 'Roboto',
        color: Colors.white,
      ),
      side: const BorderSide(color: Cores.linha, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Cores.tintaFraca, width: 2),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Cores.tinta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
