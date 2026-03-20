import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await NotificationService.initialize(container);
  // Load persisted theme before first frame
  await container.read(themeModeProvider.notifier).load();
  runApp(UncontrolledProviderScope(container: container, child: const MoodJournalApp()));
}

class MoodJournalApp extends ConsumerWidget {
  const MoodJournalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerAsync = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return routerAsync.when(
      data: (router) => MaterialApp.router(
        title: 'Mood Journal',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFFEDEDE7),
          body: SizedBox.shrink(),
        ),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}
