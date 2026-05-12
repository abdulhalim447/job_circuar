import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityProvider() {
    _checkInitialStatus();
    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateStatus(results);
    });
  }

  Future<void> _checkInitialStatus() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // If results contains anything other than none, we are online
    bool online = results.any((result) => result != ConnectivityResult.none);

    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
      debugPrint('🌐 Connectivity Changed: ${online ? "ONLINE" : "OFFLINE"}');
    }
  }

  /// Manually set status (e.g., from ApiService on timeout)
  void setOnlineStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }

  Future<void> retryConnection() async {
    await _checkInitialStatus();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
