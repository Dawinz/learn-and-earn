import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Service for managing device identification and fingerprinting
class DeviceService {
  static const String _deviceIdKey = 'device_id';
  static const String _deviceFingerprintKey = 'device_fingerprint';
  static const String _installerIdKey = 'installer_id';

  static DeviceService? _instance;
  static DeviceService get instance => _instance ??= DeviceService._();
  DeviceService._();

  String? _deviceId;
  String? _deviceFingerprint;
  String? _installerId;
  PackageInfo? _packageInfo;

  /// Initialize device service
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      await _loadStoredDeviceInfo();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing device service: $e');
      }
    }
  }

  /// Load stored device information
  Future<void> _loadStoredDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_deviceIdKey);
    _deviceFingerprint = prefs.getString(_deviceFingerprintKey);
    _installerId = prefs.getString(_installerIdKey);
  }

  /// Get or generate device ID
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_deviceIdKey);

    if (_deviceId == null) {
      // Generate a new device ID (UUID v4 format)
      _deviceId = _generateUUID();
      await prefs.setString(_deviceIdKey, _deviceId!);
    }

    return _deviceId!;
  }

  /// Get or generate device fingerprint
  Future<String> getDeviceFingerprint() async {
    if (_deviceFingerprint != null) return _deviceFingerprint!;

    final prefs = await SharedPreferences.getInstance();
    _deviceFingerprint = prefs.getString(_deviceFingerprintKey);

    if (_deviceFingerprint == null) {
      // Generate device fingerprint based on device characteristics
      _deviceFingerprint = await _generateDeviceFingerprint();
      await prefs.setString(_deviceFingerprintKey, _deviceFingerprint!);
    }

    return _deviceFingerprint!;
  }

  /// Get or generate installer ID
  Future<String> getInstallerId() async {
    if (_installerId != null) return _installerId!;

    final prefs = await SharedPreferences.getInstance();
    _installerId = prefs.getString(_installerIdKey);

    if (_installerId == null) {
      // Generate installer ID (can be used to track app installation source)
      _installerId = _generateUUID();
      await prefs.setString(_installerIdKey, _installerId!);
    }

    return _installerId!;
  }

  /// Store device ID (after receiving from backend)
  Future<void> storeDeviceId(String deviceId) async {
    _deviceId = deviceId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, deviceId);
  }

  /// Generate device fingerprint based on device characteristics
  Future<String> _generateDeviceFingerprint() async {
    final components = <String>[];

    // Platform
    components.add(Platform.operatingSystem);
    components.add(Platform.operatingSystemVersion);

    // App info
    if (_packageInfo != null) {
      components.add(_packageInfo!.packageName);
      components.add(_packageInfo!.version);
      components.add(_packageInfo!.buildNumber);
    }

    // Device ID (if available)
    final deviceId = await getDeviceId();
    components.add(deviceId);

    // Create a hash of all components
    final combined = components.join('|');
    return _hashString(combined);
  }

  /// Get device metadata for API requests
  Future<Map<String, dynamic>> getDeviceMetadata() async {
    await initialize();

    return {
      'platform': Platform.isIOS ? 'ios' : 'android',
      'os_version': Platform.operatingSystemVersion,
      'app_version': _packageInfo?.version ?? 'unknown',
      'is_emulator': _isEmulator(),
      'is_rooted': false, // TODO: Implement root/jailbreak detection if needed
    };
  }

  /// Check if running on emulator (basic detection)
  bool _isEmulator() {
    if (kDebugMode) {
      // In debug mode, assume it might be an emulator
      // You can enhance this with device_info_plus package
      return false;
    }
    return false;
  }

  /// Generate UUID v4
  String _generateUUID() {
    final random = Random();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));

    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant 10

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Simple string hashing (for fingerprint) using SHA-256
  String _hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Clear all device data (for testing/logout)
  Future<void> clearDeviceData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    await prefs.remove(_deviceFingerprintKey);
    await prefs.remove(_installerIdKey);
    _deviceId = null;
    _deviceFingerprint = null;
    _installerId = null;
  }
}
