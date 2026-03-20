import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/router/app_router.dart';
import '../checkin/check_in_sheet.dart';

import '../../core/theme/app_theme.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const bg = Color(0xFFEDEDE7);
    const green = Color(0xFF3B5444);
    final entriesAsync = ref.watch(recentEntriesProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────
            SliverAppBar(
              backgroundColor: bg,
              floating: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, color: green),
                onPressed: () {},
              ),
              title: Text(
                'The Journal',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: green,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFE8B4A0),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),

                  // ── Greeting ──────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$_greeting ',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1C1A),
                          height: 1.1,
                        ),
                      ),
                      const Text('👋', style: TextStyle(fontSize: 32)),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ── Date ──────────────────────────────────
                  Text(
                    DateFormat('EEEE, MMMM d')
                        .format(DateTime.now())
                        .toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: green.withValues(alpha: 0.5),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── CTA card / Checked-in card ─────────────
                  entriesAsync.when(
                    data: (entries) {
                      final todayStr = DateFormat('yyyy-MM-dd')
                          .format(DateTime.now());
                      final todayEntry = entries.where(
                        (e) =>
                            DateFormat('yyyy-MM-dd').format(e.date) == todayStr,
                      ).firstOrNull;
                      if (todayEntry != null) {
                        return _CheckedInCard(entry: todayEntry);
                      }
                      return _CtaCard(
                          onTap: () => showCheckInSheet(context));
                    },
                    loading: () => _CtaCard(onTap: () {}),
                    error: (_, __) =>
                        _CtaCard(onTap: () => showCheckInSheet(context)),
                  ),

                  const SizedBox(height: 16),

                  // ── Streak chip ───────────────────────────
                  entriesAsync.maybeWhen(
                    data: (entries) {
                      final streak = computeStreak(entries);
                      if (streak == 0) return const SizedBox.shrink();
                      return _StreakChip(streak: streak);
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 36),

                  // ── Recent Entries header ──────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Entries',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C1C1A),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.journalList),
                        child: Text(
                          'View all',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: green.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Entry cards ───────────────────────────
                  entriesAsync.when(
                    data: (entries) {
                      if (entries.isEmpty) {
                        return _EmptyEntries(
                            onTap: () =>
                                showCheckInSheet(context));
                      }
                      final recent = entries.take(3).toList();
                      return Column(
                        children: [
                          ...recent.map((e) => _EntryCard(entry: e)),
                          const SizedBox(height: 8),
                          _AddMemoryRow(
                              onTap: () =>
                                  showCheckInSheet(context)),
                        ],
                      );
                    },
                    loading: () => const SizedBox(height: 80),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CTA card (not checked in) ─────────────────────────────────────────────

class _CtaCard extends StatelessWidget {
  const _CtaCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF0C9A8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative book
          Positioned(
            right: -10,
            bottom: 0,
            child: Opacity(
              opacity: 0.35,
              child: Icon(
                Icons.menu_book_rounded,
                size: 140,
                color: const Color(0xFF8B5E3C),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'How are you\nfeeling today?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1A),
                    height: 1.25,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1A),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Log mood',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('✏️', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Checked-in card ───────────────────────────────────────────────────────

class _CheckedInCard extends StatelessWidget {
  const _CheckedInCard({required this.entry});
  final MoodEntry entry;

  static const _emojis = {1: '😞', 2: '😕', 3: '😐', 4: '🙂', 5: '😄'};

  @override
  Widget build(BuildContext context) {
    final emoji = _emojis[entry.moodScore] ?? '😐';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: moodColor(entry.moodScore).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: moodColor(entry.moodScore).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.moodLabel} — logged ✓',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF1C1C1A),
                  ),
                ),
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF1C1C1A).withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => showCheckInSheet(context),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B5444),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Streak chip ───────────────────────────────────────────────────────────

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            '$streak-DAY STREAK',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: const Color(0xFF1C1C1A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Entry card ────────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final MoodEntry entry;

  static const _emojis = {1: '😞', 2: '😕', 3: '😐', 4: '🙂', 5: '😄'};

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(entryDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _emojis[entry.moodScore] ?? '😐';
    final avatarColor = moodColor(entry.moodScore).withValues(alpha: 0.25);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateLabel(entry.date),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF1C1C1A),
                  ),
                ),
                if (entry.note != null && entry.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: const Color(0xFF1C1C1A).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // More menu
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.more_horiz,
              size: 20,
              color: const Color(0xFF1C1C1A).withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add another memory row ────────────────────────────────────────────────

class _AddMemoryRow extends StatelessWidget {
  const _AddMemoryRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0EA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1C1C1A).withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1A).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 18,
                color: const Color(0xFF1C1C1A).withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Add another memory',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF1C1C1A).withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────

class _EmptyEntries extends StatelessWidget {
  const _EmptyEntries({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              'Nothing here yet.',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF1C1C1A).withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTap,
              child: Text(
                'Log your first mood →',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B5444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
