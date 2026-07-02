import 'package:flutter_bloc/flutter_bloc.dart';

import '../event/onboarding_event.dart';
import '../state/onboarding_state.dart';

/// Onboarding akışının 3 adımını yönetir.
///
/// Auth entegrasyonu henüz bağlanmadığı için "Apple ile Giriş Yap" ve
/// "Hesapsız devam et" aksiyonları da şimdilik [OnboardingNextPressed] ile
/// aynı davranıyor: son adımdaysa onboarding'i tamamlanmış sayıyor.
/// Gerçek auth akışı eklenince bu davranış ayrıştırılacak (bkz. TODO).
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
    if (state.isLastStep) {
      // TODO(auth): Burada gerçek auth akışı bağlanınca
      // "Apple ile Giriş Yap" ve "Hesapsız devam et" ayrı event'lere ayrılmalı.
      emit(state.copyWith(status: OnboardingStatus.completed));
    } else {
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
