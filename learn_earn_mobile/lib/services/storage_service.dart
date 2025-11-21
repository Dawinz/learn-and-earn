import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';
import '../models/transaction.dart';

class StorageService {
  // Session storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  static const String _userIdKey = 'user_id';
  static const String _deviceIdKey = 'device_id';

  // Data storage keys
  static const String _coinsKey = 'user_coins';
  static const String _lessonsKey = 'user_lessons';
  static const String _transactionsKey = 'user_transactions';
  static const String _lastResetDateKey = 'last_reset_date';
  static const String _lastDailyLoginKey = 'last_daily_login';
  static const String _learningStreakKey = 'learning_streak';
  static const String _lastStreakDateKey = 'last_streak_date';

  // Session management
  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required String userId,
    String? deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_tokenExpiresAtKey, expiresAt.toIso8601String());
    await prefs.setString(_userIdKey, userId);
    if (deviceId != null) {
      await prefs.setString(_deviceIdKey, deviceId);
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<DateTime?> getTokenExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAtString = prefs.getString(_tokenExpiresAtKey);
    if (expiresAtString == null) return null;
    try {
      return DateTime.parse(expiresAtString);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> getStoredDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }

  static Future<bool> isTokenValid() async {
    final expiresAt = await getTokenExpiresAt();
    if (expiresAt == null) return false;
    // Check if token expires in more than 5 minutes
    return expiresAt.isAfter(DateTime.now().add(const Duration(minutes: 5)));
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiresAtKey);
    await prefs.remove(_userIdKey);
    // Note: We don't clear device_id as it's needed for re-authentication
  }

  static Future<void> saveXp(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, xp);
  }

  static Future<int> loadXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 1000; // Default starting xp
  }

  static Future<void> saveLessons(List<Lesson> lessons) async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsJson = lessons
        .map(
          (lesson) => {
            'id': lesson.id,
            'title': lesson.title,
            'summary': lesson.summary,
            'contentMD': lesson.contentMD,
            'estMinutes': lesson.estMinutes,
            'coinReward': lesson.coinReward,
            'isCompleted': lesson.isCompleted,
            'category': lesson.category,
            'createdAt': lesson.createdAt.toIso8601String(),
            'updatedAt': lesson.updatedAt.toIso8601String(),
          },
        )
        .toList();
    await prefs.setString(_lessonsKey, jsonEncode(lessonsJson));
  }

  static Future<List<Lesson>> loadLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsString = prefs.getString(_lessonsKey);

    if (lessonsString == null) {
      return []; // Return empty list if no saved lessons
    }

    try {
      final List<dynamic> lessonsJson = jsonDecode(lessonsString);
      return lessonsJson
          .map(
            (json) => Lesson(
              id: json['id'],
              title: json['title'],
              summary: json['summary'] ?? json['description'] ?? '',
              contentMD: json['contentMD'] ?? json['content'] ?? '',
              estMinutes: json['estMinutes'] ?? json['duration'] ?? 0,
              coinReward: json['coinReward'],
              isCompleted: json['isCompleted'] ?? false,
              category: json['category'],
              createdAt: json['createdAt'] != null
                  ? DateTime.parse(json['createdAt'])
                  : DateTime.now(),
              updatedAt: json['updatedAt'] != null
                  ? DateTime.parse(json['updatedAt'])
                  : DateTime.now(),
            ),
          )
          .toList();
    } catch (e) {
      print('Error loading lessons: $e');
      return [];
    }
  }

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions
        .map(
          (transaction) => {
            'id': transaction.id,
            'title': transaction.title,
            'amount': transaction.amount,
            'timestamp': transaction.timestamp.millisecondsSinceEpoch,
            'type': transaction.type,
          },
        )
        .toList();
    await prefs.setString(_transactionsKey, jsonEncode(transactionsJson));
  }

  static Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsString = prefs.getString(_transactionsKey);

    if (transactionsString == null) {
      return []; // Return empty list if no saved transactions
    }

    try {
      final List<dynamic> transactionsJson = jsonDecode(transactionsString);
      return transactionsJson
          .map(
            (json) => Transaction(
              id: json['id'],
              title: json['title'],
              amount: json['amount'],
              timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
              type: json['type'],
            ),
          )
          .toList();
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }

  static Future<void> saveLastResetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastResetDateKey, date.toIso8601String());
  }

  static Future<DateTime?> loadLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastResetDateKey);

    if (dateString == null) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error loading last reset date: $e');
      return null;
    }
  }

  static Future<void> saveLastDailyLogin(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDailyLoginKey, date.toIso8601String());
  }

  static Future<DateTime?> loadLastDailyLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastDailyLoginKey);

    if (dateString == null) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error loading last daily login: $e');
      return null;
    }
  }

  static Future<void> saveLearningStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_learningStreakKey, streak);
  }

  static Future<int> loadLearningStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_learningStreakKey) ?? 0;
  }

  static Future<void> saveLastStreakDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastStreakDateKey, date.toIso8601String());
  }

  static Future<DateTime?> loadLastStreakDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastStreakDateKey);

    if (dateString == null) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error loading last streak date: $e');
      return null;
    }
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coinsKey);
    await prefs.remove(_lessonsKey);
    await prefs.remove(_transactionsKey);
    await prefs.remove(_lastResetDateKey);
    await prefs.remove(_lastDailyLoginKey);
    await prefs.remove(_learningStreakKey);
    await prefs.remove(_lastStreakDateKey);
  }
}
