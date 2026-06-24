import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prio/main.dart';

void main() {
  testWidgets('PrioApp diagnostics smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PrioApp()));

    // Verify that the diagnostic screen is shown.
    expect(find.text('PRIO.'), findsOneWidget);
    expect(find.text('Phase 0 Diagnostic Setup'), findsOneWidget);
    expect(find.text('Fire System Test Notification'), findsOneWidget);
  });
}
