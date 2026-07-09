// 📁 lib/features/zikir/presentation/widgets/zikir_counter_ring.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// React'teki dairesel SVG progress ring'in Flutter karşılığı.
/// Sadece görsel çizim yapar; hiçbir state/iş mantığı barındırmaz (View katmanı).
class ZikirCounterRing extends CustomPainter {
  final double progressPercent; // 0-100
  final bool isCompleted;

  ZikirCounterRing({required this.progressPercent, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;

    final trackPaint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final progressPaint = Paint()
      ..color = isCompleted ? AppColors.goldBright : AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * 3.141592653589793 * (progressPercent.clamp(0, 100) / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2, // -90 derece: React'teki "-rotate-90" ile aynı başlangıç
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ZikirCounterRing oldDelegate) =>
      oldDelegate.progressPercent != progressPercent || oldDelegate.isCompleted != isCompleted;
}