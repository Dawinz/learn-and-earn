import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';
import '../models/transaction.dart';

class StorageService {
  static const String _coinsKey = 'user_coins';
  static const String _lessonsKey = 'user_lessons';
  static const String _transactionsKey = 'user_transactions';
  static const String _lastResetDateKey = 'last_reset_date';

  static Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  static Future<int> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 1000; // Default starting coins
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

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coinsKey);
    await prefs.remove(_lessonsKey);
    await prefs.remove(_transactionsKey);
    await prefs.remove(_lastResetDateKey);
  }
}
