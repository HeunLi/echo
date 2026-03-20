import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _onGetStarted(BuildContext context) {
    context.go(AppRoutes.howItWorks);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEDEDE7);
    const green = Color(0xFF3B5444);
    const buttonGreen = Color(0xFF5C7A60);
    const footerColor = Color(0xFFADADA6);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ── Icon badge ──────────────────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 56,
                  color: green,
                ),
              ),

              const SizedBox(height: 48),

              // ── Title ────────────────────────────────────────
              Text(
                'The Journal',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 52,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: green,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // ── Subtitle ─────────────────────────────────────
              Text(
                'Your daily mood, your private space.',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  color: green.withValues(alpha: 0.65),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 4),

              // ── Get Started button ────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: () => _onGetStarted(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get Started'),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Footer ────────────────────────────────────────
              Text(
                'DIGITAL HEIRLOOM © 2024',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: footerColor,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w400,
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
