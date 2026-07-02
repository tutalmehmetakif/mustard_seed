import 'package:equatable/equatable.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Kullanıcı alttaki ok (FAB) butonuna bastı.
class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

/// Kullanıcı "Geç" linkine bastı.
class OnboardingSkipPressed extends OnboardingEvent {
  const OnboardingSkipPressed();
}

/// Kullanıcı alttaki noktalardan (step indicator) birine dokundu.
class OnboardingDotTapped extends OnboardingEvent {
  const OnboardingDotTapped(this.step);

  final int step;

  @override
  List<Object?> get props => [step];
}
