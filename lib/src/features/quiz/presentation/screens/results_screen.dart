import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quizlett/core/constant/app_colors.dart';
import 'package:quizlett/src/features/quiz/presentation/providers/quiz_provider.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (quizState.category == null) {
      return const Scaffold(
        body: Center(
          child: Text('No active quiz results found.'),
        ),
      );
    }

    final category = quizState.category!;
    final questions = category.questions;
    final totalQuestions = questions.length;
    
    // Calculate stats
    int correctAnswers = 0;
    quizState.chosenAnswers.forEach((qIdx, ansIdx) {
      if (ansIdx == questions[qIdx].correctOptionIndex) {
        correctAnswers++;
      }
    });

    final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) : 0.0;
    final isHighScore = accuracy >= 0.8;

    return Scaffold(
      body: Stack(
        children: [
          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  
                  // Celebration Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isHighScore 
                                ? AppColors.success.withValues(alpha: 0.1) 
                                : AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            isHighScore ? Icons.emoji_events_rounded : Icons.star_rounded,
                            size: 70,
                            color: isHighScore ? AppColors.success : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isHighScore ? 'Congratulations!' : 'Good Effort!',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You completed the ${category.title} quiz',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Points earned card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '+${quizState.score} XP Earned',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Stats Breakdown Grid
                  Text(
                    'Your Performance',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        context,
                        'Accuracy',
                        '${(accuracy * 100).toInt()}%',
                        Icons.insights_rounded,
                        AppColors.primary,
                      ),
                      _buildStatCard(
                        context,
                        'Correct Answers',
                        '$correctAnswers / $totalQuestions',
                        Icons.check_circle_rounded,
                        AppColors.success,
                      ),
                      _buildStatCard(
                        context,
                        'Max Streak',
                        '${quizState.maxStreak} 🔥',
                        Icons.local_fire_department_rounded,
                        AppColors.secondary,
                      ),
                      _buildStatCard(
                        context,
                        'Time Spent',
                        '${quizState.elapsedSeconds}s',
                        Icons.timer_rounded,
                        AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Review Answers List
                  Text(
                    'Review Answers',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalQuestions,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, qIndex) {
                      final question = questions[qIndex];
                      final userAnsIndex = quizState.chosenAnswers[qIndex] ?? -1;
                      final isUserCorrect = userAnsIndex == question.correctOptionIndex;

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status Icon Badge
                                Icon(
                                  isUserCorrect 
                                      ? Icons.check_circle_rounded 
                                      : userAnsIndex == -1 
                                          ? Icons.timer_off_rounded 
                                          : Icons.cancel_rounded,
                                  color: isUserCorrect 
                                      ? AppColors.success 
                                      : userAnsIndex == -1 
                                          ? AppColors.warning 
                                          : AppColors.error,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                // Question Text
                                Expanded(
                                  child: Text(
                                    question.text,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // User Answer detail
                            Text(
                              userAnsIndex == -1
                                  ? 'Your Answer: (No response / Timed out)'
                                  : 'Your Answer: ${userAnsIndex >= 0 ? question.options[userAnsIndex] : ""}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isUserCorrect 
                                    ? AppColors.success 
                                    : userAnsIndex == -1 
                                        ? AppColors.warning 
                                        : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // Correct answer show if wrong
                            if (!isUserCorrect) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Correct Answer: ${question.options[question.correctOptionIndex]}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(quizControllerProvider.notifier).startQuiz(category);
                            context.pushReplacement('/quiz/${category.id}');
                          },
                          child: const Text('Try Again'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Home'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Confetti Animation overlay
          if (isHighScore)
            const Positioned.fill(
              child: IgnorePointer(
                child: _ConfettiWidget(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Confetti Particle System Widget
class _ConfettiWidget extends StatefulWidget {
  const _ConfettiWidget();

  @override
  State<_ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<_ConfettiWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _updateParticles();
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updateParticles() {
    if (!mounted) return;
    
    // Spawn new particles occasionally
    if (_particles.length < 50 && _random.nextDouble() < 0.25) {
      _particles.add(_ConfettiParticle.generate(_random));
    }

    setState(() {
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.y += p.vy;
        p.x += p.vx + math.sin(p.y / 25) * 0.4;
        p.rotation += p.rotationSpeed;
        
        // Remove particle if it goes off screen
        if (p.y > 1000) {
          _particles.removeAt(i);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConfettiPainter(_particles),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
  bool isCircle;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.isCircle,
  });

  factory _ConfettiParticle.generate(math.Random rand) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.success,
      Colors.amber,
      Colors.cyan,
      Colors.orange,
    ];
    return _ConfettiParticle(
      x: rand.nextDouble() * 400, // spawn horizontally
      y: -20,
      vx: (rand.nextDouble() - 0.5) * 2, // slight horizontal drift
      vy: rand.nextDouble() * 3 + 2.5, // vertical velocity
      color: colors[rand.nextInt(colors.length)],
      size: rand.nextDouble() * 8 + 6,
      rotation: rand.nextDouble() * 2 * math.pi,
      rotationSpeed: (rand.nextDouble() - 0.5) * 0.1,
      isCircle: rand.nextBool(),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      paint.color = p.color;
      canvas.save();
      // Translate to particle center and rotate
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
