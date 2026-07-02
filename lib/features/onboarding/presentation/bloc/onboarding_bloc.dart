import 'package:flutter_bloc/flutter_bloc.dart';

import '../event/onboarding_event.dart';
import '../state/onboarding_state.dart';

/// Onboarding akışının 3 adımını yönetir (adım geçişi, "Geç", nokta
/// göstergesi navigasyonu). Son adımdaki Google/Apple/Misafir girişleri
/// artık ayrı bir [AuthBloc] üzerinden yönetiliyor — bkz.
/// features/auth/presentation/bloc/auth_bloc.dart ve onboarding_page.dart.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingSkipPressed>(_onSkipPressed);
    on<OnboardingDotTapped>(_onDotTapped);
  }

  void _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) {
    // Son adımda (step 3) artık "ileri" ile değil, AuthBloc üzerinden
    // Google/Apple/Misafir seçimiyle tamamlanıyor — bkz. onboarding_page.dart.
    if (!state.isLastStep) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onSkipPressed(
    OnboardingSkipPressed event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(status: OnboardingStatus.completed));
  }

  void _onDotTapped(
    OnboardingDotTapped event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(currentStep: event.step));
  }
}