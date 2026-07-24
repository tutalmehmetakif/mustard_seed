import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/deed_list_item.dart';
import '../../domain/repositories/daily_deed_repository.dart';

class SupabaseDailyDeedRepository implements DailyDeedRepository {
  SupabaseDailyDeedRepository(this._client);

  final SupabaseClient _client;

@override
Future<List<DeedListItem>> getAllDeeds() async {
  final result = await _client.rpc('get_today_deeds');
  return (result as List).map((row) {
    final map = row as Map<String, dynamic>;
    return DeedListItem(
      id: map['out_deed_id'] as String,
      text: map['out_deed_text'] as String,
      completedToday: map['out_completed'] as bool? ?? false,
    );
  }).toList();
}

  @override
  Future<void> markCompleted(String deedId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('deed_completions').insert({
      'user_id': userId,
      'deed_id': deedId,
    });
  }

  @override
  Future<int> getMonthlySeedCount() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final now = DateTime.now();
    final startOfMonth =
        DateTime(now.year, now.month, 1).toIso8601String().split('T').first;

    final result = await _client
        .from('deed_completions')
        .select('id')
        .eq('user_id', userId)
        .gte('completed_date', startOfMonth);

    return (result as List).length;
  }
}