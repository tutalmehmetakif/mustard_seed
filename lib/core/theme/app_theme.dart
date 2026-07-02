import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Uygulama genelinde kullanılacak ThemeData tanımları.
/// Şimdilik sadece [light] aktif olarak kullanılıyor (bkz. main.dart),
/// [dark] hazır bekliyor — ileride bir ayar ekranından açılabilir.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.gold,
          onPrimary: Colors.white,
          secondary: AppColors.goldBright,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.goldBright,
          onPrimary: AppColors.textPrimaryDark,
          secondary: AppColors.gold,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
          error: AppColors.error,
        ),
      );
}
