import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/quick_zikir_template.dart';

/// Ana sayfadaki "Hızlı Zikir Sayacı" kartı.
///
/// NOT: Bu widget kendi yerel state'ini tutuyor, gerçek Zikir sekmesiyle
/// senkron DEĞİL. Arkadaşının zikir bloc'u paylaşılınca burası o bloc'a
/// bağlanacak şekilde güncellenmeli (tasarım aynı kalacak).
class QuickZikirCounterCard extends StatefulWidget {
  const QuickZikirCounterCard({super.key});

  @override
  State<QuickZikirCounterCard> createState() => _QuickZikirCounterCardState();
}

class _QuickZikirCounterCardState extends State<QuickZikirCounterCard> {
  static const _template = QuickZikirTemplate(
    phrase: 'Sübhanallah',
    translation: "Allah'ı her türlü noksanlıktan tenzih ederim.",
    target: 33,
  );

  int _count = 5;

  void _increment() {
    setState(() {
      if (_count >= _template.target) {
        _count = 0;
      } else {
        _count += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_count / _template.target).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'HIZLI ZİKİR SAYACI',
                    style: AppTextStyles.labelSm(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/zikir'),
                child: Row(
                  children: [
                    Text(
                      'Tam Ekran',
                      style: AppTextStyles.labelSm(
                        color: AppColors.gold,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 14, color: AppColors.gold),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _template.phrase,
            style: AppTextStyles.bodyLg(color: AppColors.textPrimary)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProgressRingButton(progress: progress, onTap: _increment),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$_count',
                          style: AppTextStyles.headlineMd(
                            color: AppColors.goldBright,
                          ).copyWith(fontSize: 20, height: 1),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '/ ${_template.target}',
                            style: AppTextStyles.labelSm(
                              color:
                                  AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor:
                            AppColors.outlineVariant.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.goldBright,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _template.translation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ).copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.goldBright.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sıfırlamak veya değiştirmek için',
                  style: AppTextStyles.labelSm(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ).copyWith(fontWeight: FontWeight.w400),
                ),
                GestureDetector(
                  onTap: () => context.go('/zikir'),
                  child: Text(
                    'Tıklayın',
                    style: AppTextStyles.labelSm(color: AppColors.gold)
                        .copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingButton extends StatelessWidget {
  const _ProgressRingButton({required this.progress, required this.onTap});

  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
            CustomPaint(
              size: const Size(56, 56),
              painter: _RingPainter(progress: progress),
            ),
            Text(
              '+1',
              style: AppTextStyles.labelSm(color: AppColors.gold)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = AppColors.goldBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -90 derece (yukarıdan başla)
      progress * 6.28319,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}