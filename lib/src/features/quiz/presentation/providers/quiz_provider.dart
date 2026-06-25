import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/quiz_models.dart';

IconData _getIconForCategory(String name) {
  switch (name.toLowerCase()) {
    case 'math':
      return Icons.calculate_rounded;
    case 'general knowledge':
      return Icons.lightbulb_rounded;
    case 'physics':
      return Icons.science_rounded;
    case 'biology':
      return Icons.yard_rounded;
    case 'chemistry':
      return Icons.biotech_rounded;
    case 'computer':
      return Icons.computer_rounded;
    default:
      return Icons.quiz_rounded;
  }
}

Color _getColorForCategory(String name) {
  switch (name.toLowerCase()) {
    case 'math':
      return const Color(0xFF6366F1); // Indigo
    case 'general knowledge':
      return const Color(0xFFF59E0B); // Amber
    case 'physics':
      return const Color(0xFF8B5CF6); // Violet
    case 'biology':
      return const Color(0xFF10B981); // Emerald
    case 'chemistry':
      return const Color(0xFFEC4899); // Pink
    case 'computer':
      return const Color(0xFF3B82F6); // Blue
    default:
      return const Color(0xFF6366F1);
  }
}

final quizCategoriesProvider = FutureProvider<List<QuizCategory>>((ref) async {
  final response = await http.get(Uri.parse('https://sadiks-quiz-apihub.lovable.app/api/v1/categories'));
  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    if (body['success'] == true) {
      final List data = body['data'] ?? [];
      return data.map<QuizCategory>((item) {
        final name = item['name'] ?? '';
        return QuizCategory(
          id: item['id'].toString(),
          title: name,
          description: item['description'] ?? '',
          icon: _getIconForCategory(name),
          color: _getColorForCategory(name),
          questions: const [], // Load questions dynamically when starting quiz
        );
      }).toList();
    }
  }
  throw Exception('Failed to load categories');
});


class QuizController extends StateNotifier<QuizSessionState> {
  QuizController(this._ref) : super(const QuizSessionState());

  final Ref _ref;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> startQuiz(QuizCategory category) async {
    _timer?.cancel();
    state = QuizSessionState(
      category: category,
      status: QuizStatus.loading,
      currentQuestionIndex: 0,
      chosenAnswers: {},
      score: 0,
      currentStreak: 0,
      maxStreak: 0,
      timeRemaining: 15,
      elapsedSeconds: 0,
    );

    try {
      final response = await http.get(Uri.parse('https://sadiks-quiz-apihub.lovable.app/api/v1/categories/${category.id}/questions'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          final List data = body['data'] ?? [];
          final List<Question> questions = data.map<Question>((q) {
            final List<String> opts = List<String>.from(q['options'] ?? []);
            final int ansIdx = q['answerIndex'] ?? 0;
            return Question(
              id: q['id'].toString(),
              text: q['question'] ?? '',
              options: opts,
              correctOptionIndex: ansIdx,
              points: q['mark'] ?? 10,
              explanation: 'The correct answer is ${opts.isNotEmpty && ansIdx < opts.length ? opts[ansIdx] : "option ${String.fromCharCode(65 + ansIdx)}"}.',
            );
          }).toList();

          final categoryWithQuestions = QuizCategory(
            id: category.id,
            title: category.title,
            description: category.description,
            icon: category.icon,
            color: category.color,
            questions: questions,
          );

          state = QuizSessionState(
            category: categoryWithQuestions,
            status: QuizStatus.inProgress,
            currentQuestionIndex: 0,
            chosenAnswers: {},
            score: 0,
            currentStreak: 0,
            maxStreak: 0,
            timeRemaining: 15,
            elapsedSeconds: 0,
          );
          _startTimer();
          return;
        }
      }
      throw Exception('Failed to load questions');
    } catch (e) {
      state = state.copyWith(status: QuizStatus.error);
    }
  }

  void selectAnswer(int optionIndex) {
    if (state.status != QuizStatus.inProgress) return;
    
    // If already answered this question, do nothing
    if (state.chosenAnswers.containsKey(state.currentQuestionIndex)) return;

    _timer?.cancel();

    final isCorrect = optionIndex == state.currentQuestion!.correctOptionIndex;
    final updatedAnswers = Map<int, int>.from(state.chosenAnswers);
    updatedAnswers[state.currentQuestionIndex] = optionIndex;

    final newStreak = isCorrect ? state.currentStreak + 1 : 0;
    final newMaxStreak = newStreak > state.maxStreak ? newStreak : state.maxStreak;
    final scoreBonus = isCorrect ? (state.currentQuestion!.points + (newStreak > 1 ? (newStreak - 1) * 2 : 0)) : 0;

    state = state.copyWith(
      chosenAnswers: updatedAnswers,
      score: state.score + scoreBonus,
      currentStreak: newStreak,
      maxStreak: newMaxStreak,
    );
  }

  void handleTimeout() {
    if (state.status != QuizStatus.inProgress) return;
    if (state.chosenAnswers.containsKey(state.currentQuestionIndex)) return;

    _timer?.cancel();

    final updatedAnswers = Map<int, int>.from(state.chosenAnswers);
    updatedAnswers[state.currentQuestionIndex] = -1; // -1 means timed out/no answer

    state = state.copyWith(
      chosenAnswers: updatedAnswers,
      currentStreak: 0,
    );
  }

  void nextQuestion() {
    if (state.status != QuizStatus.inProgress) return;

    if (state.isLastQuestion) {
      finishQuiz();
    } else {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        timeRemaining: 15,
      );
      _startTimer();
    }
  }

  void finishQuiz() {
    _timer?.cancel();
    state = state.copyWith(
      status: QuizStatus.completed,
    );

    // Update user stats in authControllerProvider
    final authState = _ref.read(authControllerProvider);
    if (authState is Authenticated) {
      final user = authState.user;
      final categoryQuestionsCount = state.category?.questions.length ?? 1;
      
      // Calculate accuracy for this session
      int correctAnswers = 0;
      state.chosenAnswers.forEach((qIdx, ansIdx) {
        if (state.category != null && 
            ansIdx == state.category!.questions[qIdx].correctOptionIndex) {
          correctAnswers++;
        }
      });
      
      final sessionAccuracy = correctAnswers / categoryQuestionsCount;
      final newTotalQuizzes = user.quizzesTaken + 1;
      
      // Cumulative accuracy
      final newAccuracy = ((user.accuracy * user.quizzesTaken) + sessionAccuracy) / newTotalQuizzes;
      final xpGained = state.score;
      final newXp = user.xp + xpGained;
      
      // Streak update (always increments or keeps active)
      final newStreak = user.streak + 1;

      // Unlock badges based on milestones
      final updatedBadges = List<String>.from(user.badges);
      if (newTotalQuizzes >= 1 && !updatedBadges.contains('Novice')) {
        updatedBadges.add('Novice');
      }
      if (newTotalQuizzes >= 5 && !updatedBadges.contains('Quiz Whiz')) {
        updatedBadges.add('Quiz Whiz');
      }
      if (state.maxStreak >= 5 && !updatedBadges.contains('Streak Master')) {
        updatedBadges.add('Streak Master');
      }
      if (newXp >= 500 && !updatedBadges.contains('Grandmaster')) {
        updatedBadges.add('Grandmaster');
      }

      final updatedUser = user.copyWith(
        xp: newXp,
        quizzesTaken: newTotalQuizzes,
        accuracy: double.parse(newAccuracy.toStringAsFixed(2)),
        streak: newStreak,
        badges: updatedBadges,
      );

      _ref.read(authControllerProvider.notifier).updateUser(updatedUser);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 1) {
        state = state.copyWith(
          timeRemaining: state.timeRemaining - 1,
          elapsedSeconds: state.elapsedSeconds + 1,
        );
      } else {
        state = state.copyWith(
          timeRemaining: 0,
          elapsedSeconds: state.elapsedSeconds + 1,
        );
        handleTimeout();
      }
    });
  }
}

final quizControllerProvider = StateNotifierProvider<QuizController, QuizSessionState>((ref) {
  return QuizController(ref);
});
