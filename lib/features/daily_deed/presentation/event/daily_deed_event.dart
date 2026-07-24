import 'package:equatable/equatable.dart';

abstract class DailyDeedEvent extends Equatable {
  const DailyDeedEvent();
  @override
  List<Object?> get props => [];
}

class DailyDeedStarted extends DailyDeedEvent {
  const DailyDeedStarted();
}

class DeedCompleted extends DailyDeedEvent {
  const DeedCompleted(this.deedId);
  final String deedId;
  @override
  List<Object?> get props => [deedId];
}