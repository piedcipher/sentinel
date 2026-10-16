import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sentinel/main.dart';

void main() {
  testWidgets('Shows both trackers at level 1', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SentinelApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('CIGARETTES'), findsOneWidget);
    expect(find.text('FAP'), findsOneWidget);
    expect(find.text('LEVEL 1 · Civilian'), findsOneWidget);
    expect(find.text('LEVEL 1 · Bruce Wayne'), findsOneWidget);
  });
}
