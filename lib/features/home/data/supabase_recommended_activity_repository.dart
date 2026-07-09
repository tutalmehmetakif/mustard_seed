import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/recommended_activity.dart';
import '../domain/repositories/recommended_activity_repository.dart';

/// [RecommendedActivityRepository]'nin Supabase implementasyonu.
///
/// `recommended_activities` tablosundan `is_active = true` satırları
/// `sort_order`'a göre sıralı çeker (bkz. supabase/recommended_activities_table.sql).
class SupabaseRecommendedActivityRepository
    implements RecommendedActivityRepository {
  SupabaseRecommendedActivityRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // Ağ hatası ya da tablo henüz boşsa uygulama boş görünmesin diye
  // yedek olarak eski sabit içerik korunuyor.
  static const List<RecommendedActivity> _fallback = [
    RecommendedActivity(
      id: 'fallback-1',
      category: 'Tefekkür',
      title: 'Sabır ve Şükür',
      description:
          'Zorluk anlarında sabrın, bolluk anlarında şükrün anlamı '
          'üzerine kısa bir okuma.',
      readTime: '3 dk',
      content:
          'Hayat, zıtlıkların ahenginden oluşur. Zorluklar sabırla, '
          'kolaylıklar şükürle karşılandığında insan ruhu olgunlaşır. '
          "Kur'an-ı Kerim'de 'Şüphesiz Allah sabredenlerle beraberdir' "
          'buyurulur. Sabır, pasif bir kabulleniş değil, umutlu dolu aktif '
          'bir duruştur. Şükür ise sahip olduklarımızın değerini bilerek '
          'kalbimizde bir tatmin duygusu uyandırmaktır. Bu iki liman, '
          'fırtınalı zamanlarda ruhumuzu dinginliğe ulaştıracaktır.',
      verseRef: 'Bakara Suresi, 153. Ayet',
    ),
    RecommendedActivity(
      id: 'fallback-2',
      category: 'Ayet',
      title: 'Kolaylık Üzerine',
      description:
          'Her zorluğun yanında bir kolaylık olduğuna dair ayetler ve '
          'kısa açıklaması.',
      readTime: '2 dk',
      content: 'Şüphesiz her zorlukla beraber bir kolaylık vardır.',
      verseRef: 'İnşirah Suresi, 5. Ayet',
    ),
  ];

  @override
  Future<List<RecommendedActivity>> fetchRecommendedActivities() async {
    try {
      final rows = await _client
          .from('recommended_activities')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      if (rows.isEmpty) return _fallback;
      return rows.map((row) => _fromRow(row)).toList();
    } catch (error) {
      // TODO(debug): Sorun teşhis edildikten sonra bu satır kaldırılabilir.
      debugPrint('fetchRecommendedActivities HATASI: $error');
      return _fallback;
    }
  }

  RecommendedActivity _fromRow(Map<String, dynamic> row) {
    return RecommendedActivity(
      id: row['id'] as String,
      category: row['category'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      readTime: row['read_time'] as String,
      content: row['content'] as String,
      verseRef: row['verse_ref'] as String?,
    );
  }
}