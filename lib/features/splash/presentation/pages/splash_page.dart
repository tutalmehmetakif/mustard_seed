import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_orb.dart';
import '../bloc/splash_bloc.dart';
import '../event/splash_event.dart';
import '../state/splash_state.dart';

/// Açılış ekranı. React'teki `SplashView` bileşeninin Flutter + BLoC
/// karşılığı: logo + marka adı + alt metin, 2.8 saniye sonra otomatik
/// olarak [onCompleted] tetiklenir. Ekrana dokunulursa hemen geçilir.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashBloc()..add(const SplashStarted()),
      child: BlocListener<SplashBloc, SplashState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == SplashStatus.completed) {
            onCompleted();
          }
        },
        child: const _SplashView(),
      ),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with SingleTickerProviderStateMixin {
  // Toplam 2000ms'lik tek bir controller üzerinde, React'teki delay/duration
  // değerlerine denk gelen Interval'lerle "kademeli" (staggered) animasyon.
  // Logo: 0 - 1200ms | Başlık: 500 - 1300ms | Alt metin: 1200 - 2000ms
  static const _totalDuration = Duration(milliseconds: 2000);

  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleOffset;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );
    _titleOffset = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
      ),
    );
    _footerOpacity = Tween<double>(begin: 0, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.read<SplashBloc>().add(const SplashSkipped()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: const GlassOrb(
                            imagePath: AppAssets.hardalTanesiLogo,
                            size: 128,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Opacity(
                        opacity: _titleOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _titleOffset.value.dy * 50),
                          child: Text(
                            'Hardal Tanesi',
                            style: AppTextStyles.headlineLg().copyWith(
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Opacity(
                    opacity: _footerOpacity.value,
                    child: Text(
                      'İÇSEL HUZUR & TEFEKKÜR',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSm(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}