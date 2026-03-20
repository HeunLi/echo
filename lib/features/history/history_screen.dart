import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/database/database_provider.dart';
import '../../core/theme/app_theme.dart';
import '../checkin/check_in_sheet.dart';
import '../home/home_providers.dart';
import '../journal/journal_entry_screen.dart';
import 'history_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(recentEntriesProvider);
    final totalCount = allAsync.maybeWhen(
      data: (e) => e.length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(Icons.calendar_month_outlined,
              color: const Color(0xFF3B5444), size: 26),
        ),
        title: Text(
          'History',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1A),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1C1C1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: totalCount < 3
          ? _EmptyState(entryCount: totalCount)
          : const _HistoryBody(),
    );
  }
}

// ─── Main body ─────────────────────────────────────────────────────────────

class _HistoryBody extends ConsumerWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MonthSelector(),
          const SizedBox(height: 16),
          const _CalendarGrid(),
          const SizedBox(height: 24),
          Divider(color: const Color(0xFF1C1C1A).withValues(alpha: 0.08)),
          const SizedBox(height: 24),
          Text(
            '7-Day Trend',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1C1A),
            ),
          ),
          const SizedBox(height: 16),
          const _TrendChart(),
          const SizedBox(height: 24),
          const _StatsRow(),
        ],
      ),
    );
  }
}

// ─── Month selector ────────────────────────────────────────────────────────

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(historyMonthProvider);
    final label = DateFormat('MMMM yyyy').format(month);
    final now = DateTime.now();
    final isCurrentMonth =
        month.year == now.year && month.month == now.month;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECECE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF1C1C1A)),
            onPressed: () {
              ref.read(historyMonthProvider.notifier).state = DateTime(
                month.year,
                month.month - 1,
              );
            },
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1C1A),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isCurrentMonth
                  ? const Color(0xFF1C1C1A).withValues(alpha: 0.25)
                  : const Color(0xFF1C1C1A),
            ),
            onPressed: isCurrentMonth
                ? null
                : () {
                    ref.read(historyMonthProvider.notifier).state = DateTime(
                      month.year,
                      month.month + 1,
                    );
                  },
          ),
        ],
      ),
    );
  }
}

// ─── Calendar grid ─────────────────────────────────────────────────────────

class _CalendarGrid extends ConsumerWidget {
  const _CalendarGrid();

  static const _dayHeaders = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(historyMonthProvider);
    final entries = ref.watch(monthEntriesProvider);

    // Map day-of-month → moodScore
    final scoreByDay = <int, int>{};
    for (final e in entries) {
      scoreByDay[e.date.day] = e.moodScore;
    }

    // First weekday of month (0=Sun … 6=Sat)
    final firstDay = DateTime(month.year, month.month, 1);
    final offset = firstDay.weekday % 7; // Mon=1…Sun=0 → Sun-first offset
    final daysInMonth =
        DateUtils.getDaysInMonth(month.year, month.month);
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        // Day headers
        Row(
          children: _dayHeaders
              .map(
                (h) => Expanded(
                  child: Center(
                    child: Text(
                      h,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: const Color(0xFF1C1C1A).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // Weeks
        for (int row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (col) {
                final cell = row * 7 + col;
                final day = cell - offset + 1;
                if (day < 1 || day > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 48));
                }
                final score = scoreByDay[day];
                return Expanded(
                  child: _DayCell(
                    day: day,
                    score: score,
                    onTap: () => _onDayTap(context, ref, month, day, score),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  void _onDayTap(BuildContext context, WidgetRef ref, DateTime month, int day,
      int? score) {
    if (score != null) {
      // Has entry — open it
      final allAsync = ref.read(recentEntriesProvider);
      allAsync.whenData((entries) {
        final entry = entries.firstWhere(
          (e) => e.date.year == month.year &&
              e.date.month == month.month &&
              e.date.day == day,
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => JournalEntryScreen(entry: entry),
          ),
        );
      });
    } else {
      // No entry — open check-in if it's today or past
      final tapped = DateTime(month.year, month.month, day);
      final today = DateTime.now();
      if (!tapped.isAfter(DateTime(today.year, today.month, today.day))) {
        showCheckInSheet(context);
      }
    }
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.score, required this.onTap});

  final int day;
  final int? score;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = score != null
        ? moodColor(score!)
        : const Color(0xFF1C1C1A).withValues(alpha: 0.12);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$day',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    score != null ? FontWeight.w600 : FontWeight.w400,
                color: score != null
                    ? const Color(0xFF1C1C1A)
                    : const Color(0xFF1C1C1A).withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trend chart ───────────────────────────────────────────────────────────

class _TrendChart extends ConsumerWidget {
  const _TrendChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(last7DaysProvider);

    if (entries.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No data for the last 7 days',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF1C1C1A).withValues(alpha: 0.35),
            ),
          ),
        ),
      );
    }

    // Build spots: x = index (0..6), y = moodScore
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].moodScore.toDouble()));
    }

    // Day labels for x-axis
    final dayLabels = entries
        .map((e) => DateFormat('EEE').format(e.date))
        .toList();

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          minY: 0.5,
          maxY: 5.5,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              gradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFF2E7D32)],
              ),
              barWidth: 3.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= dayLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dayLabels[idx],
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1C1C1A).withValues(alpha: 0.4),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stats row ─────────────────────────────────────────────────────────────

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(historyStatsProvider);
    final avgEmoji = _emojiForAvg(stats.avgMood);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'AVG MOOD',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${stats.avgMood}',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1A),
                  ),
                ),
                const SizedBox(width: 4),
                Text(avgEmoji,
                    style: const TextStyle(fontSize: 20),
                    textScaler: TextScaler.noScaling),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'STREAK',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥',
                    style: TextStyle(fontSize: 20),
                    textScaler: TextScaler.noScaling),
                const SizedBox(width: 4),
                Text(
                  '${stats.streak} d',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFBF6000),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'BEST DAY',
            child: Text(
              stats.bestDayLabel,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3B5444),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _emojiForAvg(double avg) {
    if (avg >= 4.5) return '🤩';
    if (avg >= 3.5) return '🙂';
    if (avg >= 2.5) return '😐';
    if (avg >= 1.5) return '😕';
    return '😞';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFECECE8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: const Color(0xFF1C1C1A).withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.entryCount});

  final int entryCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = entryCount / 3.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: const Color(0xFF3B5444).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Keep logging to see\nyour trends',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1A),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Log ${ 3 - entryCount} more ${3 - entryCount == 1 ? 'entry' : 'entries'} to unlock your history view.',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF1C1C1A).withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    const Color(0xFF1C1C1A).withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF3B5444)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$entryCount / 3 entries',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF1C1C1A).withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => showCheckInGuarded(context, ref.read(moodDaoProvider)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5444),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Log today\'s mood',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
