import 'dart:convert';

import '../../models/crop_batch.dart';
import '../../models/farm.dart';
import '../storage/preferences_service.dart';

/// JSON cache for list/detail payloads shown when offline.
class CacheStore {
  CacheStore(this._prefs);

  final PreferencesService _prefs;

  static const _farmsKey = 'cache.farms.v1';
  static const _farmsAtKey = 'cache.farms.at.v1';
  static const _cropsKey = 'cache.crops.v1';
  static const _cropsAtKey = 'cache.crops.at.v1';

  DateTime? get farmsCachedAt => _readAt(_farmsAtKey);
  DateTime? get cropsCachedAt => _readAt(_cropsAtKey);

  bool get hasFarmsCache => _prefs.getString(_farmsKey) != null;
  bool get hasCropsCache => _prefs.getString(_cropsKey) != null;

  Future<void> saveFarms(List<Farm> farms) async {
    final encoded = jsonEncode(farms.map((f) => f.toJson()).toList());
    await _prefs.setString(_farmsKey, encoded);
    await _prefs.setString(_farmsAtKey, DateTime.now().toIso8601String());
  }

  List<Farm>? readFarms() {
    final raw = _prefs.getString(_farmsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Farm.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCrops(List<CropBatch> crops) async {
    final encoded = jsonEncode(crops.map((c) => c.toJson()).toList());
    await _prefs.setString(_cropsKey, encoded);
    await _prefs.setString(_cropsAtKey, DateTime.now().toIso8601String());
  }

  List<CropBatch>? readCrops() {
    final raw = _prefs.getString(_cropsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CropBatch.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _prefs.remove(_farmsKey);
    await _prefs.remove(_farmsAtKey);
    await _prefs.remove(_cropsKey);
    await _prefs.remove(_cropsAtKey);
  }

  DateTime? _readAt(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}
