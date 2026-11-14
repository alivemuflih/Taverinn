import 'package:flutter/material.dart';

abstract final class TaverinnColors {
  static const ink = Color(0xFF2B241F);
  static const walnut = Color(0xFF49372C);
  static const brass = Color(0xFF785A25);
  static const cream = Color(0xFFF2EDE3);
  static const paper = Color(0xFFFCFAF5);
  static const border = Color(0xFF948570);
  static const parchmentAccent = Color(0xFFEDE2CF);
  static const mutedText = Color(0xFF62584E);
  static const wine = Color(0xFF74474A);
  static const forest = Color(0xFF3F5D4B);

  static const night = Color(0xFF211D1A);
  static const darkSurface = Color(0xFF2E2823);
  static const darkElevated = Color(0xFF39312A);
  static const parchmentText = Color(0xFFF1E8DA);
  static const mutedParchment = Color(0xFFC7B9A5);
  static const nightBorder = Color(0xFF91806E);
  static const nightBrass = Color(0xFFD1B16F);
  static const nightWine = Color(0xFFE0A4A0);
  static const nightForest = Color(0xFFA0C1A5);
}

abstract final class TaverinnSpace {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
  static const x10 = 40.0;
}

abstract final class TaverinnRadius {
  static const compact = 8.0;
  static const surface = 10.0;
  static const sheet = 14.0;
}

abstract final class TaverinnIconSize {
  static const navigation = 22.0;
  static const action = 20.0;
  static const setting = 22.0;
  static const status = 18.0;
}

abstract final class TaverinnTheme {
  static ThemeData get light => _build(dark: false);
  static ThemeData get dark => _build(dark: true);

  static ThemeData _build({required bool dark}) {
    final ink = dark ? TaverinnColors.parchmentText : TaverinnColors.ink;
    final secondary =
        dark ? TaverinnColors.mutedParchment : TaverinnColors.mutedText;
    final primary = dark ? TaverinnColors.nightBrass : TaverinnColors.brass;
    final background = dark ? TaverinnColors.night : TaverinnColors.cream;
    final surface = dark ? TaverinnColors.darkSurface : TaverinnColors.paper;
    final raised = dark ? TaverinnColors.darkElevated : TaverinnColors.cream;
    final border = dark ? TaverinnColors.nightBorder : TaverinnColors.border;
    final error = dark ? TaverinnColors.nightWine : TaverinnColors.wine;
    final success = dark ? TaverinnColors.nightForest : TaverinnColors.forest;
    final onPrimary = dark ? TaverinnColors.ink : Colors.white;
    final scheme = ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      secondary: dark ? TaverinnColors.parchmentText : TaverinnColors.walnut,
      onSecondary: dark ? TaverinnColors.ink : Colors.white,
      error: error,
      onError: dark ? TaverinnColors.ink : Colors.white,
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: raised,
      onSurfaceVariant: secondary,
      outline: border,
      outlineVariant: border,
      shadow: dark ? const Color(0x3D000000) : const Color(0x1A000000),
      scrim: const Color(0x99000000),
      inverseSurface: dark ? TaverinnColors.paper : TaverinnColors.ink,
      onInverseSurface: dark ? TaverinnColors.ink : TaverinnColors.paper,
      inversePrimary: dark ? TaverinnColors.brass : TaverinnColors.nightBrass,
      surfaceTint: primary,
      primaryContainer:
          dark ? TaverinnColors.darkElevated : TaverinnColors.parchmentAccent,
      onPrimaryContainer: ink,
      secondaryContainer: raised,
      onSecondaryContainer: ink,
      tertiary: success,
      onTertiary: dark ? TaverinnColors.ink : Colors.white,
      tertiaryContainer:
          dark ? const Color(0xFF344338) : const Color(0xFFE4EDE5),
      onTertiaryContainer: ink,
      errorContainer: dark ? const Color(0xFF4A302E) : const Color(0xFFF1E1DF),
      onErrorContainer: ink,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final textTheme = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
          color: ink,
          fontFamily: 'serif',
          fontWeight: FontWeight.w600,
          height: 1.08),
      displayMedium: base.textTheme.displayMedium?.copyWith(
          color: ink,
          fontFamily: 'serif',
          fontWeight: FontWeight.w600,
          height: 1.12),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: ink,
          fontFamily: 'serif',
          fontWeight: FontWeight.w600,
          height: 1.12),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: ink,
          fontFamily: 'serif',
          fontWeight: FontWeight.w600,
          height: 1.15),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color: ink,
          fontFamily: 'serif',
          fontWeight: FontWeight.w600,
          height: 1.18),
      titleLarge: base.textTheme.titleLarge
          ?.copyWith(color: ink, fontWeight: FontWeight.w600),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(color: ink, height: 1.45),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: ink, height: 1.4),
    );
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(TaverinnRadius.compact),
      borderSide: BorderSide(color: border),
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: ink,
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaverinnRadius.surface),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: TaverinnSpace.x4, vertical: TaverinnSpace.x3),
        labelStyle: TextStyle(color: secondary),
        hintStyle: TextStyle(color: secondary),
        border: outline,
        enabledBorder: outline,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaverinnRadius.compact),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaverinnRadius.compact),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaverinnRadius.compact),
          borderSide: BorderSide(color: error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
              horizontal: TaverinnSpace.x6, vertical: TaverinnSpace.x3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TaverinnRadius.compact)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: ink,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TaverinnRadius.compact)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            foregroundColor: primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: raised,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaverinnRadius.compact)),
        labelStyle: TextStyle(color: ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(backgroundColor: surface),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: primary, linearTrackColor: border),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            dark ? TaverinnColors.darkElevated : TaverinnColors.ink,
        contentTextStyle: TextStyle(color: dark ? ink : Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaverinnRadius.compact)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(TaverinnRadius.sheet))),
      ),
      dialogTheme: DialogThemeData(
          backgroundColor: surface, surfaceTintColor: Colors.transparent),
      iconTheme: IconThemeData(color: secondary),
      focusColor: dark ? const Color(0x29D1B16F) : const Color(0x29785A25),
    );
  }
}
