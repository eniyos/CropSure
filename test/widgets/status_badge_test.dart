import 'package:cropsure/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StatusBadge exposes label semantics and tone icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(
            label: 'Critical',
            tone: StatusBadgeTone.error,
          ),
        ),
      ),
    );

    expect(find.text('Critical'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Critical')),
      matchesSemantics(label: 'Critical'),
    );
  });
}
