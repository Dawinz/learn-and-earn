class Lesson {
  final String id;
  final String title;
  final String summary; // Backend uses 'summary' instead of 'description'
  final String contentMD; // Backend uses 'contentMD' instead of 'content'
  final int estMinutes; // Backend uses 'estMinutes' instead of 'duration'
  final int coinReward;
  final bool isCompleted;
  final String category;
  final List<String> tags;
  final List<QuizQuestion> quiz;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.contentMD,
    required this.estMinutes,
    required this.coinReward,
    this.isCompleted = false,
    required this.category,
    this.tags = const [],
    this.quiz = const [],
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convenience getters for backward compatibility
  String get description => summary;
  String get content => contentMD;
  int get duration => estMinutes;

  Lesson copyWith({
    String? id,
    String? title,
    String? summary,
    String? contentMD,
    int? estMinutes,
    int? coinReward,
    bool? isCompleted,
    String? category,
    List<String>? tags,
    List<QuizQuestion>? quiz,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      contentMD: contentMD ?? this.contentMD,
      estMinutes: estMinutes ?? this.estMinutes,
      coinReward: coinReward ?? this.coinReward,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      quiz: quiz ?? this.quiz,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'contentMD': contentMD,
      'estMinutes': estMinutes,
      'coinReward': coinReward,
      'isCompleted': isCompleted,
      'category': category,
      'tags': tags,
      'quiz': quiz.map((q) => q.toJson()).toList(),
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      contentMD: json['contentMD'] ?? '',
      estMinutes: json['estMinutes'] ?? 0,
      coinReward: json['coinReward'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      quiz:
          (json['quiz'] as List?)
              ?.map((q) => QuizQuestion.fromJson(q))
              .toList() ??
          [],
      isPublished: json['isPublished'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}
