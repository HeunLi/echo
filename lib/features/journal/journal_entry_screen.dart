import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../home/home_providers.dart';

// ─── Emoji map ─────────────────────────────────────────────────────────────

const _emojiForScore = {1: '😞', 2: '😕', 3: '😐', 4: '🙂', 5: '🤩'};

// ─── Screen ────────────────────────────────────────────────────────────────

class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key, required this.entry});

  final MoodEntry entry;

  @override
  ConsumerState<JournalEntryScreen> createState() =>
      _JournalEntryScreenState();
}

enum _SaveState { saved, saving }

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  late final TextEditingController _controller;
  _SaveState _saveState = _SaveState.saved;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.note ?? '');
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_saveState != _SaveState.saving) {
      setState(() => _saveState = _SaveState.saving);
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), _persist);
  }

  Future<void> _persist() async {
    final text = _controller.text.trim();
    final companion = MoodEntriesCompanion(
      id: Value(widget.entry.id),
      date: Value(widget.entry.date),
      moodScore: Value(widget.entry.moodScore),
      moodLabel: Value(widget.entry.moodLabel),
      note: Value(text.isEmpty ? null : text),
    );
    await ref.read(moodDaoProvider).upsertEntry(companion);
    ref.invalidate(recentEntriesProvider);
    if (mounted) setState(() => _saveState = _SaveState.saved);
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _emojiForScore[widget.entry.moodScore] ?? '😐';
    final dateLabel =
        DateFormat('MMMM d, yyyy').format(widget.entry.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1A)),
          onPressed: () async {
            _debounce?.cancel();
            final nav = Navigator.of(context);
            await _persist();
            nav.pop();
          },
        ),
        title: Text(
          dateLabel,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C1C1A),
          ),
        ),
        centerTitle: true,
        actions: [
          // Mood emoji badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF3B5444),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 18),
                textScaler: TextScaler.noScaling,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _saveState == _SaveState.saved
                      ? Row(
                          key: const ValueKey('saved'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B5444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Saved',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF3B5444),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('saving'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 7,
                              height: 7,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: const Color(0xFF1C1C1A)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Saving…',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF1C1C1A)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2EE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.75,
              color: const Color(0xFF1C1C1A),
            ),
            decoration: InputDecoration(
              hintText: "Write whatever's on your mind…",
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                height: 1.75,
                color: const Color(0xFF1C1C1A).withValues(alpha: 0.3),
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ),
      // ── Keyboard toolbar ───────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F1),
            border: Border(
              top: BorderSide(
                color: const Color(0xFF1C1C1A).withValues(alpha: 0.08),
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Formatting (stub)
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.keyboard_outlined,
                  size: 18,
                  color: const Color(0xFF1C1C1A).withValues(alpha: 0.4),
                ),
                label: Text(
                  'FORMATTING',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: const Color(0xFF1C1C1A).withValues(alpha: 0.4),
                  ),
                ),
              ),
              // Done
              TextButton.icon(
                onPressed: () async {
                  _debounce?.cancel();
                  final nav = Navigator.of(context);
                  await _persist();
                  nav.pop();
                },
                icon: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B5444),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      size: 14, color: Colors.white),
                ),
                label: Text(
                  'DONE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF1C1C1A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
