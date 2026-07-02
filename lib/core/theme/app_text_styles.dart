import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Doküman: display-hero / headline-lg / headline-md / body-lg / body-md / label-sm
///
/// line-height değerleri CSS'te px olarak veriliyor, Flutter'da ise `height`
/// font-size'a oranla çalışıyor (height = lineHeightPx / fontSizePx).
/// letter-spacing (em) değerleri de fontSize * em olarak px'e çevrildi.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle displayHero({Color? color}) => _base(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        height: 56 / 48,
        letterSpacing: -0.96,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle headlineLg({Color? color}) => _base(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        height: 40 / 32,
        letterSpacing: -0.32,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle headlineMd({Color? color}) => _base(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 32 / 24,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodyLg({Color? color}) => _base(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle bodyMd({Color? color}) => _base(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle labelSm({Color? color}) => _base(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0.65,
        color: color ?? AppColors.textSecondary,
      );
}
