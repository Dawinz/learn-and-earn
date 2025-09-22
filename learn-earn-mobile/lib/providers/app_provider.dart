import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/earning.dart';
import '../models/payout.dart';
import '../services/api_service.dart';
import '../utils/crypto.dart';
import '../utils/device_detection.dart';

class AppProvider with ChangeNotifier {
  User? _user;
  List<Earning> _earnings = [];
  List<Payout> _payouts = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  User? get user => _user;
  List<Earning> get earnings => _earnings;
  List<Payout> get payouts => _payouts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  // Computed properties
  int get totalCoins =>
      _earnings.fold(0, (sum, earning) => sum + earning.coins);
  double get totalUsd =>
      _earnings.fold(0.0, (sum, earning) => sum + earning.usd);
  int get todayCoins {
    final today = DateTime.now();
    return _earnings
        .where(
          (earning) =>
              earning.createdAt.year == today.year &&
              earning.createdAt.month == today.month &&
              earning.createdAt.day == today.day,
        )
        .fold(0, (sum, earning) => sum + earning.coins);
  }

  bool get hasMobileNumber => _user?.hasMobileNumber ?? false;
  bool get isNumberLocked => _user?.isNumberLocked ?? false;
  bool get isEmulator => _user?.isEmulator ?? false;

  /// Initialize the app
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      await _loadStoredCredentials();

      if (_user == null) {
        await _createDeviceIdentity();
      } else {
        await _loadUserData();
      }

      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize app: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load stored device credentials
  Future<void> _loadStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_id');
    final publicKey = prefs.getString('public_key');
    final privateKey = prefs.getString('private_key');

    if (deviceId != null && publicKey != null && privateKey != null) {
      ApiService.setDeviceCredentials(deviceId, publicKey, privateKey);
    }
  }

  /// Create new device identity
  Future<void> _createDeviceIdentity() async {
    try {
      final deviceIdentity = CryptoUtils.generateDeviceIdentity();
      final isEmulator = await DeviceDetection.isEmulator();

      // Store credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_id', deviceIdentity.deviceId);
      await prefs.setString('public_key', deviceIdentity.publicKey);
      await prefs.setString('private_key', deviceIdentity.privateKey);

      // Set API credentials
      ApiService.setDeviceCredentials(
        deviceIdentity.deviceId,
        deviceIdentity.publicKey,
        deviceIdentity.privateKey,
      );

      // Register with backend
      _user = await ApiService.registerDevice(
        deviceIdentity.publicKey,
        isEmulator: isEmulator,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to create device identity: $e');
    }
  }

  /// Load user data from backend
  Future<void> _loadUserData() async {
    try {
      _user = await ApiService.getUserProfile();
      await _loadEarnings();
      await _loadPayouts();
    } catch (e) {
      _setError('Failed to load user data: $e');
    }
  }

  /// Load earnings history
  Future<void> _loadEarnings() async {
    try {
      _earnings = await ApiService.getEarningsHistory();
      notifyListeners();
    } catch (e) {
      print('Failed to load earnings: $e');
    }
  }

  /// Load payout history
  Future<void> _loadPayouts() async {
    try {
      _payouts = await ApiService.getPayoutHistory();
      notifyListeners();
    } catch (e) {
      print('Failed to load payouts: $e');
    }
  }

  /// Set mobile money number
  Future<void> setMobileMoneyNumber(String mobileNumber) async {
    _setLoading(true);
    try {
      await ApiService.setMobileMoneyNumber(mobileNumber);
      await _loadUserData(); // Refresh user data
    } catch (e) {
      _setError('Failed to set mobile number: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Record an earning
  Future<void> recordEarning({
    required EarningSource source,
    String? lessonId,
    String? adSlotId,
  }) async {
    try {
      final earning = await ApiService.recordEarning(
        source: source,
        lessonId: lessonId,
        adSlotId: adSlotId,
      );

      _earnings.insert(0, earning);
      notifyListeners();
    } catch (e) {
      _setError('Failed to record earning: $e');
    }
  }

  /// Request a payout
  Future<void> requestPayout(double amountUsd) async {
    _setLoading(true);
    try {
      final payout = await ApiService.requestPayout(amountUsd);
      _payouts.insert(0, payout);
      notifyListeners();
    } catch (e) {
      _setError('Failed to request payout: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    if (_user != null) {
      await _loadUserData();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset app (for testing)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _user = null;
    _earnings = [];
    _payouts = [];
    _isInitialized = false;
    _error = null;

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
