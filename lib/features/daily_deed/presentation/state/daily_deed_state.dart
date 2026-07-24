import 'package:equatable/equatable.dart';

import '../../domain/entities/deed_list_item.dart';

enum DailyDeedStatus { initial, loading, loaded, error }

class DailyDeedState extends Equatable {
  const DailyDeedState({
    this.status = DailyDeedStatus.initial,
    this.deeds = const [],
    this.monthlySeedCount = 0,
    this.errorMessage,
  });

  final DailyDeedStatus status;
  final List<DeedListItem> deeds;
  final int monthlySeedCount;
  final String? errorMessage;

  DailyDeedState copyWith({
    DailyDeedStatus? status,
    List<DeedListItem>? deeds,
    int? monthlySeedCount,
    String? errorMessage,
  }) {
    return DailyDeedState(
      status: status ?? this.status,
      deeds: deeds ?? this.deeds,
      monthlySeedCount: monthlySeedCount ?? this.monthlySeedCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, deeds, monthlySeedCount, errorMessage];
}