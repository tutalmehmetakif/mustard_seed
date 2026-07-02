import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../event/splash_event.dart';
import '../state/splash_state.dart';

/// React tarafındaki `setTimeout(onNext, 2800)` mantığının BLoC karşılığı.
///
/// Timer, bloc kapatıldığında (`close`) iptal edilir — sayfa değiştiğinde
/// "kapalı bir bloc'a emit etmeye çalışıyorsun" hatası almamak için önemli.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashState()) {
    on<SplashStarted>(_onStarted);
    on<SplashSkipped>(_onSkipped);
  }

  Timer? _timer;

  static const _splashDuration = Duration(milliseconds: 2800);

  void _onStarted(SplashStarted event, Emitter<SplashState> emit) {
    _timer?.cancel();
    _timer = Timer(_splashDuration, () {
      if (!isClosed) add(const SplashSkipped());
    });
  }

  void _onSkipped(SplashSkipped event, Emitter<SplashState> emit) {
    _timer?.cancel();
    emit(state.copyWith(status: SplashStatus.completed));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}