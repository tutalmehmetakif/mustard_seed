import 'package:equatable/equatable.dart';

class DeedListItem extends Equatable {
  const DeedListItem({
    required this.id,
    required this.text,
    required this.completedToday,
  });

  final String id;
  final String text;
  final bool completedToday;

  DeedListItem copyWith({bool? completedToday}) => DeedListItem(
        id: id,
        text: text,
        completedToday: completedToday ?? this.completedToday,
      );

  @override
  List<Object?> get props => [id, text, completedToday];
}