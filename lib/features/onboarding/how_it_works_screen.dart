import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _PageData(
      title: 'Log Your Mood',
      body: 'A quick emoji-based check-in to track how you feel each day.',
    ),
    _PageData(
      title: 'Reflect Over Time',
      body:
          'See patterns in your mood and build a consistent journaling habit.',
    ),
  ];

  void _finish(BuildContext context) => context.go(AppRoutes.reminderSetup);

  void _next(BuildContext context) {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEDEDE7);
    const green = Color(0xFF3B5444);
    const buttonGreen = Color(0xFF5C7A60);
    const skipColor = Color(0xFFADADA6);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Skip link ──────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: GestureDetector(
                  onTap: () => _finish(context),
                  child: Text(
                    'SKIP TO JOURNAL',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: skipColor,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // ── Illustration card (PageView) ───────────────────
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: const [
                    _IllustrationCard(child: _MoodFaceIllustration()),
                    _IllustrationCard(child: _ChartIllustration()),
                  ],
                ),
              ),
            ),

            // ── Page indicators ────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 20),
              child: Row(
                children: List.generate(_pages.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: active ? 40 : 28,
                    height: 6,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: active ? green : const Color(0xFFD0CFC8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

            // ── Title ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Align(
                  alignment: Alignment.centerLeft,
                  key: ValueKey(_page),
                  child: Text(
                    _pages[_page].title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: green,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ),

            // ── Body text ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 40, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _pages[_page].body,
                  key: ValueKey('body_$_page'),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: green.withValues(alpha: 0.65),
                    height: 1.6,
                  ),
                ),
              ),
            ),

            // ── Next / Get Started button ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: SizedBox(
                width: 180,
                height: 54,
                child: FilledButton(
                  onPressed: () => _next(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_page == _pages.length - 1
                          ? 'Get Started'
                          : 'Next'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom spacer ──────────────────────────────────
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

// ─── Data ──────────────────────────────────────────────────────────────────

class _PageData {
  const _PageData({required this.title, required this.body});
  final String title;
  final String body;
}

// ─── Card wrapper ──────────────────────────────────────────────────────────

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Page 1: Mood face illustration ───────────────────────────────────────

class _MoodFaceIllustration extends StatelessWidget {
  const _MoodFaceIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(240, 240),
        painter: _FacePainter(),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF5C9A8).withValues(alpha: 0.4),
          const Color(0xFFF5C9A8).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(cx, cy), radius: size.width * 0.5));
    canvas.drawCircle(Offset(cx, cy), size.width * 0.5, glowPaint);

    // Mid glow
    final midPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFEBAA80).withValues(alpha: 0.35),
          const Color(0xFFEBAA80).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(cx, cy), radius: size.width * 0.38));
    canvas.drawCircle(Offset(cx, cy), size.width * 0.38, midPaint);

    // Face circle
    final facePaint = Paint()..color = const Color(0xFFE8A882);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.28, facePaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF3D2B1F);
    canvas.drawCircle(Offset(cx - 18, cy - 10), 5.5, eyePaint);
    canvas.drawCircle(Offset(cx + 18, cy - 10), 5.5, eyePaint);

    // Mouth (subtle smile arc)
    final mouthPaint = Paint()
      ..color = const Color(0xFF3D2B1F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final mouthRect = Rect.fromCenter(
      center: Offset(cx, cy + 8),
      width: 44,
      height: 20,
    );
    canvas.drawArc(mouthRect, 0.15, math.pi - 0.3, false, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Page 2: Mini chart illustration ──────────────────────────────────────

class _ChartIllustration extends StatelessWidget {
  const _ChartIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(260, 160),
        painter: _MiniChartPainter(),
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  static const _scores = [3, 2, 4, 3, 5, 4, 5];
  static const _moodColors = [
    Color(0xFFFFD54F),
    Color(0xFFFFB74D),
    Color(0xFF81C784),
    Color(0xFFFFD54F),
    Color(0xFF4DB6AC),
    Color(0xFF81C784),
    Color(0xFF4DB6AC),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 7;
    final barWidth = (size.width - 40) / barCount - 8;
    final maxH = size.height - 40;

    for (int i = 0; i < barCount; i++) {
      final score = _scores[i];
      final barH = (score / 5) * maxH;
      final x = 20 + i * ((size.width - 40) / barCount);
      final y = size.height - 24 - barH;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barH),
        const Radius.circular(6),
      );

      // Bar shadow
      final shadowPaint = Paint()
        ..color = _moodColors[i].withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(
          rrect.shift(const Offset(0, 4)), shadowPaint);

      // Bar fill
      final barPaint = Paint()..color = _moodColors[i];
      canvas.drawRRect(rrect, barPaint);
    }

    // Baseline
    final linePaint = Paint()
      ..color = const Color(0xFFDDDDD7)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(16, size.height - 24),
      Offset(size.width - 16, size.height - 24),
      linePaint,
    );

    // Day labels
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < barCount; i++) {
      final x = 20 + i * ((size.width - 40) / barCount);
      tp.text = TextSpan(
        text: days[i],
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFADADA6),
          fontWeight: FontWeight.w500,
        ),
      );
      tp.layout();
      tp.paint(
          canvas, Offset(x + barWidth / 2 - tp.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
