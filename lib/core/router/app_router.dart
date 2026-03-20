import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/checkin/check_in_screen.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/onboarding/how_it_works_screen.dart';
import '../../features/onboarding/reminder_setup_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../shared/widgets/main_shell.dart';

// Named route paths
class AppRoutes {
  AppRoutes._();
  static const welcome = '/welcome';
  static const howItWorks = '/how-it-works';
  static const reminderSetup = '/reminder-setup';
  static const home = '/';
  static const journalList = '/journal';
  static const checkIn = '/check-in';
  static const journalEntry = '/journal/:date';
  static const history = '/history';
  static const settings = '/settings';
}

const _seenKey = 'onboarding_complete';

Future<String> resolveInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool(_seenKey) ?? false;
  return seen ? AppRoutes.home : AppRoutes.welcome;
}

GoRouter buildRouter(String initialLocation) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        // ── Onboarding (shown once) ────────────────────────
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.howItWorks,
          builder: (context, state) => const HowItWorksScreen(),
        ),
        GoRoute(
          path: AppRoutes.reminderSetup,
          builder: (context, state) => const ReminderSetupScreen(),
        ),

        // ── Main app (PageView handles tab switching) ──────
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const MainShell(initialIndex: 0),
        ),

        // ── Full-screen routes ─────────────────────────────
        GoRoute(
          path: AppRoutes.checkIn,
          builder: (context, state) => const CheckInScreen(),
        ),
        GoRoute(
          path: AppRoutes.journalEntry,
          builder: (context, state) {
            final dateStr = state.pathParameters['date']!;
            return JournalScreen(dateString: dateStr);
          },
        ),
      ],
    );

final routerProvider = FutureProvider<GoRouter>((ref) async {
  final initialLocation = await resolveInitialRoute();
  return buildRouter(initialLocation);
});
