import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/daily_deed_repository.dart';
import '../event/daily_deed_event.dart';
import '../state/daily_deed_state.dart';

class DailyDeedBloc extends Bloc<DailyDeedEvent, DailyDeedState> {
  DailyDeedBloc({required DailyDeedRepository repository})
      : _repository = repository,
        super(const DailyDeedState()) {
    on<DailyDeedStarted>(_onStarted);
    on<DeedCompleted>(_onDeedCompleted);
  }

  final DailyDeedRepository _repository;

Future<void> _onStarted(
  DailyDeedStarted event,
  Emitter<DailyDeedState> emit,
) async {
  emit(state.copyWith(status: DailyDeedStatus.loading));
  try {
    final deeds = await _repository.getAllDeeds();
    final count = await _repository.getMonthlySeedCount();
    emit(state.copyWith(
      status: DailyDeedStatus.loaded,
      deeds: deeds,
      monthlySeedCount: count,
    ));
  } catch (error, stackTrace) {
    debugPrint('Ameller yüklenemedi: $error\n$stackTrace');   // ← ekleyin
    emit(state.copyWith(
      status: DailyDeedStatus.error,
      errorMessage: 'Ameller yüklenemedi.',
    ));
  }
}

  Future<void> _onDeedCompleted(
    DeedCompleted event,
    Emitter<DailyDeedState> emit,
  ) async {
    final index = state.deeds.indexWhere((d) => d.id == event.deedId);
    if (index == -1 || state.deeds[index].completedToday) return;

    final updated = List.of(state.deeds);
    updated[index] = updated[index].copyWith(completedToday: true);

    emit(state.copyWith(
      deeds: updated,
      monthlySeedCount: state.monthlySeedCount + 1,
    ));

    try {
      await _repository.markCompleted(event.deedId);
    } catch (_) {
      final reverted = List.of(state.deeds);
      reverted[index] = reverted[index].copyWith(completedToday: false);
      emit(state.copyWith(
        deeds: reverted,
        monthlySeedCount: state.monthlySeedCount - 1,
      ));
    }
  }
}