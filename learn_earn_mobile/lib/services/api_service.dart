import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson.dart';
import '../models/transaction.dart';

class ApiService {
  static const String baseUrl = 'https://learn-and-earn-04ok.onrender.com/api';
  static String? _deviceId;

  // Set device ID for API calls
  static void setDeviceId(String deviceId) {
    _deviceId = deviceId;
  }

  // Register device with backend
  static Future<Map<String, dynamic>> registerDevice() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'timestamp': DateTime.now().toIso8601String()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _deviceId = data['deviceId'];
        return data;
      } else {
        throw Exception('Failed to register device: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering device: $e');
      // Return mock data for offline mode
      _deviceId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      return {
        'deviceId': _deviceId,
        'message': 'Offline mode - using local data',
      };
    }
  }

  // Get lessons from backend
  static Future<List<Lesson>> getLessons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['lessons'] as List)
            .map((json) => Lesson.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading lessons from API: $e');
      // Return empty list for offline mode
      return [];
    }
  }

  // Record earning in backend
  static Future<bool> recordEarning(String source, int amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/earnings/record'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
        body: jsonEncode({
          'source': source,
          'amount': amount,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error recording earning: $e');
      return false;
    }
  }

  // Get earnings history from backend
  static Future<List<Transaction>> getEarningsHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/earnings/history'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['earnings'] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load earnings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading earnings from API: $e');
      return [];
    }
  }

  // Request payout
  static Future<Map<String, dynamic>> requestPayout(
    String mobileNumber,
    int amount,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payouts/request'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
        body: jsonEncode({
          'mobileNumber': mobileNumber,
          'amount': amount,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to request payout: ${response.statusCode}');
      }
    } catch (e) {
      print('Error requesting payout: $e');
      return {
        'success': false,
        'message': 'Offline mode - payout request saved locally',
      };
    }
  }

  // Get payout history
  static Future<List<Map<String, dynamic>>> getPayoutHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payouts/history'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['payouts']);
      } else {
        throw Exception('Failed to load payouts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading payouts from API: $e');
      return [];
    }
  }

  // Submit quiz results
  static Future<Map<String, dynamic>> submitQuiz(
    String lessonId,
    List<int> answers,
    int timeSpent,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/submit'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
        body: jsonEncode({
          'lessonId': lessonId,
          'answers': answers,
          'timeSpent': timeSpent,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to submit quiz: ${response.statusCode} - ${response.body}',
        );
        return {
          'success': false,
          'message': 'Failed to submit quiz: ${response.body}',
        };
      }
    } catch (e) {
      print('Error submitting quiz: $e');
      return {'success': false, 'message': 'Failed to submit quiz: $e'};
    }
  }

  // Get quiz history
  static Future<List<Map<String, dynamic>>> getQuizHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quiz/history'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => json as Map<String, dynamic>).toList();
      } else {
        print(
          'Failed to load quiz history: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error getting quiz history: $e');
      return [];
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to load user profile: ${response.statusCode} - ${response.body}',
        );
        return {};
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return {};
    }
  }

  // Set mobile money number
  static Future<Map<String, dynamic>> setMobileMoneyNumber(
    String mobileNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/mobile-number'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
        body: jsonEncode({'mobileNumber': mobileNumber}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to set mobile number: ${response.statusCode} - ${response.body}',
        );
        return {
          'success': false,
          'message': 'Failed to set mobile number: ${response.body}',
        };
      }
    } catch (e) {
      print('Error setting mobile number: $e');
      return {'success': false, 'message': 'Failed to set mobile number: $e'};
    }
  }

  // Get daily earnings
  static Future<List<Map<String, dynamic>>> getDailyEarnings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/earnings/daily'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => json as Map<String, dynamic>).toList();
      } else {
        print(
          'Failed to load daily earnings: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error getting daily earnings: $e');
      return [];
    }
  }

  // Get user progress
  static Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/progress'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to load user progress: ${response.statusCode} - ${response.body}',
        );
        return {};
      }
    } catch (e) {
      print('Error getting user progress: $e');
      return {};
    }
  }

  // Perform daily reset
  static Future<Map<String, dynamic>> performDailyReset() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/progress/reset'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to perform daily reset: ${response.statusCode} - ${response.body}',
        );
        return {
          'success': false,
          'message': 'Failed to perform daily reset: ${response.body}',
        };
      }
    } catch (e) {
      print('Error performing daily reset: $e');
      return {'success': false, 'message': 'Failed to perform daily reset: $e'};
    }
  }

  // Complete a lesson
  static Future<Map<String, dynamic>> completeLesson(String lessonId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/lessons/$lessonId/complete'),
        headers: {
          'Content-Type': 'application/json',
          if (_deviceId != null) 'X-Device-ID': _deviceId!,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(
          'Failed to complete lesson: ${response.statusCode} - ${response.body}',
        );
        return {
          'success': false,
          'message': 'Failed to complete lesson: ${response.body}',
        };
      }
    } catch (e) {
      print('Error completing lesson: $e');
      return {'success': false, 'message': 'Failed to complete lesson: $e'};
    }
  }

  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/../health'), // Go up one level from /api to root
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Backend health check failed: $e');
      return false;
    }
  }
}
