import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../checkin/check_in_sheet.dart';
import '../home/home_providers.dart';
import 'journal_entry_screen.dart';

const _emojiForScore = {1: '😞', 2: '😕', 3: '😐', 4: '🙂', 5: '🤩'};

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(recentEntriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1C1C1A)),
          onPressed: () {},
        ),
        title: Text(
          'Journal',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1C1C1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) => entries.isEmpty
            ? _EmptyState(onTap: () => showCheckInGuarded(context, ref.read(moodDaoProvider)))
            : _EntryList(entries: entries),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCheckInGuarded(context, ref.read(moodDaoProvider)),
        backgroundColor: const Color(0xFF3B5444),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─── Grouped list ──────────────────────────────────────────────────────────

class _EntryList extends StatelessWidget {
  const _EntryList({required this.entries});

  final List<MoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<MoodEntry>>{};
    for (final e in entries) {
      final key = DateFormat('MMMM yyyy').format(e.date).toUpperCase();
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final months = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: months.length,
      itemBuilder: (context, i) {
        final month = months[i];
        final monthEntries = grouped[month]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 12),
              child: Text(
                month,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: const Color(0xFF1C1C1A).withValues(alpha: 0.4),
                ),
              ),
            ),
            ...monthEntries.map((e) => _EntryCard(entry: e)),
          ],
        );
      },
    );
  }
}

// ─── Entry card ────────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final MoodEntry entry;

  @override
  Widget build(BuildContext context) {
    final emoji = _emojiForScore[entry.moodScore] ?? '😐';
    final dateLabel = DateFormat('EEE, MMM d').format(entry.date);
    final timeLabel = DateFormat('h:mm a').format(entry.createdAt);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => JournalEntryScreen(entry: entry),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF1C1C1A).withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 26),
                      textScaler: TextScaler.noScaling,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECECE8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry.moodLabel,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color:
                              const Color(0xFF1C1C1A).withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                entry.note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: const Color(0xFF1C1C1A).withValues(alpha: 0.55),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFECECE8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 64,
                        color: const Color(0xFF1C1C1A).withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 80,
                        height: 3,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF1C1C1A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 56,
                        height: 3,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF1C1C1A).withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: -16,
                    right: 20,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4C4A8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1C1C1A)
                                .withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        size: 26,
                        color: const Color(0xFF1C1C1A).withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Nothing here yet.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Capture your first thought and begin your journey of self-reflection.',
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: const Color(0xFF1C1C1A).withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Log your first mood',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5444),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
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
