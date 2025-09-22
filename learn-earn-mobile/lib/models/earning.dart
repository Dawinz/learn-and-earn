enum EarningSource { lesson, quiz, streak, dailyBonus, adReward }

extension EarningSourceExtension on EarningSource {
  String get value {
    switch (this) {
      case EarningSource.lesson:
        return 'lesson';
      case EarningSource.quiz:
        return 'quiz';
      case EarningSource.streak:
        return 'streak';
      case EarningSource.dailyBonus:
        return 'daily-bonus';
      case EarningSource.adReward:
        return 'ad-reward';
    }
  }

  static EarningSource fromString(String value) {
    switch (value) {
      case 'lesson':
        return EarningSource.lesson;
      case 'quiz':
        return EarningSource.quiz;
      case 'streak':
        return EarningSource.streak;
      case 'daily-bonus':
        return EarningSource.dailyBonus;
      case 'ad-reward':
        return EarningSource.adReward;
      default:
        throw ArgumentError('Invalid earning source: $value');
    }
  }
}

class Earning {
  final String id;
  final String deviceId;
  final EarningSource source;
  final int coins;
  final double usd;
  final String? lessonId;
  final String? adSlotId;
  final DateTime createdAt;

  Earning({
    required this.id,
    required this.deviceId,
    required this.source,
    required this.coins,
    required this.usd,
    this.lessonId,
    this.adSlotId,
    required this.createdAt,
  });

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      id: json['_id'] ?? json['id'],
      deviceId: json['deviceId'],
      source: EarningSourceExtension.fromString(json['source']),
      coins: json['coins'],
      usd: json['usd'].toDouble(),
      lessonId: json['lessonId'],
      adSlotId: json['adSlotId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'source': source.value,
      'coins': coins,
      'usd': usd,
      'lessonId': lessonId,
      'adSlotId': adSlotId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class EarningSummary {
  final int totalCoins;
  final double totalUsd;
  final Map<String, int> bySource;

  EarningSummary({
    required this.totalCoins,
    required this.totalUsd,
    required this.bySource,
  });

  factory EarningSummary.fromJson(Map<String, dynamic> json) {
    return EarningSummary(
      totalCoins: json['totalCoins'] ?? 0,
      totalUsd: (json['totalUsd'] ?? 0).toDouble(),
      bySource: Map<String, int>.from(json['bySource'] ?? {}),
    );
  }
}
