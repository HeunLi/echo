import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_journal/main.dart';

void main() {
  testWidgets('App smoke test — renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MoodJournalApp()));
    expect(find.byType(MoodJournalApp), findsOneWidget);
  });
}
