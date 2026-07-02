import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// React tarafındaki `.glass-orb` + `.animate-breathe` efektinin Flutter
/// karşılığı: dairesel, hafif camsı bir çerçeve içinde görsel + arkasında
/// bulanık bir "aura" parıltısı + yavaş nefes alma (scale/opacity) animasyonu.
class GlassOrb extends StatefulWidget {
  const GlassOrb({
    super.key,
    required this.imagePath,
    this.size = 192,
    this.auraOpacity = 0.1,
  });

  final String imagePath;
  final double size;
  final double auraOpacity;

  @override
  State<GlassOrb> createState() => _GlassOrbState();
}

class _GlassOrbState extends State<GlassOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    // CSS: 8s ease-in-out infinite, scale 1 -> 1.05 -> 1
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.4,
      height: widget.size * 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan ambiyans (blur glow)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: widget.size * 1.25,
              height: widget.size * 1.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldBright.withValues(alpha: widget.auraOpacity),
              ),
            ),
          ),
          // Nefes alan cam çerçeve
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scale.value,
                child: Opacity(opacity: _opacity.value, child: child),
              );
            },
            child: Container(
              width: widget.size,
              height: widget.size,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.goldBright.withValues(alpha: 0.25),
                    AppColors.gold.withValues(alpha: 0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}