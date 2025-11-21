import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Service for linking email to device-based account using OTP
class EmailLinkingService {
  /// Send OTP to email for verification
  static Future<Map<String, dynamic>> sendOtp({
    required String email,
    String? referralCode,
  }) async {
    try {
      // Use Supabase Auth SDK to send OTP directly
      // signInWithOtp returns void, so if it completes without exception, it succeeded
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null, // No redirect needed for mobile app
        shouldCreateUser: true, // Allow creating user if doesn't exist
      );

      // If referral code is provided, we can store it temporarily
      // The referral will be claimed after email verification
      // (handled in email_verification_screen.dart after OTP verification)

      // If we reach here, OTP was sent successfully
      return {
        'success': true,
        'message': 'Verification code sent to your email. Please check your inbox (and spam folder).',
      };
    } on AuthException catch (e) {
      // Log the error for debugging
      print('Email OTP Error: ${e.message}');
      return {
        'success': false,
        'error': 'auth_error',
        'message': e.message.isNotEmpty 
            ? e.message 
            : 'Failed to send verification code. Please check your email and try again.',
      };
    } catch (e) {
      // Log the error for debugging
      print('Email OTP Network Error: $e');
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e. Please check your internet connection and try again.',
      };
    }
  }

  /// Verify OTP and link email to account
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      // Verify OTP using Supabase Auth SDK
      final response = await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: otpCode.trim(),
        type: OtpType.email,
      );

      if (response.user != null && response.session != null) {
        // OTP is verified, but we need to link the email to the device-based user
        // Get the current device-based user ID
        final deviceUserId = await StorageService.getUserId();
        
        if (deviceUserId != null) {
          // Update the device-based user's email in users_public table
          // Use the device session (not the email OTP session) to update
          final updateResult = await _linkEmailToDeviceUser(
            deviceUserId: deviceUserId,
            email: email,
          );

          if (updateResult['success'] == true) {
            // Email successfully linked to device user
            // Note: We don't use the email session - we keep using the device session
            return {
              'success': true,
              'message': 'Email successfully linked to your account',
              'profileUpdated': true,
            };
          } else {
            // OTP verified but failed to link email
            return {
              'success': false,
              'error': 'linking_failed',
              'message': updateResult['message'] ?? 'Email verified but failed to link to account',
            };
          }
        } else {
          // No device user found - this shouldn't happen
          return {
            'success': false,
            'error': 'no_device_user',
            'message': 'Device session not found. Please restart the app.',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'verification_failed',
          'message': 'Failed to verify OTP',
        };
      }
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': 'auth_error',
        'message': e.message.isNotEmpty ? e.message : 'Authentication error occurred',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'verification_error',
        'message': 'Failed to verify OTP: $e',
      };
    }
  }

  /// Link email to device-based user account
  static Future<Map<String, dynamic>> _linkEmailToDeviceUser({
    required String deviceUserId,
    required String email,
  }) async {
    try {
      // Verify device session exists
      final deviceAccessToken = await StorageService.getAccessToken();
      
      if (deviceAccessToken == null) {
        return {
          'success': false,
          'error': 'no_device_session',
          'message': 'Device session not found',
        };
      }

      // Use API call to update email
      // ApiService.updateUserEmail() uses _getAuthHeaders() which gets the token from StorageService
      // This ensures we're updating the device user (stored in storage), not the email user (in Supabase client)
      final result = await ApiService.updateUserEmail(email: email);
      
      if (result['success'] == true) {
        return {
          'success': true,
          'message': 'Email linked successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'update_failed',
          'message': result['message'] ?? 'Failed to update user email',
        };
      }
    } catch (e) {
      print('Error linking email to device user: $e');
      return {
        'success': false,
        'error': 'update_error',
        'message': 'Failed to link email: $e',
      };
    }
  }

  /// Check if email is already linked
  static Future<bool> isEmailLinked(String email) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      return user?.email == email;
    } catch (e) {
      return false;
    }
  }

  /// Get current user's email (if linked)
  static String? getLinkedEmail() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      return user?.email;
    } catch (e) {
      return null;
    }
  }
}

