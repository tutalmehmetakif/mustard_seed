import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';

enum AskStatus { idle, loading, failure, limitReached }

class AskState extends Equatable {
  const AskState({
    required this.messages,
    this.status = AskStatus.idle,
    this.errorMessage,
    this.questionCount = 0,
    this.isPremium = false,
  });

  final List<ChatMessage> messages;
  final AskStatus status;
  final String? errorMessage;

  /// Ücretsiz kullanıcının şu ana kadar sorduğu soru sayısı — doküman:
  /// "günlük 3 soru limiti". Şimdilik oturum bazlı (uygulama kapanınca
  /// sıfırlanıyor); günlük/kalıcı limit için ileride Supabase'de bir
  /// sayaç tutulması gerekecek.
  final int questionCount;

  /// TODO(premium): RevenueCat entegrasyonu kurulunca gerçek abonelik
  /// durumundan gelecek. Şimdilik her zaman false.
  final bool isPremium;

  bool get isLoading => status == AskStatus.loading;
  bool get limitReached => status == AskStatus.limitReached;

  static const int freeQuestionLimit = 3;

  @override
  List<Object?> get props => [
        messages,
        status,
        errorMessage,
        questionCount,
        isPremium,
      ];
}