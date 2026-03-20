import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/notifications/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enabled = false;
  int _hour24 = 20;
  int _minute = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await NotificationService.loadSettings();
    setState(() {
      _enabled = s.enabled;
      _hour24 = s.hour24;
      _minute = s.minute;
      _loading = false;
    });
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() => _enabled = value);
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
          timePickerTheme: TimePickerThemeData(
            backgroundColor: const Color(0xFFF7F7F4),
            hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            dialBackgroundColor: const Color(0xFFECECE8),
          ),
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color(0xFF3B5444),
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _hour24 = picked.hour;
      _minute = picked.minute;
    });
    if (_enabled) {
      await NotificationService.scheduleDailyReminder(_hour24, _minute);
    }
  }

  String get _timeDisplay {
    final s = ReminderSettings(enabled: _enabled, hour24: _hour24, minute: _minute);
    return s.displayTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1A),
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _SectionHeader('Reminders'),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      icon: Icons.notifications_outlined,
                      title: 'Daily reminder',
                      subtitle: 'Get nudged to check in each day',
                      trailing: Switch(
                        value: _enabled,
                        onChanged: _toggleReminder,
                        activeThumbColor: const Color(0xFF3B5444),
                        activeTrackColor: const Color(0xFF3B5444).withValues(alpha: 0.4),
                      ),
                    ),
                    if (_enabled) ...[
                      Divider(
                        height: 1,
                        color: const Color(0xFF1C1C1A).withValues(alpha: 0.06),
                      ),
                      _SettingsRow(
                        icon: Icons.schedule_outlined,
                        title: 'Reminder time',
                        subtitle: _timeDisplay,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: const Color(0xFF1C1C1A).withValues(alpha: 0.3),
                        ),
                        onTap: _pickTime,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
                _SectionHeader('About'),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      icon: Icons.lock_outline,
                      title: 'Privacy',
                      subtitle: 'All data stays on your device',
                    ),
                    Divider(
                      height: 1,
                      color: const Color(0xFF1C1C1A).withValues(alpha: 0.06),
                    ),
                    _SettingsRow(
                      icon: Icons.info_outline,
                      title: 'Version',
                      subtitle: '1.0.0',
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
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
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF3B5444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF3B5444)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C1C1A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF1C1C1A).withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
