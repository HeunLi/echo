import 'package:drift/drift.dart';
import 'app_database.dart';
import 'mood_entry.dart';

part 'mood_dao.g.dart';

@DriftAccessor(tables: [MoodEntries])
class MoodDao extends DatabaseAccessor<AppDatabase> with _$MoodDaoMixin {
  MoodDao(super.db);

  Future<int> insertEntry(MoodEntriesCompanion entry) =>
      into(moodEntries).insert(entry);

  Future<bool> updateEntry(MoodEntriesCompanion entry) =>
      update(moodEntries).replace(entry);

  Future<int> upsertEntry(MoodEntriesCompanion entry) =>
      into(moodEntries).insertOnConflictUpdate(entry);

  Future<MoodEntry?> getEntryByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(moodEntries)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(startOfDay) &
              t.date.isSmallerThanValue(endOfDay)))
        .getSingleOrNull();
  }

  Future<List<MoodEntry>> getAllEntries() =>
      (select(moodEntries)..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<MoodEntry>> watchAllEntries() =>
      (select(moodEntries)..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<MoodEntry>> getEntriesInRange(
      DateTime start, DateTime end) =>
      (select(moodEntries)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<int> deleteEntry(int id) =>
      (delete(moodEntries)..where((t) => t.id.equals(id))).go();
}
