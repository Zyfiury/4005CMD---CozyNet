import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_app/temperature_control.dart';

void main() {
  testWidgets('Temperature control updates UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TemperatureControlScreen())),
    );

    expect(find.text('20°C'), findsOneWidget);

    // Test "+" button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('21°C'), findsOneWidget);

    // Test slider
    await tester.drag(find.byType(Slider), const Offset(50, 0));
    await tester.pump();
    expect(find.textContaining(RegExp(r'2[1-9]°C')), findsOneWidget);
  });
}
