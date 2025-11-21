import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'device_service.dart';
import 'storage_service.dart';
import 'api_service.dart';

/// Auth Service for device-based guest authentication
class AuthService {
  static const String _userKey = 'user_data';

  /// Initialize device authentication
  /// This should be called on app startup
  static Future<Map<String, dynamic>> initializeDeviceAuth() async {
    try {
      // Initialize device service
      await DeviceService.instance.initialize();

      // Check if we have a valid session
      final isValid = await StorageService.isTokenValid();
      if (isValid) {
        // Try to restore session
        final deviceId = await StorageService.getStoredDeviceId();
        if (deviceId != null) {
          return await restoreDeviceSession(deviceId: deviceId);
        }
      }

      // Start new device authentication
      return await startDeviceAuth();
    } catch (e) {
      return {
        'success': false,
        'error': 'initialization_error',
        'message': 'Failed to initialize authentication: $e',
      };
    }
  }

  /// Start device authentication (first launch or new device)
  static Future<Map<String, dynamic>> startDeviceAuth() async {
    try {
      final deviceService = DeviceService.instance;
      await deviceService.initialize();

      final deviceId = await StorageService.getStoredDeviceId();
      final deviceFingerprint = await deviceService.getDeviceFingerprint();
      final installerId = await deviceService.getInstallerId();
      final deviceMetadata = await deviceService.getDeviceMetadata();

      final result = await ApiService.authDeviceStart(
        deviceId: deviceId,
        deviceFingerprint: deviceFingerprint,
        installerId: installerId,
        deviceMetadata: deviceMetadata,
      );

      if (result['success'] == true) {
        // Store device ID if provided
        if (result['device_id'] != null) {
          await deviceService.storeDeviceId(result['device_id']);
        }

        // Load user profile
        final userProfile = await ApiService.getMe();
        if (userProfile['success'] == true && userProfile['profile'] != null) {
          final profile = userProfile['profile'];
          final user = User(
            id: profile['id'] ?? result['user_id'] ?? '',
            email: profile['email'] ?? '',
            name: profile['name'] ?? 'Guest User',
            phoneNumber: profile['phone'],
            createdAt: profile['created_at'] != null
                ? DateTime.parse(profile['created_at'])
                : DateTime.now(),
            lastLoginAt: DateTime.now(),
            isEmailVerified: profile['email_verified'] ?? false,
          );
          await storeUser(user);
        }
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'auth_error',
        'message': 'Failed to start device authentication: $e',
      };
    }
  }

  /// Restore device session (subsequent launches)
  static Future<Map<String, dynamic>> restoreDeviceSession({
    required String deviceId,
  }) async {
    try {
      final deviceService = DeviceService.instance;
      await deviceService.initialize();

      final deviceFingerprint = await deviceService.getDeviceFingerprint();
      final installerId = await deviceService.getInstallerId();
      final deviceMetadata = await deviceService.getDeviceMetadata();

      final result = await ApiService.authDeviceStart(
        deviceId: deviceId,
        deviceFingerprint: deviceFingerprint,
        installerId: installerId,
        deviceMetadata: deviceMetadata,
      );

      if (result['success'] == true) {
        // Load user profile
        final userProfile = await ApiService.getMe();
        if (userProfile['success'] == true && userProfile['profile'] != null) {
          final profile = userProfile['profile'];
          final user = User(
            id: profile['id'] ?? result['user_id'] ?? '',
            email: profile['email'] ?? '',
            name: profile['name'] ?? 'Guest User',
            phoneNumber: profile['phone'],
            createdAt: profile['created_at'] != null
                ? DateTime.parse(profile['created_at'])
                : DateTime.now(),
            lastLoginAt: DateTime.now(),
            isEmailVerified: profile['email_verified'] ?? false,
          );
          await storeUser(user);
        }
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'restore_error',
        'message': 'Failed to restore session: $e',
      };
    }
  }

  /// Get stored token (for backward compatibility)
  static Future<String?> getToken() async {
    return await StorageService.getAccessToken();
  }

  /// Get stored user
  static Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Store auth data
  static Future<void> storeAuthData(String token, User user) async {
    await StorageService.saveSession(
      accessToken: token,
      refreshToken: '', // Not used in device auth
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      userId: user.id,
    );
    await storeUser(user);
  }

  /// Store user
  static Future<void> storeUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Clear auth data
  static Future<void> clearAuthData() async {
    await StorageService.clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final isValid = await StorageService.isTokenValid();
    return token != null && token.isNotEmpty && isValid;
  }

  /// Logout
  static Future<void> logout() async {
    await clearAuthData();
    // Note: We don't clear device_id to allow re-authentication
  }

  /// Get current user profile from backend
  static Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final result = await ApiService.getMe();
      if (result['success'] == true && result['profile'] != null) {
        final profile = result['profile'];
        final user = User(
          id: profile['id'] ?? '',
          email: profile['email'] ?? '',
          name: profile['name'] ?? 'Guest User',
          phoneNumber: profile['phone'],
          createdAt: profile['created_at'] != null
              ? DateTime.parse(profile['created_at'])
              : DateTime.now(),
          lastLoginAt: DateTime.now(),
          isEmailVerified: profile['email_verified'] ?? false,
        );
        await storeUser(user);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===== LEGACY METHODS (for backward compatibility) =====
  // These methods are kept for compatibility but may not work with device-based auth

  /// Legacy: Sign up (not used in device-based auth)
  static Future<AuthResponse> signup(SignupRequest request) async {
    return AuthResponse(
      success: false,
      message: 'Device-based authentication is used. No signup required.',
    );
  }

  /// Legacy: Login (not used in device-based auth)
  static Future<AuthResponse> login(LoginRequest request) async {
    return AuthResponse(
      success: false,
      message: 'Device-based authentication is used. Use initializeDeviceAuth() instead.',
    );
  }

  /// Legacy: Update profile
  static Future<AuthResponse> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    // This would need to be implemented if the backend supports profile updates
    return AuthResponse(
      success: false,
      message: 'Profile update not yet implemented for device-based auth',
    );
  }

  /// Legacy: Change password (not applicable for device-based auth)
  static Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return AuthResponse(
      success: false,
      message: 'Password change not applicable for device-based authentication',
    );
  }

  /// Legacy: Forgot password (not applicable for device-based auth)
  static Future<AuthResponse> forgotPassword(String email) async {
    return AuthResponse(
      success: false,
      message: 'Password reset not applicable for device-based authentication',
    );
  }
}