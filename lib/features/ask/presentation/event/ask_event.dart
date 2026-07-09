import 'package:equatable/equatable.dart';

sealed class AskEvent extends Equatable {
  const AskEvent();

  @override
  List<Object?> get props => [];
}

/// Kullanıcı bir soru gönderdi (input kutusundan ya da öneri chip'inden).
class AskMessageSent extends AskEvent {
  const AskMessageSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// Kullanıcı, başarısız olan son soruyu "Yeniden Dene" ile tekrar gönderdi.
class AskRetryRequested extends AskEvent {
  const AskRetryRequested();
}