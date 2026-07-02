import 'package:flutter/material.dart';

/// Hardal Tanesi marka renk paleti.
/// Kaynak: "Hardal Tanesi Visual Language" dokümanı + Tailwind tema tanımları.
///
/// Not: Şu an sadece light mode aktif kullanılıyor (bkz. AppTheme),
/// ancak dark mode değerleri de ileride kolayca açılabilsin diye burada tutuluyor.
class AppColors {
  AppColors._();

  // ---- Light mode ----
  static const Color background = Color(0xFFFFF8F1);
  static const Color surface = Color(0xFFF6EDDF);
  static const Color textPrimary = Color(0xFF1F1B13);
  static const Color textSecondary = Color(0xFF4D4635);

  // ---- Dark mode ----
  static const Color backgroundDark = Color(0xFF12100D);
  static const Color surfaceDark = Color(0xFF1E1A14);
  static const Color textPrimaryDark = Color(0xFFFBF2E4);
  static const Color textSecondaryDark = Color(0xFFD1C5AF);

  // ---- Accent (mod bağımsız) ----
  static const Color gold = Color(0xFF755B00);
  static const Color goldBright = Color(0xFFC9A227);

  // ---- Yardımcı ----
  static const Color error = Color(0xFFBA1A1A);
  static const Color outline = Color(0xFF7F7663);
  static const Color outlineVariant = Color(0xFFD1C5AF);
}
