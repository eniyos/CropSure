import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks device connectivity and optional demo force-offline mode.
class ConnectivityController extends ChangeNotifier {
  ConnectivityController({
    Connectivity? connectivity,
    bool skipPlatform = false,
  })  : _connectivity = connectivity ?? Connectivity(),
        _skipPlatform = skipPlatform;

  final Connectivity _connectivity;
  final bool _skipPlatform;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _hasNetwork = true;
  bool _forceOffline = false;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  bool get hasNetwork => _hasNetwork;
  bool get forceOffline => _forceOffline;

  /// Effective online state used by offline-aware repositories.
  bool get isOnline => _hasNetwork && !_forceOffline;

  bool get isOffline => !isOnline;

  Future<void> start() async {
    if (_skipPlatform) {
      _initialized = true;
      notifyListeners();
      return;
    }

    try {
      final results = await _connectivity.checkConnectivity();
      _apply(results);
      _subscription ??=
          _connectivity.onConnectivityChanged.listen(_apply);
    } catch (_) {
      // Unit/widget tests and some hosts have no connectivity plugin.
      _hasNetwork = true;
    }
    _initialized = true;
    notifyListeners();
  }

  void _apply(List<ConnectivityResult> results) {
    final online = results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn ||
          r == ConnectivityResult.other,
    );
    if (online == _hasNetwork) return;
    _hasNetwork = online;
    notifyListeners();
  }

  /// Demo toggle for Chrome / always-online environments.
  void setForceOffline(bool value) {
    if (_forceOffline == value) return;
    _forceOffline = value;
    notifyListeners();
  }

  void toggleForceOffline() => setForceOffline(!_forceOffline);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
