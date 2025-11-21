import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VersionInfo {
  final String minimumVersion;
  final int minimumBuildNumber;
  final String latestVersion;
  final int latestBuildNumber;
  final bool forceUpdate;
  final String updateMessage;
  final String updateTitle;
  final String androidDownloadUrl;
  final String iosDownloadUrl;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final Map<String, dynamic> features;

  VersionInfo({
    required this.minimumVersion,
    required this.minimumBuildNumber,
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.forceUpdate,
    required this.updateMessage,
    required this.updateTitle,
    required this.androidDownloadUrl,
    required this.iosDownloadUrl,
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.features,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      minimumVersion: json['minimumVersion'] ?? '1.0.0',
      minimumBuildNumber: json['minimumBuildNumber'] ?? 1,
      latestVersion: json['latestVersion'] ?? '1.0.0',
      latestBuildNumber: json['latestBuildNumber'] ?? 1,
      forceUpdate: json['forceUpdate'] ?? false,
      updateMessage: json['updateMessage'] ?? 'A new version is available.',
      updateTitle: json['updateTitle'] ?? 'Update Available',
      androidDownloadUrl: json['androidDownloadUrl'] ?? '',
      iosDownloadUrl: json['iosDownloadUrl'] ?? '',
      maintenanceMode: json['maintenanceMode'] ?? false,
      maintenanceMessage:
          json['maintenanceMessage'] ?? 'App is under maintenance.',
      features: json['features'] ?? {},
    );
  }
}

class VersionService {
  static VersionService? _instance;
  static VersionService get instance => _instance ??= VersionService._();
  VersionService._();

  static const String _baseUrl =
      'https://learn-and-earn-04ok.onrender.com/api/version';

  PackageInfo? _packageInfo;
  VersionInfo? _versionInfo;

  // Initialize version service
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      if (kDebugMode) {
        print('App Version: ${_packageInfo!.version}');
        print('Build Number: ${_packageInfo!.buildNumber}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get package info: $e');
      }
    }
  }

  // Get current app version
  String get currentVersion => _packageInfo?.version ?? '1.0.0';
  int get currentBuildNumber =>
      int.tryParse(_packageInfo?.buildNumber ?? '1') ?? 1;

  // Check for updates
  Future<VersionCheckResult> checkForUpdates() async {
    try {
      final response = await http
          .get(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _versionInfo = VersionInfo.fromJson(data['data']);
          return _analyzeVersion();
        }
      }

      return VersionCheckResult(
        needsUpdate: false,
        forceUpdate: false,
        maintenanceMode: false,
        versionInfo: null,
        error: 'Failed to check version: ${response.statusCode}',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Version check error: $e');
      }
      return VersionCheckResult(
        needsUpdate: false,
        forceUpdate: false,
        maintenanceMode: false,
        versionInfo: null,
        error: 'Network error: $e',
      );
    }
  }

  // Analyze version requirements
  VersionCheckResult _analyzeVersion() {
    if (_versionInfo == null) {
      return VersionCheckResult(
        needsUpdate: false,
        forceUpdate: false,
        maintenanceMode: false,
        versionInfo: null,
        error: 'No version info available',
      );
    }

    // Check maintenance mode
    if (_versionInfo!.maintenanceMode) {
      return VersionCheckResult(
        needsUpdate: false,
        forceUpdate: false,
        maintenanceMode: true,
        versionInfo: _versionInfo,
        error: _versionInfo!.maintenanceMessage,
      );
    }

    // Check if force update is required
    if (_versionInfo!.forceUpdate) {
      return VersionCheckResult(
        needsUpdate: true,
        forceUpdate: true,
        maintenanceMode: false,
        versionInfo: _versionInfo,
        error: null,
      );
    }

    // Check minimum version requirement
    final currentVersion = this.currentVersion;
    final minimumVersion = _versionInfo!.minimumVersion;
    final currentBuild = this.currentBuildNumber;
    final minimumBuild = _versionInfo!.minimumBuildNumber;

    // Simple version comparison (you might want to use a proper version comparison library)
    final needsUpdate =
        _compareVersions(currentVersion, minimumVersion) < 0 ||
        currentBuild < minimumBuild;

    return VersionCheckResult(
      needsUpdate: needsUpdate,
      forceUpdate: needsUpdate,
      maintenanceMode: false,
      versionInfo: _versionInfo,
      error: null,
    );
  }

  // Simple version comparison
  int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final v1Part = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Part = i < v2Parts.length ? v2Parts[i] : 0;

      if (v1Part < v2Part) return -1;
      if (v1Part > v2Part) return 1;
    }

    return 0;
  }

  // Get download URL for current platform
  String getDownloadUrl() {
    if (_versionInfo == null) return '';

    if (Platform.isAndroid) {
      return _versionInfo!.androidDownloadUrl;
    } else if (Platform.isIOS) {
      return _versionInfo!.iosDownloadUrl;
    }

    return '';
  }

  // Check if a feature is enabled
  bool isFeatureEnabled(String featureName) {
    if (_versionInfo?.features == null) return true;
    return _versionInfo!.features[featureName] ?? true;
  }
}

class VersionCheckResult {
  final bool needsUpdate;
  final bool forceUpdate;
  final bool maintenanceMode;
  final VersionInfo? versionInfo;
  final String? error;

  VersionCheckResult({
    required this.needsUpdate,
    required this.forceUpdate,
    required this.maintenanceMode,
    required this.versionInfo,
    required this.error,
  });
}
