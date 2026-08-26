import 'package:flutter/material.dart';

/// CropSure visual identity — premium agri: deep leaf, sky mist, harvest gold.
abstract final class AppColors {
  // Brand
  static const Color leaf = Color(0xFF1A6B3C);
  static const Color leafDeep = Color(0xFF0E3F24);
  static const Color leafBright = Color(0xFF2F9E5B);
  static const Color harvest = Color(0xFFD4A017);
  static const Color skyMist = Color(0xFFF3F7F2);
  static const Color ink = Color(0xFF0C1A14);

  static const Color green600 = leaf;
  static const Color green700 = leafDeep;
  static const Color green500 = leafBright;
  static const Color green50 = Color(0xFFE8F5EC);

  static const Color neutral900 = ink;
  static const Color neutral700 = Color(0xFF3D4F44);
  static const Color neutral500 = Color(0xFF6B7C72);
  static const Color neutral300 = Color(0xFFC5CFC8);
  static const Color neutral200 = Color(0xFFDCE4DE);
  static const Color neutral100 = Color(0xFFEEF3EF);
  static const Color white = Color(0xFFFFFFFF);

  static const Color primary = leaf;
  static const Color primaryDark = leafDeep;
  static const Color primaryLight = leafBright;
  static const Color secondary = leafDeep;
  static const Color accent = harvest;

  // Legacy aliases
  static const Color cream = skyMist;
  static const Color dark = ink;
  static const Color forest = leaf;
  static const Color sage = leafBright;
  static const Color terracotta = Color(0xFFC45C26);

  static const Color background = skyMist;
  static const Color surface = white;
  static const Color surfaceGlass = Color(0xE6FFFFFF);
  static const Color surfaceMuted = neutral100;
  static const Color outline = Color(0x331A6B3C);
  static const Color outlineStrong = Color(0x4D0C1A14);

  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0x993D4F44);
  static const Color textOnPrimary = white;
  static const Color textDisabled = Color(0x666B7C72);

  static const Color success = leaf;
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFC23030);
  static const Color info = Color(0xFF1B6B8A);

  static const Color severityHealthy = leaf;
  static const Color severityMild = leafBright;
  static const Color severityModerate = Color(0xFFD97706);
  static const Color severitySevere = Color(0xFFC45C26);
  static const Color severityCritical = Color(0xFF9F1239);

  static const Color trustHigh = leaf;
  static const Color trustMedium = Color(0xFFD97706);
  static const Color trustLow = Color(0xFFC23030);

  static Color greenWash([double opacity = 0.12]) =>
      leaf.withValues(alpha: opacity);
}
