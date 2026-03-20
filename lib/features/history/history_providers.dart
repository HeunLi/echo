import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../home/home_providers.dart';

// ─── Selected month (default = current month) ──────────────────────────────

final historyMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

// ─── Entries for the displayed month ──────────────────────────────────────

final monthEntriesProvider = Provider<List<MoodEntry>>((ref) {
  final month = ref.watch(historyMonthProvider);
  final allAsync = ref.watch(recentEntriesProvider);
  return allAsync.maybeWhen(
    data: (entries) => entries.where((e) {
      return e.date.year == month.year && e.date.month == month.month;
    }).toList(),
    orElse: () => [],
  );
});

// ─── Entries for the last 7 days ──────────────────────────────────────────

final last7DaysProvider = Provider<List<MoodEntry>>((ref) {
  final allAsync = ref.watch(recentEntriesProvider);
  return allAsync.maybeWhen(
    data: (entries) {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      return entries
          .where((e) => e.date.isAfter(cutoff))
          .toList()
          .reversed
          .toList();
    },
    orElse: () => [],
  );
});

// ─── Stats ────────────────────────────────────────────────────────────────

class HistoryStats {
  const HistoryStats({
    required this.avgMood,
    required this.streak,
    required this.bestDayLabel,
  });
  final double avgMood;
  final int streak;
  final String bestDayLabel;
}

final historyStatsProvider = Provider<HistoryStats>((ref) {
  final allAsync = ref.watch(recentEntriesProvider);
  final month = ref.watch(historyMonthProvider);

  return allAsync.maybeWhen(
    data: (entries) {
      // Avg mood: last 7 days
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      final week = entries.where((e) => e.date.isAfter(cutoff)).toList();
      final avg = week.isEmpty
          ? 0.0
          : week.map((e) => e.moodScore).reduce((a, b) => a + b) /
              week.length;

      // Streak
      final streak = computeStreak(entries);

      // Best day: highest mood in current month
      final monthEntries = entries.where(
        (e) => e.date.year == month.year && e.date.month == month.month,
      );
      String bestDay = '—';
      if (monthEntries.isNotEmpty) {
        final best = monthEntries.reduce(
          (a, b) => a.moodScore >= b.moodScore ? a : b,
        );
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        bestDay = days[(best.date.weekday - 1) % 7];
      }

      return HistoryStats(
        avgMood: double.parse(avg.toStringAsFixed(1)),
        streak: streak,
        bestDayLabel: bestDay,
      );
    },
    orElse: () =>
        const HistoryStats(avgMood: 0, streak: 0, bestDayLabel: '—'),
  );
});
