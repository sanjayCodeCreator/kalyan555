import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sm_project/quiz2/leaderboard_notifier.dart';
import 'package:sm_project/quiz2/leaderboard_screen.dart';
import 'package:sm_project/utils/colors.dart';

import 'quiz_notifier.dart';

class MCQQuizScreen extends ConsumerStatefulWidget {
  final String sectionTitle;

  const MCQQuizScreen({
    super.key,
    required this.sectionTitle,
  });

  @override
  ConsumerState<MCQQuizScreen> createState() => _MCQQuizScreenState();
}

class _MCQQuizScreenState extends ConsumerState<MCQQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _cardController;
  Timer? _timer;
  int _timeLeft = 30;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  late ConfettiController _correctAnswerConfetti;
  late AnimationController _prevButtonController;
  late AnimationController _nextButtonController;
  late AnimationController _optionSelectionController;

  @override
  void initState() {
    super.initState();

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _optionSelectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _prevButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;

    _nextButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    _correctAnswerConfetti = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _startTimer();
    _cardController.forward();
    _timerController.forward();

    // Load sound effects
    _loadSounds();

    // Refresh leaderboard to update with new quiz points
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardProvider.notifier).refreshLeaderboard();
    });
  }

  Future<void> _loadSounds() async {
    // Pre-load sound effects for better performance
    await _audioPlayer.setSource(AssetSource('sound/clock_timer.wav'));
  }

  void _playSound(String soundName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource('sound/$soundName'));
      await _audioPlayer.resume();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;

          // Play clock timer sound for the entire quiz duration
          if (_timeLeft <= 30 && _timeLeft > 0) {
            _playSound('clock_timer.wav');
          }
        } else {
          _timer?.cancel();

          // Auto-move to next question when time runs out
          final quizState = ref.read(quizProvider);
          if (quizState.currentQuestionIndex < quizState.questions.length - 1) {
            _moveToNextQuestion();
          } else {
            _submitQuiz();
          }
        }
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 30;
    });
    _timerController.reset();
    _timerController.forward();
    _startTimer();
  }

  void _moveToNextQuestion() {
    _nextButtonController.forward(from: 0.95);
    _cardController.reset();
    ref.read(quizProvider.notifier).nextQuestion();
    _resetTimer();
    _cardController.forward();
    HapticFeedback.mediumImpact();
  }

  void _moveToPreviousQuestion() {
    _prevButtonController.forward(from: 0.95);
    _cardController.reset();
    ref.read(quizProvider.notifier).previousQuestion();
    _resetTimer();
    _cardController.forward();
    HapticFeedback.mediumImpact();
  }

  void _answerQuestion(int questionIndex, int optionIndex) {
    HapticFeedback.selectionClick();

    final quizState = ref.read(quizProvider);
    final currentQuestion = quizState.questions[questionIndex];

    ref.read(quizProvider.notifier).answerQuestion(questionIndex, optionIndex);

    // Play selection sound
    _playSound('select_option.mp3');

    // If answer is correct, show confetti
    if (currentQuestion.correctOptionIndex == optionIndex) {
      _correctAnswerConfetti.play();
      _playSound('correct_answer.mp3');
    }

    // Animate option selection
    _optionSelectionController.reset();
    _optionSelectionController.forward();
  }

  void _submitQuiz() {
    _nextButtonController.forward(from: 0.95);
    _timer?.cancel();
    ref.read(quizProvider.notifier).submitQuiz();
    HapticFeedback.heavyImpact();

    // Play celebration sound
    _playSound('victory');

    // Start confetti for celebration
    _confettiController.play();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerController.dispose();
    _cardController.dispose();
    _confettiController.dispose();
    _correctAnswerConfetti.dispose();
    _audioPlayer.dispose();
    _prevButtonController.dispose();
    _nextButtonController.dispose();
    _optionSelectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final isLastQuestion =
        quizState.currentQuestionIndex == quizState.questions.length - 1;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    if (quizState.isLoading) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0E27),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Loading Questions...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (quizState.questions.isEmpty) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0E27),
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B4B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    quizState.errorMessage.isNotEmpty
                        ? quizState.errorMessage
                        : 'No questions available.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (quizState.isQuizCompleted) {
      return ResultScreen(
        confettiController: _confettiController,
        onRestart: () {
          ref.read(quizProvider.notifier).resetQuiz();
          _resetTimer();
        },
      );
    }

    final currentQuestion = quizState.questions[quizState.currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xff142318),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Color(0xfffeb800), width: 2),
            ),
            title: const Text(
              'Quit Quiz?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to quit? Your progress will be lost.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continue Quiz'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Quit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1E1B4B),
            ],
          ),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                widget.sectionTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.3,
                ),
              ),
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Q ${quizState.currentQuestionIndex + 1}/${quizState.questions.length}',
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    // Timer bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _timeLeft / 30,
                          backgroundColor: const Color(0xFF374151),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeLeft > 10
                                ? const Color(0xFF10B981)
                                : _timeLeft > 5
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFEF4444),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1B4B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (_timeLeft > 10
                                    ? const Color(0xFF10B981)
                                    : _timeLeft > 5
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444))
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              color: _timeLeft > 10
                                  ? const Color(0xFF10B981)
                                  : _timeLeft > 5
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFEF4444),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_timeLeft s',
                              style: TextStyle(
                                color: _timeLeft > 10
                                    ? const Color(0xFF10B981)
                                    : _timeLeft > 5
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Question card
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                          child: FadeTransition(
                            opacity: _cardController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _cardController,
                                curve: Curves.easeOut,
                              )),
                              child: Column(
                                children: [
                                  // Question
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1B4B),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF6366F1)
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF6366F1),
                                                Color(0xFF8B5CF6)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Question ${quizState.currentQuestionIndex + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          currentQuestion.question,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isSmallScreen ? 16 : 18,
                                            fontWeight: FontWeight.w600,
                                            height: 1.4,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Options
                                  ...List.generate(
                                    currentQuestion.options.length,
                                    (index) => ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.98,
                                        end: 1.0,
                                      ).animate(CurvedAnimation(
                                        parent: _cardController,
                                        curve: Interval(
                                          0.2 + (index * 0.1),
                                          1.0,
                                          curve: Curves.easeOut,
                                        ),
                                      )),
                                      child: OptionButton(
                                        option: currentQuestion.options[index],
                                        optionIndex: index,
                                        isSelected: currentQuestion
                                                .selectedOptionIndex ==
                                            index,
                                        onTap: () => _answerQuestion(
                                            quizState.currentQuestionIndex,
                                            index),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous button
                          quizState.currentQuestionIndex > 0
                              ? Flexible(
                                  child: ScaleTransition(
                                    scale: _prevButtonController,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          splashColor:
                                              Colors.white.withOpacity(0.1),
                                          onTap: _moveToPreviousQuestion,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.arrow_back_rounded,
                                                  size: isSmallScreen ? 16 : 18,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Previous',
                                                  style: TextStyle(
                                                    fontSize:
                                                        isSmallScreen ? 12 : 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),

                          // Question indicator
                          Flexible(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    quizState.questions.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index ==
                                                quizState.currentQuestionIndex
                                            ? const Color(0xFF6366F1)
                                            : quizState.questions[index]
                                                        .selectedOptionIndex !=
                                                    null
                                                ? const Color(0xFF10B981)
                                                : Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Next/Submit button
                          Flexible(
                            child: ScaleTransition(
                              scale: _nextButtonController,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isLastQuestion
                                        ? [
                                            const Color(0xFF10B981),
                                            const Color(0xFF059669)
                                          ]
                                        : [
                                            const Color(0xFF6366F1),
                                            const Color(0xFF8B5CF6)
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isLastQuestion
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF6366F1))
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    splashColor: Colors.white.withOpacity(0.1),
                                    onTap: isLastQuestion
                                        ? _submitQuiz
                                        : _moveToNextQuestion,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isLastQuestion
                                                ? Icons.check_rounded
                                                : Icons.arrow_forward_rounded,
                                            size: isSmallScreen ? 16 : 18,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isLastQuestion ? 'Submit' : 'Next',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Confetti for correct answers
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _correctAnswerConfetti,
                    blastDirection: math.pi / 2,
                    maxBlastForce: 4,
                    minBlastForce: 1,
                    emissionFrequency: 0.03,
                    numberOfParticles: 10,
                    gravity: 0.1,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                      Color(0xfffeb800),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String option;
  final int optionIndex;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.option,
    required this.optionIndex,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final optionLetters = ['A', 'B', 'C', 'D'];
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1).withOpacity(0.2)
              : const Color(0xFF1E1B4B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFF6366F1).withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 28 : 32,
              height: isSmallScreen ? 28 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : const Color(0xFF6366F1).withOpacity(0.2),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFF6366F1).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  optionLetters[optionIndex],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.3,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends ConsumerStatefulWidget {
  final ConfettiController confettiController;
  final VoidCallback onRestart;

  const ResultScreen({
    super.key,
    required this.confettiController,
    required this.onRestart,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playVictorySound();

    // Refresh leaderboard to update with new quiz points
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardProvider.notifier).refreshLeaderboard();
    });
  }

  void _playVictorySound() async {
    try {
      await _audioPlayer.setSource(AssetSource('sound/victory.mp3'));
      await _audioPlayer.resume();
    } catch (e) {
      print('Error playing victory sound: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final result = quizState.result!;

    final percentage = (result.correctAnswers / result.totalQuestions) * 100;
    final Color resultColor = percentage >= 80
        ? Colors.green
        : percentage >= 60
            ? const Color(0xfffeb800)
            : percentage >= 40
                ? Colors.orange
                : Colors.red;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E27),
            Color(0xFF1E1B4B),
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Quiz Results',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: 0.3,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              // Confetti animation
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: widget.confettiController,
                  blastDirection: math.pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 1,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Color(0xfffeb800),
                  ],
                ),
              ),

              // Results content
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Trophy animation for winners
                    if (percentage >= 60)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      )
                    else
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.red,
                          size: 60,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Score card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: resultColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            percentage >= 80
                                ? 'Excellent!'
                                : percentage >= 60
                                    ? 'Good Job!'
                                    : percentage >= 40
                                        ? 'Nice Try!'
                                        : 'Keep Practicing!',
                            style: TextStyle(
                              color: resultColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Your Score',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${result.points}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                ' pts',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildModernResultStat(
                                '${result.correctAnswers}/${result.totalQuestions}',
                                'Correct',
                                Icons.check_circle_rounded,
                                const Color(0xFF10B981),
                              ),
                              _buildModernResultStat(
                                '${result.totalQuestions - result.correctAnswers}/${result.totalQuestions}',
                                'Wrong',
                                Icons.cancel_rounded,
                                const Color(0xFFEF4444),
                              ),
                              _buildModernResultStat(
                                '${percentage.toStringAsFixed(0)}%',
                                'Accuracy',
                                Icons.analytics_rounded,
                                const Color(0xFF6366F1),
                              ),
                            ],
                          ),
                          if (percentage >= 60) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF10B981).withOpacity(0.2),
                                    const Color(0xFF059669).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      const Color(0xFF10B981).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF10B981),
                                          Color(0xFF059669)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Award Earned: ${result.award}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Congratulations! You\'ve earned a reward for your performance.',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 13,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // More questions message
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6366F1).withOpacity(0.2),
                                  const Color(0xFF8B5CF6).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.psychology_rounded,
                                  color: Color(0xFF6366F1),
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Want to test your knowledge more?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Press "Play Again" to get a new set of questions every day so you can improve your knowledge.',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Question summary
                    const Text(
                      'Question Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      quizState.questions.length,
                      (index) {
                        final question = quizState.questions[index];
                        final isCorrect = question.selectedOptionIndex ==
                            question.correctOptionIndex;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCorrect
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          isCorrect ? Colors.green : Colors.red,
                                    ),
                                    child: Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      question.question,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Your Answer: ${question.selectedOptionIndex != null ? question.options[question.selectedOptionIndex!] : 'Not answered'}',
                                style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!isCorrect) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Correct Answer: ${question.options[question.correctOptionIndex]}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),

                    // Bottom buttons
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 400),
                                  pageBuilder: (_, __, ___) =>
                                      const LeaderboardScreen(),
                                  transitionsBuilder:
                                      (_, animation, __, child) =>
                                          SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    )),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.leaderboard_rounded,
                              color: Color(0xFF10B981),
                              size: 18,
                            ),
                            label: const Text(
                              'Leaderboard',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.onRestart();
                            },
                            icon: const Icon(
                              Icons.replay_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Play Again',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernResultStat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
