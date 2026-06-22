import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.backgroundOrbPrimary,
    required this.backgroundOrbSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceStrong,
    required this.outline,
    required this.shadow,
    required this.primary,
    required this.primaryStrong,
    required this.primarySoft,
    required this.secondary,
    required this.secondarySoft,
    required this.errorSoft,
    required this.errorStrong,
    required this.success,
    required this.white,
    required this.black,
  });

  final Color backgroundTop;
  final Color backgroundBottom;
  final Color backgroundOrbPrimary;
  final Color backgroundOrbSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceStrong;
  final Color outline;
  final Color shadow;
  final Color primary;
  final Color primaryStrong;
  final Color primarySoft;
  final Color secondary;
  final Color secondarySoft;
  final Color errorSoft;
  final Color errorStrong;
  final Color success;
  final Color white;
  final Color black;

  static AppPalette of(BuildContext context) {
    final extension = Theme.of(context).extension<AppPalette>();
    assert(
      extension != null,
      'AppPalette is not attached to the current theme.',
    );
    return extension!;
  }

  static const light = AppPalette(
    backgroundTop: Color(0xFFFFF7F0),
    backgroundBottom: Color(0xFFF4EAE2),
    backgroundOrbPrimary: Color(0x33D79A49),
    backgroundOrbSecondary: Color(0x26B45E3C),
    textPrimary: Color(0xFF2E2622),
    textSecondary: Color(0xFF6F625A),
    surface: Color(0xFFFFFCF8),
    surfaceMuted: Color(0xFFF8EFE5),
    surfaceStrong: Color(0xFFF4E2D2),
    outline: Color(0xFFF0E4D9),
    shadow: Color(0x142E2622),
    primary: Color(0xFFB45E3C),
    primaryStrong: Color(0xFF8B4A2F),
    primarySoft: Color(0xFFF3DBCB),
    secondary: Color(0xFFD79A49),
    secondarySoft: Color(0xFFF5E5D9),
    errorSoft: Color(0xFFFFF1ED),
    errorStrong: Color(0xFFB34D3D),
    success: Color(0xFF4B7A59),
    white: Colors.white,
    black: Color(0xFF111111),
  );

  static const dark = AppPalette(
    backgroundTop: Color(0xFF171211),
    backgroundBottom: Color(0xFF241B18),
    backgroundOrbPrimary: Color(0x33D79A49),
    backgroundOrbSecondary: Color(0x26C7774F),
    textPrimary: Color(0xFFF7EDE2),
    textSecondary: Color(0xFFC2B1A3),
    surface: Color(0xFF241C19),
    surfaceMuted: Color(0xFF2D221E),
    surfaceStrong: Color(0xFF3A2A24),
    outline: Color(0xFF45352E),
    shadow: Color(0x33000000),
    primary: Color(0xFFD18A63),
    primaryStrong: Color(0xFFF0B58C),
    primarySoft: Color(0xFF56372B),
    secondary: Color(0xFFE0AE5D),
    secondarySoft: Color(0xFF4D3B26),
    errorSoft: Color(0xFF402724),
    errorStrong: Color(0xFFFF9A8A),
    success: Color(0xFF8CC79B),
    white: Color(0xFFFFFBF7),
    black: Color(0xFF0B0A09),
  );

  @override
  AppPalette copyWith({
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? backgroundOrbPrimary,
    Color? backgroundOrbSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceStrong,
    Color? outline,
    Color? shadow,
    Color? primary,
    Color? primaryStrong,
    Color? primarySoft,
    Color? secondary,
    Color? secondarySoft,
    Color? errorSoft,
    Color? errorStrong,
    Color? success,
    Color? white,
    Color? black,
  }) {
    return AppPalette(
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      backgroundOrbPrimary: backgroundOrbPrimary ?? this.backgroundOrbPrimary,
      backgroundOrbSecondary:
          backgroundOrbSecondary ?? this.backgroundOrbSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      outline: outline ?? this.outline,
      shadow: shadow ?? this.shadow,
      primary: primary ?? this.primary,
      primaryStrong: primaryStrong ?? this.primaryStrong,
      primarySoft: primarySoft ?? this.primarySoft,
      secondary: secondary ?? this.secondary,
      secondarySoft: secondarySoft ?? this.secondarySoft,
      errorSoft: errorSoft ?? this.errorSoft,
      errorStrong: errorStrong ?? this.errorStrong,
      success: success ?? this.success,
      white: white ?? this.white,
      black: black ?? this.black,
    );
  }

  @override
  ThemeExtension<AppPalette> lerp(
    covariant ThemeExtension<AppPalette>? other,
    double t,
  ) {
    if (other is! AppPalette) {
      return this;
    }
    return AppPalette(
      backgroundTop: Color.lerp(backgroundTop, other.backgroundTop, t)!,
      backgroundBottom:
          Color.lerp(backgroundBottom, other.backgroundBottom, t)!,
      backgroundOrbPrimary:
          Color.lerp(backgroundOrbPrimary, other.backgroundOrbPrimary, t)!,
      backgroundOrbSecondary:
          Color.lerp(backgroundOrbSecondary, other.backgroundOrbSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryStrong: Color.lerp(primaryStrong, other.primaryStrong, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondarySoft: Color.lerp(secondarySoft, other.secondarySoft, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      errorStrong: Color.lerp(errorStrong, other.errorStrong, t)!,
      success: Color.lerp(success, other.success, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
    );
  }
}
