import 'package:flutter/material.dart';

enum QuizDifficulty { easy, medium, hard }

class Quiz {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int coinReward;
  final String category;
  final QuizDifficulty difficulty;
  final int timeLimit; // in minutes
  final String imageUrl;
  final bool isPremium;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.coinReward,
    required this.category,
    this.difficulty = QuizDifficulty.easy,
    this.timeLimit = 10,
    this.imageUrl = '',
    this.isPremium = false,
  });

  String get difficultyText {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 'Easy';
      case QuizDifficulty.medium:
        return 'Medium';
      case QuizDifficulty.hard:
        return 'Hard';
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return Colors.green;
      case QuizDifficulty.medium:
        return Colors.orange;
      case QuizDifficulty.hard:
        return Colors.red;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'coinReward': coinReward,
      'category': category,
      'difficulty': difficulty.name,
      'timeLimit': timeLimit,
      'imageUrl': imageUrl,
      'isPremium': isPremium,
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      questions:
          (json['questions'] as List?)
              ?.map((q) => QuizQuestion.fromJson(q))
              .toList() ??
          [],
      coinReward: json['coinReward'] ?? 0,
      category: json['category'] ?? '',
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => QuizDifficulty.easy,
      ),
      timeLimit: json['timeLimit'] ?? 10,
      imageUrl: json['imageUrl'] ?? '',
      isPremium: json['isPremium'] ?? false,
    );
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class QuizResult {
  final String quizId;
  final int score;
  final int totalQuestions;
  final List<bool> answers;
  final DateTime completedAt;

  QuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.completedAt,
  });

  double get percentage => (score / totalQuestions) * 100;
  bool get passed => percentage >= 70;

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'answers': answers,
      'completedAt': completedAt.millisecondsSinceEpoch,
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      quizId: json['quizId'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      answers: List<bool>.from(json['answers'] ?? []),
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        json['completedAt'] ?? 0,
      ),
    );
  }
}
