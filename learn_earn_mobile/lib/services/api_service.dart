import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../models/lesson.dart';
import '../models/transaction.dart';
import 'storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// API Service for communicating with Supabase backend
class ApiService {
  static const String baseUrl = AppConstants.SUPABASE_BASE_URL;
  static const String _anonKey = AppConstants.SUPABASE_ANON_KEY;

  /// Get authentication headers
  static Future<Map<String, String>> _getAuthHeaders({
    bool includeIdempotencyKey = false,
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'apikey': _anonKey,
    };

    // Try to get token from Supabase session first
    String? accessToken;
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        accessToken = session.accessToken;
      }
    } catch (e) {
      // Fallback to stored token
      accessToken = await StorageService.getAccessToken();
    }

    // If still no token, try stored token
    if (accessToken == null) {
      accessToken = await StorageService.getAccessToken();
    }

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    if (includeIdempotencyKey && idempotencyKey != null) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    return headers;
  }

  /// Generate a new UUID for idempotency
  static String _generateIdempotencyKey() {
    return const Uuid().v4();
  }

  /// Handle API errors
  static Map<String, dynamic> _handleError(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      return {
        'error': errorData['error'] ?? 'unknown_error',
        'message': errorData['message'] ?? 'An error occurred',
        'code': errorData['code'],
        'details': errorData['details'],
      };
    } catch (e) {
      return {
        'error': 'parse_error',
        'message': 'Failed to parse error response',
      };
    }
  }

  // ===== DEVICE AUTHENTICATION =====

  /// Start device authentication (create/restore guest session)
  static Future<Map<String, dynamic>> authDeviceStart({
    String? deviceId,
    required String deviceFingerprint,
    String? installerId,
    required Map<String, dynamic> deviceMetadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth-device-start'),
        headers: {'Content-Type': 'application/json', 'apikey': _anonKey},
        body: jsonEncode({
          if (deviceId != null) 'device_id': deviceId,
          'device_fingerprint': deviceFingerprint,
          if (installerId != null) 'installer_id': installerId,
          'device_metadata': deviceMetadata,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Store session
        if (data['session'] != null) {
          final session = data['session'];
          await StorageService.saveSession(
            accessToken: session['access_token'],
            refreshToken: session['refresh_token'],
            expiresAt: DateTime.parse(session['expires_at']),
            userId: data['user_id'],
            deviceId: data['device_id'],
          );
        }

        return {
          'success': true,
          'session': data['session'],
          'user_id': data['user_id'],
          'is_new_user': data['is_new_user'] ?? false,
          'device_id': data['device_id'],
        };
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== USER PROFILE & XP =====

  /// Get user profile and XP balance
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Update user email in users_public table
  static Future<Map<String, dynamic>> updateUserEmail({
    required String email,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/me'),
        headers: headers,
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email updated successfully',
          ...jsonDecode(response.body),
        };
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Link email to user account using OTP
  /// Uses the existing /auth-otp endpoint to send OTP to email
  /// After OTP is verified with Supabase Auth SDK, email is automatically linked
  static Future<Map<String, dynamic>> linkEmail({
    required String email,
    String? referralCode,
  }) async {
    try {
      // Use /auth-otp endpoint (no auth required for sending OTP)
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/auth-otp'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          if (referralCode != null) 'referral_code': referralCode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Verification code sent to your email',
          ...jsonDecode(response.body),
        };
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== XP CREDIT (BATCHED) =====

  /// Credit XP in batches with idempotency
  static Future<Map<String, dynamic>> creditXp({
    required List<Map<String, dynamic>> events,
  }) async {
    try {
      final idempotencyKey = _generateIdempotencyKey();
      final headers = await _getAuthHeaders(
        includeIdempotencyKey: true,
        idempotencyKey: idempotencyKey,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/xp-credit'),
        headers: headers,
        body: jsonEncode({'events': events}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Get XP history with cursor pagination
  static Future<Map<String, dynamic>> getXpHistory({
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (cursor != null) 'cursor': cursor,
      };

      final response = await http.get(
        Uri.parse('$baseUrl/xp-history').replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== LESSONS =====

  /// Get published lessons
  static Future<Map<String, dynamic>> getLessons({
    int limit = 50,
    int offset = 0,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (category != null) 'category': category,
      };

      final response = await http.get(
        Uri.parse('$baseUrl/lessons').replace(queryParameters: queryParams),
        headers: {'Content-Type': 'application/json', 'apikey': _anonKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'lessons': (data['lessons'] as List)
              .map((json) => Lesson.fromJson(json))
              .toList(),
          'total': data['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'lessons': <Lesson>[],
          'total': 0,
          ..._handleError(response),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'lessons': <Lesson>[],
        'total': 0,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Update lesson progress
  static Future<Map<String, dynamic>> updateLessonProgress({
    required String lessonId,
    required double progressPercent,
    required int timeSpentSeconds,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/lessons-progress'),
        headers: headers,
        body: jsonEncode({
          'lesson_id': lessonId,
          'progress_percent': progressPercent,
          'time_spent_seconds': timeSpentSeconds,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Mark lesson as complete (idempotent, awards XP)
  /// For mobile app local lessons, include xp_reward so backend can award XP
  static Future<Map<String, dynamic>> completeLesson({
    required String lessonId,
    required int timeSpentSeconds,
    Map<String, dynamic>? metadata,
    int? xpReward, // XP reward for mobile app local lessons
  }) async {
    try {
      final idempotencyKey = _generateIdempotencyKey();
      final headers = await _getAuthHeaders(
        includeIdempotencyKey: true,
        idempotencyKey: idempotencyKey,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/lessons-complete'),
        headers: headers,
        body: jsonEncode({
          'lesson_id': lessonId,
          'time_spent_seconds': timeSpentSeconds,
          if (xpReward != null)
            'xp_reward': xpReward, // Send XP reward for mobile app lessons
          if (metadata != null) 'metadata': metadata,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== USER STATS =====

  /// Get user statistics (streak, daily login, achievements)
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user-stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Update user statistics
  static Future<Map<String, dynamic>> updateUserStats({
    int? learningStreak,
    String? lastStreakDate,
    String? lastDailyLoginDate,
    int? totalLessonsCompleted,
    int? totalQuizzesCompleted,
    int? totalAdViews,
    int? longestStreak,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{};

      if (learningStreak != null) body['learning_streak'] = learningStreak;
      if (lastStreakDate != null) body['last_streak_date'] = lastStreakDate;
      if (lastDailyLoginDate != null)
        body['last_daily_login_date'] = lastDailyLoginDate;
      if (totalLessonsCompleted != null)
        body['total_lessons_completed'] = totalLessonsCompleted;
      if (totalQuizzesCompleted != null)
        body['total_quizzes_completed'] = totalQuizzesCompleted;
      if (totalAdViews != null) body['total_ad_views'] = totalAdViews;
      if (longestStreak != null) body['longest_streak'] = longestStreak;

      final response = await http.put(
        Uri.parse('$baseUrl/user-stats'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Record daily login
  static Future<Map<String, dynamic>> recordDailyLogin({
    required int xpAwarded,
    required bool adWatched,
  }) async {
    try {
      final idempotencyKey = _generateIdempotencyKey();
      final headers = await _getAuthHeaders(
        includeIdempotencyKey: true,
        idempotencyKey: idempotencyKey,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/daily-login'),
        headers: headers,
        body: jsonEncode({'xp_awarded': xpAwarded, 'ad_watched': adWatched}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== QUIZ SUBMISSIONS =====

  /// Submit quiz results
  static Future<Map<String, dynamic>> submitQuiz({
    required String lessonId,
    required List<int> answers,
    int? timeSpentSeconds,
    String? quizId,
    int? correctAnswers,
    int? totalQuestions,
    int? xpReward,
  }) async {
    try {
      final idempotencyKey = _generateIdempotencyKey();
      final headers = await _getAuthHeaders(
        includeIdempotencyKey: true,
        idempotencyKey: idempotencyKey,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/quiz-submit'),
        headers: headers,
        body: jsonEncode({
          'lesson_id': lessonId,
          'quiz_id': quizId,
          'answers': answers,
          'correct_answers': correctAnswers,
          'total_questions': totalQuestions ?? answers.length,
          'time_spent_seconds': timeSpentSeconds ?? 0,
          if (xpReward != null) 'xp_reward': xpReward,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== ACHIEVEMENTS =====

  /// Get user achievements
  static Future<Map<String, dynamic>> getAchievements() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/achievements'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Unlock an achievement
  static Future<Map<String, dynamic>> unlockAchievement({
    required String achievementType,
    required String achievementName,
    int xpReward = 0,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/achievements'),
        headers: headers,
        body: jsonEncode({
          'achievement_type': achievementType,
          'achievement_name': achievementName,
          'xp_reward': xpReward,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== REFERRALS =====

  /// Get referral statistics
  static Future<Map<String, dynamic>> getReferrals() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/referrals'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Claim/record referral code
  static Future<Map<String, dynamic>> claimReferral({
    required String referralCode,
  }) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'auth_required',
          'message': 'User ID not found',
        };
      }

      final idempotencyKey = _generateIdempotencyKey();
      final headers = await _getAuthHeaders(
        includeIdempotencyKey: true,
        idempotencyKey: idempotencyKey,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/referral-signup'),
        headers: headers,
        body: jsonEncode({'user_id': userId, 'referral_code': referralCode}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== CONVERSION & WITHDRAWALS =====

  /// Get current XP to TZS conversion rate
  static Future<Map<String, dynamic>> getConversionRate() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/conversion-rate'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Get withdrawals (read-only for mobile)
  static Future<Map<String, dynamic>> getWithdrawals({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final response = await http.get(
        Uri.parse('$baseUrl/withdrawals').replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== SYSTEM ENDPOINTS =====

  /// Get API version and feature flags
  static Future<Map<String, dynamic>> getVersion() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/version'),
        headers: {'Content-Type': 'application/json', 'apikey': _anonKey},
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, ..._handleError(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  /// Health check
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json', 'apikey': _anonKey},
      );

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(response.body)};
      } else {
        return {'success': false, 'status': 'unhealthy'};
      }
    } catch (e) {
      return {
        'success': false,
        'status': 'unreachable',
        'error': 'network_error',
        'message': 'Network error: $e',
      };
    }
  }

  // ===== LEGACY COMPATIBILITY METHODS =====
  // These methods maintain backward compatibility with existing code

  /// Legacy: Get lessons (returns List<Lesson>)
  static Future<List<Lesson>> getLessonsList({
    int limit = 50,
    int offset = 0,
    String? category,
  }) async {
    final result = await getLessons(
      limit: limit,
      offset: offset,
      category: category,
    );
    if (result['success'] == true) {
      return result['lessons'] as List<Lesson>;
    }
    return [];
  }

  /// Legacy: Get earnings history (returns List<Transaction>)
  static Future<List<Transaction>> getEarningsHistory() async {
    final result = await getXpHistory(limit: 100);
    if (result['success'] == true) {
      final events = result['events'] as List?;
      if (events != null) {
        return events.map((event) {
          return Transaction(
            id: event['id'] ?? '',
            title: _getSourceTitle(event['source'] ?? 'unknown'),
            amount: event['xp_delta'] ?? 0,
            timestamp: DateTime.parse(event['created_at']),
            type: event['xp_delta']! > 0 ? 'credit' : 'debit',
          );
        }).toList();
      }
    }
    return [];
  }

  static String _getSourceTitle(String source) {
    switch (source) {
      case 'lesson':
        return 'Lesson Completed';
      case 'quiz':
        return 'Quiz Completed';
      case 'ad':
        return 'Ad Reward';
      case 'daily':
        return 'Daily Bonus';
      case 'referral_reward':
        return 'Referral Reward';
      default:
        return 'XP Credit';
    }
  }

  /// Legacy: Record earning (uses XP credit)
  static Future<bool> recordEarning(String source, int amount) async {
    final nonce = _generateIdempotencyKey();
    final result = await creditXp(
      events: [
        {'nonce': nonce, 'source': source, 'xp_delta': amount, 'metadata': {}},
      ],
    );
    return result['success'] == true;
  }

  /// Legacy: Complete lesson
  static Future<Map<String, dynamic>> completeLessonLegacy(
    String lessonId,
  ) async {
    return await completeLesson(lessonId: lessonId, timeSpentSeconds: 0);
  }

  /// Legacy: Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    return await getMe();
  }
}
