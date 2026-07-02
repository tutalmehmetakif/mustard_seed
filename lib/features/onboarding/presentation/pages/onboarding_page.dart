import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/onboarding_bloc.dart';
import '../event/onboarding_event.dart';
import '../state/onboarding_state.dart';
import '../../../../core/widgets/glass_orb.dart';
import '../widgets/onboarding_step_indicator.dart';

/// 3 adımlı onboarding akışı.
/// React tarafındaki `OnboardingView` bileşeninin Flutter + BLoC karşılığı.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.onCompleted});

  /// Onboarding tamamlandığında (son adım veya "Geç") tetiklenir.
  /// Auth akışı henüz bağlanmadığı için şimdilik sadece navigasyon amaçlı.
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == OnboardingStatus.completed) {
            onCompleted();
          }
        },
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
                  _AppleSignInButton(
                    // TODO(auth): Gerçek Apple Sign In entegrasyonu bağlanacak.
                    onPressed: () => context
                        .read<OnboardingBloc>()
                        .add(const OnboardingNextPressed()),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context
                        .read<OnboardingBloc>()
                        .add(const OnboardingNextPressed()),
                    child: Text(
                      'Hesapsız devam et',
                      style: AppTextStyles.bodyMd(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
  const _AppleSignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.apple, color: Colors.white, size: 20),
        label: Text(
          'Apple ile Giriş Yap',
          style: AppTextStyles.bodyMd(color: Colors.white).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF171717),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
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