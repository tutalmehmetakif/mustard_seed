import '../entities/recommended_activity.dart';

/// "Tavsiye Edilenler" içeriğinin nereden geldiğini soyutlar
/// (şu an Supabase).
abstract class RecommendedActivityRepository {
  /// Aktif tavsiyeleri `sort_order`'a göre sıralı çeker.
  Future<List<RecommendedActivity>> fetchRecommendedActivities();
}