import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sentinel/main.dart';

void main() {
  testWidgets('Shows both trackers at level 1', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SentinelApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('🚬  CIGARETTES  ·  REACHER'), findsOneWidget);
    expect(find.text('CIVILIAN'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('🛡️  FAP  ·  BATMAN'), findsOneWidget);
    expect(find.text('BRUCE WAYNE'), findsOneWidget);
  });
}
