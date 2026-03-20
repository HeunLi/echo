import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/router/app_router.dart';

class ReminderSetupScreen extends StatefulWidget {
  const ReminderSetupScreen({super.key});

  @override
  State<ReminderSetupScreen> createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends State<ReminderSetupScreen> {
  // Default: 8:00 PM
  int _hourIndex = 7;   // 1–12, index 7 = 8
  int _minuteIndex = 0; // 0,10,20...50, index 0 = 00
  int _periodIndex = 1; // 0 = AM, 1 = PM

  static const _hours = ['1','2','3','4','5','6','7','8','9','10','11','12'];
  static const _minutes = ['00','10','20','30','40','50'];
  static const _periods = ['AM','PM'];

  String get _timeLabel {
    final h = int.parse(_hours[_hourIndex]);
    final isPm = _periodIndex == 1;
    // Convert to 24h for label matching
    final hour24 = isPm ? (h == 12 ? 12 : h + 12) : (h == 12 ? 0 : h);
    if (hour24 >= 5 && hour24 < 10) return 'MORNING RITUAL';
    if (hour24 >= 10 && hour24 < 14) return 'MIDDAY CHECK-IN';
    if (hour24 >= 17 && hour24 < 20) return 'GOLDEN HOUR REFLECTION';
    if (hour24 >= 20 && hour24 < 23) return 'EVENING WIND DOWN';
    return 'QUIET MOMENT';
  }

  bool get _isGoldenHour => _timeLabel == 'GOLDEN HOUR REFLECTION';

  Future<void> _onSetReminder(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setBool('reminder_enabled', true);
    await prefs.setInt('reminder_hour', int.parse(_hours[_hourIndex]));
    await prefs.setInt('reminder_minute', int.parse(_minutes[_minuteIndex]));
    await prefs.setString('reminder_period', _periods[_periodIndex]);
    if (context.mounted) context.go(AppRoutes.home);
  }

  Future<void> _onSkip(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (context.mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEDEDE7);
    const green = Color(0xFF3B5444);
    const buttonGreen = Color(0xFF5C7A60);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // ── Bell icon ─────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E2DB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  size: 28,
                  color: green,
                ),
              ),

              const SizedBox(height: 28),

              // ── Title ─────────────────────────────────────
              Text(
                'Stay Consistent',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 44,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C1C1A),
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              // ── Subtitle ──────────────────────────────────
              Text(
                "We'll send a gentle nudge to check in.",
                style: GoogleFonts.inter(
                  fontSize: 17,
                  color: green.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // ── Picker card ───────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E2),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Hour
                          _WheelColumn(
                            items: _hours,
                            selectedIndex: _hourIndex,
                            onChanged: (i) => setState(() => _hourIndex = i),
                          ),
                          // Colon
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              ':',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF9E9E98),
                              ),
                            ),
                          ),
                          // Minute
                          _WheelColumn(
                            items: _minutes,
                            selectedIndex: _minuteIndex,
                            onChanged: (i) => setState(() => _minuteIndex = i),
                          ),
                          const SizedBox(width: 16),
                          // AM/PM
                          _WheelColumn(
                            items: _periods,
                            selectedIndex: _periodIndex,
                            onChanged: (i) => setState(() => _periodIndex = i),
                            width: 64,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Time label chip ────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey(_timeLabel),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFDFD9),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isGoldenHour
                                  ? Icons.wb_sunny_outlined
                                  : Icons.schedule_outlined,
                              size: 14,
                              color: const Color(0xFF8B6914),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _timeLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: const Color(0xFF8B6914),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // ── Set Reminder button ───────────────────────
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: () => _onSetReminder(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonGreen,
                    foregroundColor: const Color(0xFF2A3D2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Set Reminder'),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Skip ──────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => _onSkip(context),
                  child: Text(
                    'Skip for now',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF1C1C1A).withValues(alpha: 0.55),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Footer ────────────────────────────────────
              Center(
                child: Text(
                  'PRIVACY FIRST  •  ENCRYPTED JOURNEY',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFFADADA6),
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Custom drum-roll wheel column ─────────────────────────────────────────

class _WheelColumn extends StatefulWidget {
  const _WheelColumn({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.width = 80,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double width;

  @override
  State<_WheelColumn> createState() => _WheelColumnState();
}

class _WheelColumnState extends State<_WheelColumn> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        FixedExtentScrollController(initialItem: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(_WheelColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scrollController.jumpToItem(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selected item highlight
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Wheel
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: 52,
            diameterRatio: 1.8,
            physics: const FixedExtentScrollPhysics(),
            perspective: 0.003,
            onSelectedItemChanged: widget.onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, index) {
                final isSelected = index == widget.selectedIndex;
                return Center(
                  child: Text(
                    widget.items[index],
                    style: GoogleFonts.inter(
                      fontSize: isSelected ? 32 : 20,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w300,
                      color: isSelected
                          ? const Color(0xFF3B5444)
                          : const Color(0xFFB0B0A8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
