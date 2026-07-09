import '../entities/chat_message.dart';

/// "Kur'an'a Sor" özelliğinin backend'den bağımsız sözleşmesi.
///
/// Gerçek implementasyon (SupabaseAskQuranRepository) bir Supabase Edge
/// Function'ı çağırıyor — RAG mimarisi (vektör arama + LLM) tamamen
/// sunucu tarafında çalışıyor, API anahtarları hiçbir zaman uygulamaya
/// gömülmüyor.
abstract class AskQuranRepository {
  /// Kullanıcının sorusunu, önceki mesaj geçmişiyle birlikte gönderir.
  /// Dönen cevap SADECE Kur'an ayetlerine dayanmalı (sistem promptu
  /// bunu Edge Function tarafında zorunlu kılıyor).
  ///
  /// Başarısız olursa [AskQuranFailure] fırlatır.
  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
  });
}