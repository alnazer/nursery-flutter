import 'package:flutter/material.dart';

/// ألوان هوية الحضانة كما في ملف التصاميم (فاتح وداكن).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.bg2,
    required this.surface,
    required this.line,
    required this.ink,
    required this.body,
    required this.muted,
    required this.soft,
    required this.primary,
    required this.primaryInk,
    required this.coral,
    required this.coralSoft,
    required this.green,
    required this.greenSoft,
    required this.sun,
    required this.sunSoft,
    required this.sky,
    required this.skyInk,
    required this.purple,
    required this.purpleSoft,
  });

  final Color bg;
  final Color bg2;
  final Color surface;
  final Color line;
  final Color ink;
  final Color body;
  final Color muted;
  final Color soft;
  final Color primary;
  final Color primaryInk;
  final Color coral;
  final Color coralSoft;
  final Color green;
  final Color greenSoft;
  final Color sun;
  final Color sunSoft;
  final Color sky;
  final Color skyInk;
  final Color purple;
  final Color purpleSoft;

  static const AppColors light = AppColors(
    bg: Color(0xFFFDFAF4),
    bg2: Color(0xFFF7F3EB),
    surface: Color(0xFFFFFFFF),
    line: Color(0xFFEDE7DB),
    ink: Color(0xFF1C2848),
    body: Color(0xFF4D5670),
    muted: Color(0xFF636B82),
    soft: Color(0xFFE3F3F1),
    primary: AppTheme.brand,
    primaryInk: AppTheme.brand,
    coral: Color(0xFFC9412F),
    coralSoft: Color(0xFFFDE6E2),
    green: Color(0xFF3F8A31),
    greenSoft: Color(0xFFE6F3E2),
    sun: Color(0xFF8A5A00),
    sunSoft: Color(0xFFFDF3DE),
    sky: Color(0xFFCFE8F6),
    skyInk: Color(0xFF1F5F86),
    purple: Color(0xFF6A3FA0),
    purpleSoft: Color(0xFFEFE7FB),
  );

  static const AppColors dark = AppColors(
    bg: Color(0xFF0F1522),
    bg2: Color(0xFF161E2E),
    surface: Color(0xFF1A2336),
    line: Color(0xFF2B354A),
    ink: Color(0xFFEEF1F7),
    body: Color(0xFFC3C9D6),
    muted: Color(0xFF9AA3B5),
    soft: Color(0xFF163A38),
    primary: AppTheme.brand,
    primaryInk: Color(0xFF7FC6BD),
    coral: Color(0xFFFF8F80),
    coralSoft: Color(0xFF3B2226),
    green: Color(0xFF8BD27F),
    greenSoft: Color(0xFF1A3322),
    sun: Color(0xFFF3C768),
    sunSoft: Color(0xFF372D17),
    sky: Color(0xFF16304A),
    skyInk: Color(0xFF8FC7EF),
    purple: Color(0xFFC6A8F2),
    purpleSoft: Color(0xFF2A2140),
  );

  @override
  AppColors copyWith({Color? primary, Color? primaryInk}) => AppColors(
        bg: bg,
        bg2: bg2,
        surface: surface,
        line: line,
        ink: ink,
        body: body,
        muted: muted,
        soft: soft,
        primary: primary ?? this.primary,
        primaryInk: primaryInk ?? this.primaryInk,
        coral: coral,
        coralSoft: coralSoft,
        green: green,
        greenSoft: greenSoft,
        sun: sun,
        sunSoft: sunSoft,
        sky: sky,
        skyInk: skyInk,
        purple: purple,
        purpleSoft: purpleSoft,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return t < 0.5 ? this : other;
  }
}

class AppTheme {
  const AppTheme._();

  /// اللون الأساسي لهوية الحضانة.
  static const Color brand = Color(0xFF21847A);

  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static TextTheme _textTheme(Brightness brightness) {
    final Typography typography = Typography.material2021(platform: TargetPlatform.android);

    return brightness == Brightness.dark ? typography.white : typography.black;
  }

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: brightness,
    ).copyWith(
      primary: colors.primary,
      surface: colors.surface,
      error: colors.coral,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.bg,
      canvasColor: colors.bg,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg,
        foregroundColor: colors.ink,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: _textTheme(brightness).apply(bodyColor: colors.body, displayColor: colors.ink),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primaryInk, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.coral, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.coral, width: 2),
        ),
        labelStyle: TextStyle(color: colors.ink, fontWeight: FontWeight.w700),
        hintStyle: TextStyle(color: colors.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primaryInk),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryInk,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: colors.primaryInk, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: colors.line, space: 1, thickness: 1),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
