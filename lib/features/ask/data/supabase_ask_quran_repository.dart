import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/chat_message.dart';
import '../domain/exceptions/ask_quran_failure.dart';
import '../domain/repositories/ask_quran_repository.dart';

/// [AskQuranRepository]'nin Supabase implementasyonu.
///
/// Gerçek RAG mantığı (vektör arama + LLM çağrısı) burada DEĞİL,
/// Supabase'e deploy edilecek `ask-quran` adlı Edge Function'da çalışıyor
/// (bkz. supabase/functions/ask-quran/index.ts). Flutter tarafı sadece
/// bu fonksiyonu çağırıp cevabı döndürüyor — Claude/OpenAI API anahtarı
/// hiçbir zaman istemci tarafında (uygulamada) bulunmuyor.
class SupabaseAskQuranRepository implements AskQuranRepository {
  SupabaseAskQuranRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'ask-quran',
        body: {
          'message': message,
          'history': history
              .map(
                (m) => {
                  'sender': m.sender.name,
                  'text': m.text,
                },
              )
              .toList(),
        },
      );

      if (response.status != 200) {
        throw const AskQuranFailure(
          'Huzur veren sunucumuzla geçici bir bağlantı sorunu yaşandı. '
          'Lütfen tekrar deneyin.',
        );
      }

      final data = response.data as Map<String, dynamic>;
      final text = data['text'] as String?;
      if (text == null || text.isEmpty) {
        throw const AskQuranFailure('Cevap alınamadı. Lütfen tekrar dene.');
      }
      return text;
    } on AskQuranFailure {
      rethrow;
    } on FunctionException catch (e) {
      throw AskQuranFailure(
        e.details?.toString() ??
            'Huzur veren sunucumuzla geçici bir bağlantı sorunu yaşandı.',
      );
    } catch (_) {
      throw const AskQuranFailure(
        'Huzur veren sunucumuzla geçici bir bağlantı sorunu yaşandı. '
        'Lütfen tekrar deneyin.',
      );
    }
  }
}