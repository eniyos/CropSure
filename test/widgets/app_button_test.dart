import 'package:cropsure/widgets/app_button.dart';
import 'package:cropsure/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppButton shows label and invokes callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    expect(tapped, isTrue);
  });

  testWidgets('StatusBadge renders label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(label: 'Healthy', tone: StatusBadgeTone.success),
        ),
      ),
    );
    expect(find.text('Healthy'), findsOneWidget);
  });
}
