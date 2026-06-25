import 'package:flutter/material.dart';

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final int points;
  final String explanation;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.points,
    required this.explanation,
  });
}

class QuizCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Question> questions;

  const QuizCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

enum QuizStatus { initial, inProgress, completed }

class QuizSessionState {
  final QuizCategory? category;
  final QuizStatus status;
  final int currentQuestionIndex;
  final Map<int, int> chosenAnswers; // question index -> chosen option index
  final int score;
  final int currentStreak;
  final int maxStreak;
  final int timeRemaining; // in seconds
  final int elapsedSeconds;

  const QuizSessionState({
    this.category,
    this.status = QuizStatus.initial,
    this.currentQuestionIndex = 0,
    this.chosenAnswers = const {},
    this.score = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.timeRemaining = 15,
    this.elapsedSeconds = 0,
  });

  bool get isLastQuestion =>
      category != null && currentQuestionIndex >= category!.questions.length - 1;

  Question? get currentQuestion {
    if (category == null || currentQuestionIndex >= category!.questions.length) {
      return null;
    }
    return category!.questions[currentQuestionIndex];
  }

  QuizSessionState copyWith({
    QuizCategory? category,
    QuizStatus? status,
    int? currentQuestionIndex,
    Map<int, int>? chosenAnswers,
    int? score,
    int? currentStreak,
    int? maxStreak,
    int? timeRemaining,
    int? elapsedSeconds,
  }) {
    return QuizSessionState(
      category: category ?? this.category,
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      chosenAnswers: chosenAnswers ?? this.chosenAnswers,
      score: score ?? this.score,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
