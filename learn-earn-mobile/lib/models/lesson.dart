class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class AdSlot {
  final String position; // 'mid-lesson', 'post-quiz', 'daily-bonus'
  final bool required;
  final int coinReward;

  AdSlot({
    required this.position,
    required this.required,
    required this.coinReward,
  });

  factory AdSlot.fromJson(Map<String, dynamic> json) {
    return AdSlot(
      position: json['position'],
      required: json['required'],
      coinReward: json['coinReward'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'required': required,
      'coinReward': coinReward,
    };
  }
}

class Lesson {
  final String id;
  final String title;
  final String summary;
  final String contentMD;
  final int estMinutes;
  final List<String> tags;
  final String category;
  final List<QuizQuestion> quiz;
  final List<AdSlot> adSlots;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.contentMD,
    required this.estMinutes,
    required this.tags,
    required this.category,
    required this.quiz,
    required this.adSlots,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      summary: json['summary'],
      contentMD: json['contentMD'] ?? '',
      estMinutes: json['estMinutes'],
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      quiz:
          (json['quiz'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(q))
              .toList() ??
          [],
      adSlots:
          (json['adSlots'] as List<dynamic>?)
              ?.map((a) => AdSlot.fromJson(a))
              .toList() ??
          [],
      isPublished: json['isPublished'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'contentMD': contentMD,
      'estMinutes': estMinutes,
      'tags': tags,
      'category': category,
      'quiz': quiz.map((q) => q.toJson()).toList(),
      'adSlots': adSlots.map((a) => a.toJson()).toList(),
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    if (estMinutes < 60) {
      return '${estMinutes}m';
    } else {
      final hours = estMinutes ~/ 60;
      final minutes = estMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }
}
