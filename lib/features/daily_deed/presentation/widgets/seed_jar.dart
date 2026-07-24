import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SeedJar extends StatelessWidget {
  const SeedJar({
    super.key,
    required this.seedCount,
    required this.targetCount,
    this.size = 140,
  });

  final int seedCount;
  final int targetCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ratio =
        targetCount == 0 ? 0.0 : (seedCount / targetCount).clamp(0.0, 1.0);
    final percentage = (ratio * 100).round();

    return SizedBox(
      width: size/1.2,
      height: size * 1.35,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: ratio),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size * 1.35),
                painter: _JarPainter(
                  fillRatio: value,
                  isDarkMode: isDarkMode,
                  seedCount: seedCount,
                ),
              ),
              Positioned(
                bottom: size * 0.24,
                child: Column(
                  children: [
                    Text(
                      '%$percentage',
                      style: AppTextStyles.displayHero(
                        color: value > 0.4
                            ? Colors.white
                            : (isDarkMode
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                      ).copyWith(fontSize: size * 0.19, height: 1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'DOLU',
                      style: AppTextStyles.labelSm(
                        color: value > 0.4
                            ? Colors.white.withValues(alpha: 0.85)
                            : (isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary)
                                .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _JarPainter extends CustomPainter {
  _JarPainter({
    required this.fillRatio,
    required this.isDarkMode,
    required this.seedCount,
  });

  final double fillRatio;
  final bool isDarkMode;
  final int seedCount;

  @override
  void paint(Canvas canvas, Size size) {
    final jarPath = _buildJarPath(size);
    final lidPath = _buildLidPath(size);
    final outlineColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.outline;

    canvas.drawShadow(jarPath, Colors.black.withValues(alpha: 0.18), 10, false);

    // Cam gövde zemini.
    canvas.drawPath(
      jarPath,
      Paint()..color = (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.035),
    );

    canvas.save();
    canvas.clipPath(jarPath);

    if (fillRatio > 0) {
      final fillTop = size.height - (size.height * fillRatio * 0.82);
      final fillRect = Rect.fromLTWH(0, fillTop, size.width, size.height - fillTop);

      canvas.drawRect(
        fillRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.goldBright, AppColors.gold],
          ).createShader(fillRect),
      );

      canvas.drawLine(
        Offset(0, fillTop),
        Offset(size.width, fillTop),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..strokeWidth = 2.5,
      );

      // Tohumlar — tabana doğru yığılan, organik dağılım.
      final random = Random(42);
      final seedBody = Paint()..color = const Color(0xFF6B4A12);
      final seedHighlight = Paint()..color = Colors.white.withValues(alpha: 0.5);
      final visibleSeeds = (seedCount * 5).clamp(0, 220);

      for (var i = 0; i < visibleSeeds; i++) {
        final dx = random.nextDouble() * size.width;
        final depthBias = pow(random.nextDouble(), 1.6); // altta yoğunlaşsın
        final dy = fillTop + 8 + depthBias * (size.height - fillTop - 14);
        final r = 1.8 + random.nextDouble() * 0.9;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(dx, dy.toDouble()), width: r * 2, height: r * 1.3),
          seedBody,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(dx - 0.4, dy.toDouble() - 0.4),
            width: r * 0.7,
            height: r * 0.45,
          ),
          seedHighlight,
        );
      }
    }

    canvas.restore();

    // Ana kontur.
    canvas.drawPath(
      jarPath,
      Paint()
        ..color = outlineColor.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Kapak — ayrı, hafif dolgulu.
    canvas.drawPath(
      lidPath,
      Paint()..color = (isDarkMode ? AppColors.surfaceDark : AppColors.surface),
    );
    canvas.drawPath(
      lidPath,
      Paint()
        ..color = outlineColor.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Cam parlaklığı — sol tarafta eğik highlight.
    final highlightPath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.26)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.6,
        size.width * 0.15,
        size.height * 0.88,
      );
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: isDarkMode ? 0.1 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.02
        ..strokeCap = StrokeCap.round,
    );

    // İkinci, daha ince bir highlight (cam kalınlığı hissi).
    final highlight2 = Path()
      ..moveTo(size.width * 0.28, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.55,
        size.width * 0.27,
        size.height * 0.75,
      );
    canvas.drawPath(
      highlight2,
      Paint()
        ..color = Colors.white.withValues(alpha: isDarkMode ? 0.06 : 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.008
        ..strokeCap = StrokeCap.round,
    );
  }

  Path _buildJarPath(Size size) {
    final w = size.width;
    final h = size.height;
    final neckW = w * 0.42;

    return Path()
      ..moveTo(w / 2 - neckW / 2, h * 0.1)
      ..lineTo(w / 2 + neckW / 2, h * 0.1)
      ..lineTo(w / 2 + neckW / 2, h * 0.2)
      ..quadraticBezierTo(w, h * 0.2, w, h * 0.38)
      ..lineTo(w, h * 0.92)
      ..quadraticBezierTo(w, h, w * 0.88, h)
      ..lineTo(w * 0.12, h)
      ..quadraticBezierTo(0, h, 0, h * 0.92)
      ..lineTo(0, h * 0.38)
      ..quadraticBezierTo(0, h * 0.2, w / 2 - neckW / 2, h * 0.2)
      ..close();
  }

  Path _buildLidPath(Size size) {
    final w = size.width;
    final h = size.height;
    final lidW = w * 0.5;

    return Path()
      ..moveTo(w / 2 - lidW / 2, 0)
      ..lineTo(w / 2 + lidW / 2, 0)
      ..quadraticBezierTo(w / 2 + lidW / 2 + 4, h * 0.05, w / 2 + lidW / 2, h * 0.1)
      ..lineTo(w / 2 - lidW / 2, h * 0.1)
      ..quadraticBezierTo(w / 2 - lidW / 2 - 4, h * 0.05, w / 2 - lidW / 2, 0)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _JarPainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio || oldDelegate.seedCount != seedCount;
  }
}