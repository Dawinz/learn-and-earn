import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'https://learn-and-earn-04ok.onrender.com/api';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user
  static Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Store auth data
  static Future<void> storeAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Clear auth data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Sign up
  static Future<AuthResponse> signup(SignupRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );


      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success &&
          authResponse.token != null &&
          authResponse.user != null) {
        await storeAuthData(authResponse.token!, authResponse.user!);
      }

      return authResponse;
    } catch (e) {
      print('Signup error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Login
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );


      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success &&
          authResponse.token != null &&
          authResponse.user != null) {
        await storeAuthData(authResponse.token!, authResponse.user!);
      }

      return authResponse;
    } catch (e) {
      print('Login error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await clearAuthData();
    }
  }

  // Get current user profile
  static Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        await storeAuthData(token, user);
        return user;
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // Update user profile
  static Future<AuthResponse> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResponse(success: false, message: 'Not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.user != null) {
        await storeAuthData(token, authResponse.user!);
      }

      return authResponse;
    } catch (e) {
      print('Update profile error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Change password
  static Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResponse(success: false, message: 'Not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      print('Change password error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Forgot password
  static Future<AuthResponse> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      print('Forgot password error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}
