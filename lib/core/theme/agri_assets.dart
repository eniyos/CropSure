import 'package:flutter/painting.dart';

/// Curated agricultural imagery for CropSure surfaces.
///
/// All scenes are **local assets** (no Unsplash). The tractor sunset
/// ([signupFieldSunset]) is reserved for the signup/register screen only.
abstract final class AgriAssets {
  /// Golden wheat field at dusk — splash / dashboard heroes.
  static const String dawnField = 'assets/images/dawn_field.jpg';

  /// Lush green crop rows — login / canopy scenes.
  static const String greenCanopy = 'assets/images/green_canopy.jpg';

  /// Close farm soil / foliage work.
  static const String soilHands = 'assets/images/soil_hands.jpg';

  /// Fresh field produce / morning crops.
  static const String mistMorning = 'assets/images/mist_morning.jpg';

  /// Harvest bounty.
  static const String harvest = 'assets/images/harvest.jpg';

  /// Tech-in-field energy (shared green canopy).
  static const String smartFarm = greenCanopy;

  /// Leaf / foliage macro accents.
  static const String leafMacro = soilHands;

  /// Local signup-only hero — tractor at sunset. Do not reuse elsewhere.
  static const String signupFieldSunset =
      'assets/images/signup_field_sunset.jpg';

  static const List<String> collage = [
    greenCanopy,
    soilHands,
    harvest,
    mistMorning,
  ];

  static bool isAssetPath(String path) => path.startsWith('assets/');

  static bool hasImage(String path) => path.trim().isNotEmpty;

  static ImageProvider? imageProviderOrNull(String path) {
    if (!hasImage(path)) return null;
    if (isAssetPath(path)) return AssetImage(path);
    return NetworkImage(path);
  }
}
