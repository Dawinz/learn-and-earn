import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    // Check initial connectivity status
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectivityStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity
          .checkConnectivity();
      _updateConnectivityStatus(results);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      _isConnected = false;
      notifyListeners();
    }
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    bool wasConnected = _isConnected;

    // Check if any of the connectivity results indicate internet access
    _isConnected = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn ||
          result == ConnectivityResult.bluetooth ||
          result == ConnectivityResult.other,
    );

    // Only notify listeners if the connectivity status actually changed
    if (wasConnected != _isConnected) {
      notifyListeners();
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final List<ConnectivityResult> results = await _connectivity
          .checkConnectivity();
      return results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet ||
            result == ConnectivityResult.vpn ||
            result == ConnectivityResult.bluetooth ||
            result == ConnectivityResult.other,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error checking internet connection: $e');
      }
      return false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
