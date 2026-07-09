import 'package:equatable/equatable.dart';

enum ChatSender { user, ai }

/// "Kur'an'a Sor" sohbetindeki tek bir mesajı temsil eder.
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  final String id;
  final ChatSender sender;
  final String text;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, sender, text, timestamp];
}