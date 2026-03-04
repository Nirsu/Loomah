import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'loomah_theme.tailor.dart';

@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
/// The color palette for the Loomah app, defined as a ThemeExtension.
class LoomahPalette extends ThemeExtension<LoomahPalette>
    with _$LoomahPaletteTailorMixin {
  /// Constructor for [LoomahPalette].
  const LoomahPalette({
    required this.background,
    required this.foreground,
    required this.textDark,
    required this.textLight,
    required this.pastelPurple,
    required this.pastelLavender,
    required this.pastelViolet,
    required this.pastelPeach,
    required this.pastelCream,
    required this.pastelMint,
    required this.pastelPink,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.accentLight,
    required this.accentPink,
    required this.accentGreen,
    required this.glassBg,
    required this.glassBorder,
  });

  @override
  final Color background;
  @override
  final Color foreground;
  @override
  final Color textDark;
  @override
  final Color textLight;
  @override
  final Color pastelPurple;
  @override
  final Color pastelLavender;
  @override
  final Color pastelViolet;
  @override
  final Color pastelPeach;
  @override
  final Color pastelCream;
  @override
  final Color pastelMint;
  @override
  final Color pastelPink;
  @override
  final Color accentPrimary;
  @override
  final Color accentSecondary;
  @override
  final Color accentLight;
  @override
  final Color accentPink;
  @override
  final Color accentGreen;
  @override
  final Color glassBg;
  @override
  final Color glassBorder;

  /// The light color palette for the Loomah app.
  static const LoomahPalette light = LoomahPalette(
    background: Color(0xFFFAFAFA),
    foreground: Color(0xFF18181B),
    textDark: Color(0xFF18181B),
    textLight: Color(0xFF71717A),
    pastelPurple: Color(0xFFF5F3FF),
    pastelLavender: Color(0xFFFDF4FF),
    pastelViolet: Color(0xFFDDD6FE),
    pastelPeach: Color(0xFFFFF7ED),
    pastelCream: Color(0xFFFFFBEB),
    pastelMint: Color(0xFFECFDF5),
    pastelPink: Color(0xFFFDF2F8),
    accentPrimary: Color(0xFFF97316),
    accentSecondary: Color(0xFFEA580C),
    accentLight: Color(0xFFFFEDD5),
    accentPink: Color(0xFFFB923C),
    accentGreen: Color(0xFF10B981),
    glassBg: Color(0xB3FFFFFF),
    glassBorder: Color(0x33FFFFFF),
  );
}

/// The main theme class for the Loomah app, defining the overall look and feel of the application.
class LoomahTheme {
  LoomahTheme._();

  /// The light theme for the Loomah app, using the [LoomahPalette.light] color palette and custom text styles.
  static ThemeData light() {
    const LoomahPalette palette = LoomahPalette.light;

    final TextTheme textTheme =
        const TextTheme(
          displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
          displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ).apply(
          fontFamily: 'Nunito',
          bodyColor: palette.textDark,
          displayColor: palette.textDark,
        );

    final ColorScheme colorScheme =
        ColorScheme.fromSeed(seedColor: palette.accentPrimary).copyWith(
          primary: palette.accentPrimary,
          secondary: palette.accentSecondary,
          surface: palette.pastelCream,
          onSurface: palette.textDark,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textDark,
        elevation: 0,
      ),
    );
  }
}
