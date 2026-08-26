import 'package:flutter/widgets.dart';

/// Shared layout breakpoints for phone / tablet / wide Chrome demos.
abstract final class Breakpoints {
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phone;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= phone && w < desktop;
  }

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktop) return 720;
    if (w >= tablet) return 640;
    return 480;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 360) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    }
    if (w < phone) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.all(24);
  }
}
