import 'package:drift/drift.dart';

class MoodEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get moodScore => integer()();
  TextColumn get moodLabel => text().withLength(min: 1, max: 32)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date}
      ];
}
