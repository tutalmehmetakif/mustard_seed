import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/verse_of_the_day.dart';
import '../domain/repositories/verse_repository.dart';

/// [VerseRepository]'nin Supabase implementasyonu.
///
/// Rastgele satır çekmek için `verses` tablosunun üstüne tanımlı
/// `get_random_verse()` veritabanı fonksiyonunu çağırıyor (bkz.
/// supabase/verses_table.sql) — PostgREST'in kendisi "ORDER BY random()"
/// sorgusunu doğrudan desteklemediği için bu şekilde çözüldü.
class SupabaseVerseRepository implements VerseRepository {
  SupabaseVerseRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const VerseOfTheDay _fallback = VerseOfTheDay(
    id: 'fallback',
    text: 'Şüphesiz her zorlukla beraber bir kolaylık vardır.',
    reference: 'İnşirah Suresi, 6. Ayet',
  );

  @override
  Future<VerseOfTheDay> fetchRandomVerse() async {
    try {
      final response = await _client.rpc('get_random_verse');
      final rows = response as List<dynamic>;
      if (rows.isEmpty) return _fallback;
      return _fromRow(rows.first as Map<String, dynamic>);
    } catch (error) {
      // TODO(debug): Sorun teşhis edildikten sonra bu satır kaldırılabilir.
      debugPrint('fetchRandomVerse HATASI: $error');
      // Ağ hatası, tablo henüz oluşturulmamış vb. durumlarda uygulama
      // çökmesin diye sabit bir yedek ayetle devam ediyoruz.
      return _fallback;
    }
  }

  @override
  Future<VerseOfTheDay> fetchVerseById(String id) async {
    try {
      final row = await _client.from('verses').select().eq('id', id).single();
      return _fromRow(row);
    } catch (error) {
      debugPrint('fetchVerseById HATASI: $error');
      return _fallback;
    }
  }

  VerseOfTheDay _fromRow(Map<String, dynamic> row) {
    return VerseOfTheDay(
      id: row['id'] as String,
      text: row['text'] as String,
      reference: row['reference'] as String,
      explanation: row['explanation'] as String?,
    );
  }
}