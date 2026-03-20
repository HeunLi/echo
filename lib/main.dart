import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MoodJournalApp()));
}

class MoodJournalApp extends ConsumerWidget {
  const MoodJournalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerAsync = ref.watch(routerProvider);

    return routerAsync.when(
      data: (router) => MaterialApp.router(
        title: 'Mood Journal',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
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
