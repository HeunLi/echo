import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'mood_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final moodDaoProvider = Provider<MoodDao>((ref) {
  return ref.watch(appDatabaseProvider).moodDao;
});
