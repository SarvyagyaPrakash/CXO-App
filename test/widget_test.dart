import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_cxo/main.dart';

void main() {
  testWidgets('CXO Connect main landing smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: CXOConnectApp(),
      ),
    );

    // Verify that the title "CXO CONNECT" is visible
    expect(find.text('CXO CONNECT'), findsAtLeast(1));
  });
}
