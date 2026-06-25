import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/quiz_models.dart';

final quizCategoriesProvider = Provider<List<QuizCategory>>((ref) {
  return [
    const QuizCategory(
      id: 'science-tech',
      title: 'Science & Tech',
      description: 'Test your knowledge on computers, coding, and the physical sciences.',
      icon: Icons.biotech_rounded,
      color: Color(0xFF6366F1),
      questions: [
        Question(
          id: 'st-1',
          text: 'What does "API" stand for in software development?',
          options: [
            'Application Programming Interface',
            'Advanced Protocol Integration',
            'Access Program Identifier',
            'Automated Process Interconnection'
          ],
          correctOptionIndex: 0,
          points: 10,
          explanation: 'API stands for Application Programming Interface. It is a set of defined rules that enable different applications to communicate with each other.',
        ),
        Question(
          id: 'st-2',
          text: 'Which programming language is Flutter written in?',
          options: ['Java', 'Swift', 'Dart', 'Kotlin'],
          correctOptionIndex: 2,
          points: 10,
          explanation: 'Flutter is written in Dart, a client-optimized programming language created by Google for fast apps on multiple platforms.',
        ),
        Question(
          id: 'st-3',
          text: 'What is the speed of light in a vacuum?',
          options: [
            '~300,000 km/s',
            '~150,000 km/s',
            '~500,000 km/s',
            '~1,000,000 km/s'
          ],
          correctOptionIndex: 0,
          points: 15,
          explanation: 'The speed of light in a vacuum is exactly 299,792,458 meters per second, which is approximately 300,000 kilometers per second.',
        ),
        Question(
          id: 'st-4',
          text: 'Which HTML tag is used to link an external JavaScript file?',
          options: ['<link>', '<script>', '<js>', '<style>'],
          correctOptionIndex: 1,
          points: 10,
          explanation: 'The <script> HTML tag is used to embed or reference executable JavaScript code, both inline and external.',
        ),
        Question(
          id: 'st-5',
          text: 'What does CPU stand for?',
          options: [
            'Central Process Unit',
            'Computer Personal Unit',
            'Central Processing Unit',
            'Control Power Unit'
          ],
          correctOptionIndex: 2,
          points: 10,
          explanation: 'The CPU (Central Processing Unit) is the primary component of a computer that acts as its "brain", executing instructions of a computer program.',
        ),
      ],
    ),
    const QuizCategory(
      id: 'space-astronomy',
      title: 'Space & Cosmos',
      description: 'Explore the mysteries of stars, galaxies, black holes, and the solar system.',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF8B5CF6),
      questions: [
        Question(
          id: 'sp-1',
          text: 'What is the largest planet in our Solar System?',
          options: ['Saturn', 'Jupiter', 'Neptune', 'Earth'],
          correctOptionIndex: 1,
          points: 10,
          explanation: 'Jupiter is the fifth planet from the Sun and the largest in the Solar System, with a mass more than two and a half times that of all the other planets combined.',
        ),
        Question(
          id: 'sp-2',
          text: 'Which galaxy is closest to our Milky Way?',
          options: ['Andromeda', 'Triangulum', 'Large Magellanic Cloud', 'Sombrero'],
          correctOptionIndex: 0,
          points: 15,
          explanation: 'The Andromeda Galaxy is the closest major galaxy to our Milky Way and is on a collision course with it in about 4.5 billion years.',
        ),
        Question(
          id: 'sp-3',
          text: 'What is the hottest planet in our solar system?',
          options: ['Mercury', 'Mars', 'Venus', 'Jupiter'],
          correctOptionIndex: 2,
          points: 10,
          explanation: 'Venus is the hottest planet in the Solar System, with surface temperatures reaching 462°C (864°F) due to a thick, runaway greenhouse effect atmosphere.',
        ),
        Question(
          id: 'sp-4',
          text: 'How many planets are in our solar system?',
          options: ['7', '8', '9', '10'],
          correctOptionIndex: 1,
          points: 10,
          explanation: 'There are 8 planets in our solar system: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, and Neptune (Pluto was reclassified as a dwarf planet in 2006).',
        ),
        Question(
          id: 'sp-5',
          text: 'Who was the first human to travel into outer space?',
          options: ['Neil Armstrong', 'Yuri Gagarin', 'Buzz Aldrin', 'Alan Shepard'],
          correctOptionIndex: 1,
          points: 15,
          explanation: 'Soviet cosmonaut Yuri Gagarin became the first human in space on April 12, 1961, orbiting Earth in Vostok 1.',
        ),
      ],
    ),
    const QuizCategory(
      id: 'geography-culture',
      title: 'Geography & Landmarks',
      description: 'Journey across the globe to discover capitals, rivers, oceans, and monuments.',
      icon: Icons.public_rounded,
      color: Color(0xFF10B981),
      questions: [
        Question(
          id: 'geo-1',
          text: 'What is the capital of Japan?',
          options: ['Kyoto', 'Osaka', 'Tokyo', 'Hiroshima'],
          correctOptionIndex: 2,
          points: 10,
          explanation: 'Tokyo is the capital and most populous prefecture of Japan, located on the eastern coast of the main island, Honshu.',
        ),
        Question(
          id: 'geo-2',
          text: 'Which is the longest river in the world?',
          options: ['Amazon River', 'Nile River', 'Yangtze River', 'Mississippi River'],
          correctOptionIndex: 1,
          points: 15,
          explanation: 'The Nile is traditionally considered the longest river in the world, spanning about 6,650 kilometers (4,130 miles) through northeastern Africa.',
        ),
        Question(
          id: 'geo-3',
          text: 'What is the smallest country in the world by land area?',
          options: ['Monaco', 'San Marino', 'Vatican City', 'Liechtenstein'],
          correctOptionIndex: 2,
          points: 15,
          explanation: 'Vatican City is the smallest independent state in the world, both by area (approx. 0.49 sq km) and population, located entirely within Rome, Italy.',
        ),
        Question(
          id: 'geo-4',
          text: 'Which ocean is the largest on Earth?',
          options: ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean', 'Pacific Ocean'],
          correctOptionIndex: 3,
          points: 10,
          explanation: 'The Pacific Ocean is the largest and deepest of Earth\'s oceanic divisions, extending from the Arctic Ocean in the north to the Southern Ocean in the south.',
        ),
        Question(
          id: 'geo-5',
          text: 'Mount Everest is situated in which mountain range?',
          options: ['Andes', 'Alps', 'Himalayas', 'Rockies'],
          correctOptionIndex: 2,
          points: 10,
          explanation: 'Mount Everest, the earth\'s highest mountain above sea level, is located in the Mahalangur Himal sub-range of the Himalayas, on the border between Nepal and China.',
        ),
      ],
    ),
    const QuizCategory(
      id: 'pop-culture',
      title: 'Pop Culture & Media',
      description: 'Test your trivia skills on blockbusters, TV shows, music, and creators.',
      icon: Icons.movie_creation_rounded,
      color: Color(0xFFF59E0B),
      questions: [
        Question(
          id: 'pc-1',
          text: 'Who played Iron Man / Tony Stark in the Marvel Cinematic Universe?',
          options: ['Chris Evans', 'Robert Downey Jr.', 'Chris Hemsworth', 'Mark Ruffalo'],
          correctOptionIndex: 1,
          points: 10,
          explanation: 'Robert Downey Jr. portrayed Tony Stark / Iron Man, starting with the 2008 film Iron Man, kickstarting the massive MCU franchise.',
        ),
        Question(
          id: 'pc-2',
          text: 'What is the name of the fictional continent in Game of Thrones?',
          options: ['Middle-earth', 'Essos', 'Westeros', 'Narnia'],
          correctOptionIndex: 2,
          points: 10,
          explanation: 'Most of the story in Game of Thrones takes place on the continent of Westeros, with some arcs happening in the eastern continent of Essos.',
        ),
        Question(
          id: 'pc-3',
          text: 'How many Academy Awards (Oscars) did the 1997 movie "Titanic" win?',
          options: ['9', '11', '13', '15'],
          correctOptionIndex: 1,
          points: 15,
          explanation: 'Titanic won 11 Academy Awards in 1998, tying the record with Ben-Hur for the most Oscar wins by a single film.',
        ),
        Question(
          id: 'pc-4',
          text: 'Which space opera movie features the iconic phrase "May the Force be with you"?',
          options: ['Star Trek', 'Dune', 'Star Wars', 'Interstellar'],
          correctOptionIndex: 2,
          points: 10,
          explanation: '"May the Force be with you" is one of the most famous quotes from the Star Wars franchise, used to wish good luck or safety to individuals.',
        ),
        Question(
          id: 'pc-5',
          text: 'Who is the creator of the Harry Potter book series?',
          options: ['J.R.R. Tolkien', 'George R.R. Martin', 'J.K. Rowling', 'C.S. Lewis'],
          correctOptionIndex: 2,
          points: 10,
          explanation: 'J.K. Rowling is the British author who wrote the seven-book Harry Potter fantasy series, which has sold over 600 million copies worldwide.',
        ),
      ],
    ),
  ];
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

  void startQuiz(QuizCategory category) {
    _timer?.cancel();
    state = QuizSessionState(
      category: category,
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
