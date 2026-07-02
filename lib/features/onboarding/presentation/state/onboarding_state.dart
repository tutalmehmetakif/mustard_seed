import 'package:equatable/equatable.dart';

enum OnboardingStatus { inProgress, completed }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.currentStep = 1,
    this.status = OnboardingStatus.inProgress,
  });

  /// 1, 2 veya 3 — React tarafındaki `step` state'inin karşılığı.
  final int currentStep;
  final OnboardingStatus status;

  static const int totalSteps = 3;

  bool get isLastStep => currentStep == totalSteps;

  OnboardingState copyWith({
    int? currentStep,
    OnboardingStatus? status,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [currentStep, status];
}
