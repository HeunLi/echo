import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/database/database_provider.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _reminderEnabled = false;
  int _hour24 = 20;
  int _minute = 0;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await NotificationService.loadSettings();
    setState(() {
      _reminderEnabled = s.enabled;
      _hour24 = s.hour24;
      _minute = s.minute;
      _loading = false;
    });
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() => _reminderEnabled = value);
    try {
      if (value) {
        await NotificationService.requestAndroidPermission();
        await NotificationService.scheduleDailyReminder(_hour24, _minute);
      } else {
        await NotificationService.cancelReminder();
      }
    } catch (e) {
      debugPrint('Failed to toggle reminder: $e');
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour24, minute: _minute),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: const Color(0xFF3B5444)),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _hour24 = picked.hour;
      _minute = picked.minute;
    });
    if (_reminderEnabled) {
      await NotificationService.scheduleDailyReminder(_hour24, _minute);
    }
  }

  String get _timeDisplay {
    final s = ReminderSettings(
        enabled: _reminderEnabled, hour24: _hour24, minute: _minute);
    return s.displayTime;
  }

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      final entries = await ref.read(moodDaoProvider).getAllEntries();
      final json = jsonEncode(entries
          .map((e) => {
                'date': e.date.toIso8601String().substring(0, 10),
                'moodScore': e.moodScore,
                'moodLabel': e.moodLabel,
                'note': e.note,
                'createdAt': e.createdAt.toIso8601String(),
              })
          .toList());

      await SharePlus.instance.share(
        ShareParams(
          text: json,
          subject: 'Mood Journal Export',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3B5444),
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                // ── REMINDERS ──────────────────────────────
                _SectionHeader('Reminders'),
                _SettingsCard(children: [
                  _SwitchRow(
                    title: 'Daily reminder',
                    value: _reminderEnabled,
                    onChanged: _toggleReminder,
                  ),
                  if (_reminderEnabled) ...[
                    _Divider(),
                    _TapRow(
                      title: 'Remind me at',
                      trailing: _TimeBadge(_timeDisplay),
                      onTap: _pickTime,
                    ),
                  ],
                ]),

                const SizedBox(height: 24),

                // ── APPEARANCE ─────────────────────────────
                _SectionHeader('Appearance'),
                _SettingsCard(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1C1C1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ThemeSegment(
                          current: themeMode,
                          onChanged: (m) =>
                              ref.read(themeModeProvider.notifier).set(m),
                        ),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 24),

                // ── DATA ───────────────────────────────────
                _SectionHeader('Data'),
                _SettingsCard(children: [
                  _TapRow(
                    title: 'Export data',
                    trailing: _exporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right,
                            color: Color(0xFFB0B0A8)),
                    onTap: _exporting ? null : _exportData,
                  ),
                ]),

                const SizedBox(height: 24),

                // ── ABOUT ──────────────────────────────────
                _SectionHeader('About'),
                _SettingsCard(children: [
                  _InfoRow(title: 'App version', value: '1.0.0'),
                  _Divider(),
                  _TapRow(
                    title: 'Rate the app',
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xFFB0B0A8)),
                    onTap: () {},
                  ),
                  _Divider(),
                  _TapRow(
                    title: 'Privacy policy',
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xFFB0B0A8)),
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 40),

                // ── Footer ─────────────────────────────────
                Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1A).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quietly observing the self.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF1C1C1A).withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: const Color(0xFF1C1C1A).withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ─── Card container ────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: const Color(0xFF1C1C1A).withValues(alpha: 0.07),
    );
  }
}

// ─── Row types ─────────────────────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C1C1A),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF3B5444),
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.title,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1C1C1A),
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C1C1A),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF1C1C1A).withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Time badge ────────────────────────────────────────────────────────────

class _TimeBadge extends StatelessWidget {
  const _TimeBadge(this.time);
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF3B5444).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3B5444),
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: Color(0xFFB0B0A8), size: 20),
      ],
    );
  }
}

// ─── Theme segment control ─────────────────────────────────────────────────

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({required this.current, required this.onChanged});

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFECECE8),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _Segment('Light', ThemeMode.light, current, onChanged),
          _Segment('Dark', ThemeMode.dark, current, onChanged),
          _Segment('System', ThemeMode.system, current, onChanged),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment(this.label, this.mode, this.current, this.onChanged);

  final String label;
  final ThemeMode mode;
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == current;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B5444) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF1C1C1A).withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}
