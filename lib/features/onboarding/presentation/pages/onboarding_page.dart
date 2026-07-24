import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mustard_seed/features/auth/data/bloc/auth_bloc.dart';
import 'package:mustard_seed/features/auth/data/event/auth_event.dart';
import 'package:mustard_seed/features/auth/data/state/auth_state.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/glass_orb.dart';

import '../bloc/onboarding_bloc.dart';
import '../event/onboarding_event.dart';
import '../state/onboarding_state.dart';
import '../widgets/onboarding_step_indicator.dart';

/// 3 adımlı onboarding akışı.
/// React tarafındaki `OnboardingView` bileşeninin Flutter + BLoC karşılığı.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.onCompleted});

  /// Onboarding tamamlandığında (son adım - Google/Apple/Misafir - veya
  /// "Geç") tetiklenir.
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: MultiBlocListener(
        listeners: [
          // "Geç" ile auth'a hiç girmeden onboarding tamamlanırsa.
          BlocListener<OnboardingBloc, OnboardingState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == OnboardingStatus.completed) {
                onCompleted();
              }
            },
          ),
          // Google / Apple ile giriş ya da "Hesapsız devam et" sonucu.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == AuthStatus.authenticated ||
                  state.status == AuthStatus.guest) {
                onCompleted();
              } else if (state.status == AuthStatus.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage!)),
                );
              }
            },
          ),
        ],
        child: const _OnboardingView(),
      ),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _OnboardingHeader(),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: context.horizontalMargin),
                child: BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: _StepContent(
                        key: ValueKey(state.currentStep),
                        step: state.currentStep,
                      ),
                    );
                  },
                ),
              ),
            ),
            const _OnboardingFooter(),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalMargin,
        vertical: 16,
      ),
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.goldBright,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'HARDAL TANESİ',
                    style: AppTextStyles.labelSm(
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              if (!state.isLastStep)
                GestureDetector(
                  onTap: () => context
                      .read<OnboardingBloc>()
                      .add(const OnboardingSkipPressed()),
                  child: Text(
                    'GEÇ',
                    style: AppTextStyles.labelSm(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 1:
        return const _OnboardingStepOne();
      case 2:
        return const _OnboardingStepTwo();
      default:
        return const _OnboardingStepThree();
    }
  }
}

class _OnboardingStepOne extends StatelessWidget {
  const _OnboardingStepOne();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GlassOrb(imagePath: AppAssets.onboardingGuidance, size: 192),
            const SizedBox(height: 48),
            Text(
              'Bir ayet gününüzü değiştirebilir.',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLg(),
            ),
            const SizedBox(height: 16),
            Text(
              'Sakinlik ve derinlik arayışınızda, her gün yeni bir anlam keşfedin.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStepTwo extends StatelessWidget {
  const _OnboardingStepTwo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GlassOrb(
              imagePath: AppAssets.onboardingIntention,
              size: 192,
              auraOpacity: 0.15,
            ),
            const SizedBox(height: 48),
            Text('Niyet Et.', style: AppTextStyles.headlineLg()),
            const SizedBox(height: 16),
            Text(
              'Her yolculuk bir niyetle başlar. Bugünün huzuru için kalbini hazırla.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStepThree extends StatelessWidget {
  const _OnboardingStepThree();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GlassOrb(imagePath: AppAssets.hardalTanesiLogo, size: 128),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    'Umudu yanında taşı.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLg(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'İçsel yolculuğunuzda daima rehberlik alın, zikirlerinizi kaydedin ve dilediğinizi sorun.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd(),
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final isLoading = authState.isLoading;
                      return Column(
                        children: [
                          _AppleSignInButton(
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => context.read<AuthBloc>().add(
                                      const AuthAppleSignInRequested(),
                                    ),
                          ),
                          const SizedBox(height: 12),
                          _GoogleSignInButton(
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => context.read<AuthBloc>().add(
                                      const AuthGoogleSignInRequested(),
                                    ),
                          ),
                          const SizedBox(height: 12),
                          _EmailContinueButton(
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => context.push('/email-auth'),
                          ),
                          const SizedBox(height: 16),
                          
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({required this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.apple, color: Colors.white, size: 20),
        label: Text(
          'Apple ile Giriş Yap',
          style: AppTextStyles.bodyMd(color: Colors.white).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF171717),
          disabledBackgroundColor: const Color(0xFF171717),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.textPrimary),
                ),
              )
            : const _GoogleLogo(size: 18),
        label: Text(
          'Google ile Giriş Yap',
          style: AppTextStyles.bodyMd(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _EmailContinueButton extends StatelessWidget {
  const _EmailContinueButton({required this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.mail_outline,
          size: 18,
          color: AppColors.textPrimary,
        ),
        label: Text(
          'E-posta ile Devam Et',
          style: AppTextStyles.bodyMd(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(
            color: AppColors.textPrimary.withValues(alpha: 0.15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

/// Google'ın resmi çok renkli "G" logosu — geçici, basitleştirilmiş
/// versiyon. Prodüksiyona geçmeden önce Google'ın resmi marka
/// kaynaklarından (developers.google.com/identity/branding) indirilen
/// orijinal SVG/PNG ile değiştirilmesi önerilir.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final strokeWidth = size.width * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromCircle(center: center, radius: r - strokeWidth / 2);

    // Google'ın 4 renginin yaklaşık açı dilimleri.
    paint.color = const Color(0xFF4285F4); // mavi
    canvas.drawArc(rect, -0.45, 1.7, false, paint);

    paint.color = const Color(0xFF34A853); // yeşil
    canvas.drawArc(rect, 1.25, 1.3, false, paint);

    paint.color = const Color(0xFFFBBC05); // sarı
    canvas.drawArc(rect, 2.55, 1.0, false, paint);

    paint.color = const Color(0xFFEA4335); // kırmızı
    canvas.drawArc(rect, 3.55, 1.35, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, top: 16),
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OnboardingStepIndicator(
                totalSteps: OnboardingState.totalSteps,
                currentStep: state.currentStep,
                onDotTap: (step) => context
                    .read<OnboardingBloc>()
                    .add(OnboardingDotTapped(step)),
              ),
              const SizedBox(height: 24),
              if (!state.isLastStep)
                _NextButton(
                  onPressed: () => context
                      .read<OnboardingBloc>()
                      .add(const OnboardingNextPressed()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gold,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 64,
          height: 64,
          child: Icon(Icons.arrow_forward, color: Colors.white),
        ),
      ),
    );
  }
}