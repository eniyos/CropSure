import 'package:cropsure/core/theme/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Breakpoints detect phone vs wide widths', (tester) async {
    late bool phone;
    late bool wide;
    late double maxWidth;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: Builder(
          builder: (context) {
            phone = Breakpoints.isPhone(context);
            wide = Breakpoints.isWide(context);
            maxWidth = Breakpoints.contentMaxWidth(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(phone, isTrue);
    expect(wide, isFalse);
    expect(maxWidth, 480);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1280, 800)),
        child: Builder(
          builder: (context) {
            phone = Breakpoints.isPhone(context);
            wide = Breakpoints.isWide(context);
            maxWidth = Breakpoints.contentMaxWidth(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(phone, isFalse);
    expect(wide, isTrue);
    expect(maxWidth, 720);
  });
}
