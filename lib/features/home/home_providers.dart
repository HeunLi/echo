import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';

final recentEntriesProvider = StreamProvider<List<MoodEntry>>((ref) {
  return ref.watch(moodDaoProvider).watchAllEntries();
});

final todayEntryProvider = FutureProvider<MoodEntry?>((ref) {
  return ref.watch(moodDaoProvider).getEntryByDate(DateTime.now());
});

int computeStreak(List<MoodEntry> entries) {
  if (entries.isEmpty) return 0;
  final dates = entries
      .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
      .toSet();
  var day = DateTime.now();
  day = DateTime(day.year, day.month, day.day);
  int streak = 0;
  while (dates.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}
