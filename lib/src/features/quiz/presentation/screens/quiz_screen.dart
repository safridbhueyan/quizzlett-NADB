import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quizlett/core/constant/app_colors.dart';
import 'package:quizlett/src/features/quiz/domain/quiz_models.dart';
import 'package:quizlett/src/features/quiz/presentation/providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String categoryId;
  const QuizScreen({required this.categoryId, super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text('Are you sure you want to quit? Your progress for this session will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (quizState.status == QuizStatus.loading || quizState.status == QuizStatus.initial) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading Questions...',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    if (quizState.status == QuizStatus.error) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Failed to load questions',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (quizState.category == null) {
      return const Scaffold(
        body: Center(
          child: Text('No active quiz category found.'),
        ),
      );
    }

    final currentQuestion = quizState.currentQuestion;
    if (currentQuestion == null) {
      // Completed, redirect
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacement('/quiz-results');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasAnswered = quizState.chosenAnswers.containsKey(quizState.currentQuestionIndex);
    final selectedAnswerIndex = quizState.chosenAnswers[quizState.currentQuestionIndex];

    // Pulse the timer when time gets low
    if (quizState.timeRemaining <= 5 && !hasAnswered) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }

    // Determine timer color
    Color timerColor = AppColors.success;
    if (quizState.timeRemaining <= 5) {
      timerColor = AppColors.error;
    } else if (quizState.timeRemaining <= 10) {
      timerColor = AppColors.warning;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(quizState.category!.title),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              final shouldPop = await _showExitDialog();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
          ),
          actions: [
            // Streak indicator in header
            if (quizState.currentStreak > 0)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥'),
                        const SizedBox(width: 4),
                        Text(
                          '${quizState.currentStreak}',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // 1. Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (quizState.currentQuestionIndex + 1) / quizState.category!.questions.length,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Progress details text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${quizState.currentQuestionIndex + 1} of ${quizState.category!.questions.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Score: ${quizState.score} pts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Pulsing Countdown Circle
                    Center(
                      child: ScaleTransition(
                        scale: _pulseController,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: timerColor.withValues(alpha: 0.1),
                            border: Border.all(color: timerColor.withValues(alpha: 0.3), width: 2),
                            boxShadow: [
                              if (quizState.timeRemaining <= 5 && !hasAnswered)
                                BoxShadow(
                                  color: timerColor.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${quizState.timeRemaining}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: timerColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Question Text Display Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        currentQuestion.text,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 4. Interactive Choice Options List
                    Column(
                      children: List.generate(currentQuestion.options.length, (index) {
                        final optionText = currentQuestion.options[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: _buildOptionButton(
                            context: context,
                            index: index,
                            optionText: optionText,
                            correctIndex: currentQuestion.correctOptionIndex,
                            hasAnswered: hasAnswered,
                            selectedIndex: selectedAnswerIndex,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    // 5. Answer Explanation Sliding Container
                    if (hasAnswered) ...[
                      const SizedBox(height: 8),
                      _buildExplanationCard(
                        context: context,
                        isCorrect: selectedAnswerIndex == currentQuestion.correctOptionIndex,
                        explanation: currentQuestion.explanation,
                        pointsEarned: selectedAnswerIndex == currentQuestion.correctOptionIndex
                            ? currentQuestion.points + (quizState.currentStreak > 1 ? (quizState.currentStreak - 1) * 2 : 0)
                            : 0,
                        streak: quizState.currentStreak,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref.read(quizControllerProvider.notifier).nextQuestion(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.all(AppColors.primary),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  quizState.isLastQuestion ? 'Finish Quiz' : 'Next Question',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required int index,
    required String optionText,
    required int correctIndex,
    required bool hasAnswered,
    required int? selectedIndex,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color btnColor = isDark ? AppColors.surfaceDark : Colors.white;
    Color borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.borderLight;
    Color textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    Widget? icon;

    if (hasAnswered) {
      if (index == correctIndex) {
        // Correct Option
        btnColor = AppColors.success.withValues(alpha: 0.15);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        icon = const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22);
      } else if (selectedIndex == index && selectedIndex != correctIndex) {
        // User selected this incorrect option
        btnColor = AppColors.error.withValues(alpha: 0.15);
        borderColor = AppColors.error;
        textColor = AppColors.error;
        icon = const Icon(Icons.cancel_rounded, color: AppColors.error, size: 22);
      } else {
        // Unselected other options fade out
        textColor = textColor.withValues(alpha: 0.4);
        borderColor = borderColor.withValues(alpha: 0.3);
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: hasAnswered
            ? null
            : () => ref.read(quizControllerProvider.notifier).selectAnswer(index),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (!hasAnswered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
            ],
          ),
          child: Row(
            children: [
              // Circle prefix index letter (A, B, C, D)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasAnswered && index == correctIndex
                      ? AppColors.success.withValues(alpha: 0.1)
                      : hasAnswered && selectedIndex == index
                          ? AppColors.error.withValues(alpha: 0.1)
                          : isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                ),
                alignment: Alignment.center,
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Option content
              Expanded(
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 10),
                icon,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard({
    required BuildContext context,
    required bool isCorrect,
    required String explanation,
    required int pointsEarned,
    required int streak,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bannerBg = isCorrect 
        ? AppColors.success.withValues(alpha: 0.1) 
        : AppColors.error.withValues(alpha: 0.1);
    final bannerBorder = isCorrect ? AppColors.success : AppColors.error;
    final headerText = isCorrect ? 'Correct Answer!' : 'Incorrect!';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bannerBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: bannerBorder.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: bannerBorder,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  headerText,
                  style: TextStyle(
                    color: bannerBorder,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // XP & Score bonus display
          if (isCorrect) ...[
            Row(
              children: [
                const Text('✨ ', style: TextStyle(fontSize: 14)),
                Text(
                  '+$pointsEarned XP',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (streak > 1) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Streak Bonus Included!',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          Text(
            'Explanation:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
