import 'dart:convert';

import '../../models/sync_operation.dart';
import '../storage/preferences_service.dart';

/// Persists the offline mutation queue across restarts.
class SyncQueueStore {
  SyncQueueStore(this._prefs);

  final PreferencesService _prefs;
  static const _key = 'sync.queue.v1';

  List<SyncOperation> readAll() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => SyncOperation.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeAll(List<SyncOperation> ops) async {
    final encoded = jsonEncode(ops.map((o) => o.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }

  Future<void> clear() => _prefs.remove(_key);
}
