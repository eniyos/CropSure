import 'package:cropsure/core/theme/agri_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('signup sunset asset resolves and paints', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Image.asset(
            AgriAssets.signupFieldSunset,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsOneWidget);
  });
}
