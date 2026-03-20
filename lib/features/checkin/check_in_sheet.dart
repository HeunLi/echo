import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_providers.dart';

// ─── Public helper to open the sheet ──────────────────────────────────────

Future<void> showCheckInSheet(BuildContext context,
    {MoodEntry? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => CheckInSheet(existing: existing),
  );
}

// ─── Mood data ─────────────────────────────────────────────────────────────

const _moods = [
  _Mood(score: 1, emoji: '😞', label: 'TERRIBLE'),
  _Mood(score: 2, emoji: '😕', label: 'BAD'),
  _Mood(score: 3, emoji: '😐', label: 'OKAY'),
  _Mood(score: 4, emoji: '🙂', label: 'GOOD'),
  _Mood(score: 5, emoji: '🤩', label: 'GREAT'),
];

class _Mood {
  const _Mood({required this.score, required this.emoji, required this.label});
  final int score;
  final String emoji;
  final String label;
}

// ─── Sheet widget ──────────────────────────────────────────────────────────

class CheckInSheet extends ConsumerStatefulWidget {
  const CheckInSheet({super.key, this.existing});

  final MoodEntry? existing;

  @override
  ConsumerState<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends ConsumerState<CheckInSheet> {
  int? _selectedScore;
  late final TextEditingController _noteController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _selectedScore = widget.existing!.moodScore;
      _noteController =
          TextEditingController(text: widget.existing!.note ?? '');
    } else {
      _noteController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedScore == null) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    final mood = _moods.firstWhere((m) => m.score == _selectedScore);
    final note = _noteController.text.trim();

    final companion = MoodEntriesCompanion(
      id: widget.existing != null
          ? Value(widget.existing!.id)
          : const Value.absent(),
      date: Value(date),
      moodScore: Value(_selectedScore!),
      moodLabel: Value(mood.label),
      note: Value(note.isEmpty ? null : note),
    );

    await ref.read(moodDaoProvider).upsertEntry(companion);

    // Invalidate so HomeScreen refreshes
    ref.invalidate(recentEntriesProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCCCCC6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // ── Date ────────────────────────────────────────
          Text(
            'TODAY, ${DateFormat('MMMM d').format(DateTime.now()).toUpperCase()}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: const Color(0xFF1C1C1A).withValues(alpha: 0.45),
            ),
          ),

          const SizedBox(height: 8),

          // ── Title ───────────────────────────────────────
          Text(
            'How are you feeling?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1A),
            ),
          ),

          const SizedBox(height: 32),

          // ── Mood selector ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _moods
                  .map((m) => _MoodOption(
                        mood: m,
                        isSelected: _selectedScore == m.score,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedScore = m.score);
                        },
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 28),

          // ── Note field ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ValueListenableBuilder(
              valueListenable: _noteController,
              builder: (context, value, _) {
                return TextField(
                  controller: _noteController,
                  maxLines: 4,
                  maxLength: 280,
                  buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) =>
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '$currentLength/280',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color:
                                const Color(0xFF1C1C1A).withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF1C1C1A),
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF1C1C1A).withValues(alpha: 0.35),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFECECE8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── Save button ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed:
                    (_selectedScore != null && !_saving) ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5444),
                  disabledBackgroundColor:
                      const Color(0xFF3B5444).withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Single mood option ────────────────────────────────────────────────────

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  final _Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glowColor = moodColor(mood.score);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            // Emoji with glow
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              width: isSelected ? 64 : 44,
              height: isSelected ? 64 : 44,
              decoration: isSelected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.45),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    )
                  : null,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  style: TextStyle(
                    fontSize: isSelected ? 48 : 32,
                  ),
                  child: Text(
                    mood.emoji,
                    textScaler: TextScaler.noScaling,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.8,
                color: isSelected
                    ? moodColor(mood.score)
                    : const Color(0xFF1C1C1A).withValues(alpha: 0.4),
              ),
              child: Text(mood.label),
            ),
          ],
        ),
      ),
    );
  }
}
