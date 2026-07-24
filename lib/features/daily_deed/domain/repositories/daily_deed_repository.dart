import '../entities/deed_list_item.dart';

abstract class DailyDeedRepository {
  Future<List<DeedListItem>> getAllDeeds();
  Future<void> markCompleted(String deedId);
  Future<int> getMonthlySeedCount();
}