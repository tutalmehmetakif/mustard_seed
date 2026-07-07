import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/exceptions/ask_quran_failure.dart';
import '../../domain/repositories/ask_quran_repository.dart';
import '../event/ask_event.dart';
import '../state/ask_state.dart';

/// "Kur'an'a Sor" sohbetinin durumunu yönetir.
///
/// Doküman: "Cevaplar SADECE Kur'an referanslarıyla verilir — hadis,
/// sünnet, mezhep görüşü dahil edilmez." — bu kural burada değil, Edge
/// Function'daki sistem promptunda uygulanıyor; Bloc sadece isteği
/// gönderip UI durumunu (loading/hata/limit) yönetiyor.
class AskBloc extends Bloc<AskEvent, AskState> {
  AskBloc({required AskQuranRepository askQuranRepository})
      : _repository = askQuranRepository,
        super(AskState(messages: [_welcomeMessage])) {
    on<AskMessageSent>(_onMessageSent);
    on<AskRetryRequested>(_onRetryRequested);
  }

  final AskQuranRepository _repository;

  static final ChatMessage _welcomeMessage = ChatMessage(
    id: 'welcome',
    sender: ChatSender.ai,
    text: 'Selamün Aleyküm\n\n'
        'Kalbinize iyi gelecek ayetleri ve hikmetleri keşfedin. '
        'Ne sormak istersiniz?',
    timestamp: DateTime.now(),
  );

  Future<void> _onMessageSent(
    AskMessageSent event,
    Emitter<AskState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty || state.isLoading) return;

    if (!state.isPremium &&
        state.questionCount >= AskState.freeQuestionLimit) {
      emit(AskState(
        messages: state.messages,
        status: AskStatus.limitReached,
        questionCount: state.questionCount,
        isPremium: state.isPremium,
      ));
      return;
    }

    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: ChatSender.user,
      text: text,
      timestamp: DateTime.now(),
    );

    final messagesWithUser = [...state.messages, userMessage];

    emit(AskState(
      messages: messagesWithUser,
      status: AskStatus.loading,
      questionCount: state.questionCount + 1,
      isPremium: state.isPremium,
    ));

    await _requestAnswer(text, messagesWithUser, emit);
  }

  Future<void> _onRetryRequested(
    AskRetryRequested event,
    Emitter<AskState> emit,
  ) async {
    final lastUserMessage = state.messages.reversed.firstWhere(
      (m) => m.sender == ChatSender.user,
      orElse: () => _welcomeMessage,
    );
    if (lastUserMessage.id == 'welcome') return;

    emit(AskState(
      messages: state.messages,
      status: AskStatus.loading,
      questionCount: state.questionCount,
      isPremium: state.isPremium,
    ));

    await _requestAnswer(lastUserMessage.text, state.messages, emit);
  }

  Future<void> _requestAnswer(
    String question,
    List<ChatMessage> historyForRequest,
    Emitter<AskState> emit,
  ) async {
    try {
      final answer = await _repository.sendMessage(
        message: question,
        history: historyForRequest,
      );
      final aiMessage = ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}-ai',
        sender: ChatSender.ai,
        text: answer,
        timestamp: DateTime.now(),
      );
      emit(AskState(
        messages: [...historyForRequest, aiMessage],
        status: AskStatus.idle,
        questionCount: state.questionCount,
        isPremium: state.isPremium,
      ));
    } on AskQuranFailure catch (e) {
      emit(AskState(
        messages: historyForRequest,
        status: AskStatus.failure,
        errorMessage: e.message,
        questionCount: state.questionCount,
        isPremium: state.isPremium,
      ));
    }
  }
}