import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';

import 'mcq_question_answer.dart';

// Quiz section model
class QuizSection {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int questionsCount;

  QuizSection({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.questionsCount = 10, // Default to 10 questions
  });
}

// Quiz question model
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final int? selectedOptionIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.selectedOptionIndex,
  });

  QuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctOptionIndex,
    int? selectedOptionIndex,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
    );
  }
}

// Quiz result model
class QuizResult {
  final int correctAnswers;
  final int totalQuestions;
  final int points;
  final String award;

  QuizResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.points,
    required this.award,
  });
}

// Quiz state
class QuizState {
  final bool isLoading;
  final String errorMessage;
  final List<QuizSection> sections;
  final List<QuizQuestion> questions;
  final QuizResult? result;
  final int currentQuestionIndex;
  final bool isQuizCompleted;

  QuizState({
    this.isLoading = false,
    this.errorMessage = '',
    this.sections = const [],
    this.questions = const [],
    this.result,
    this.currentQuestionIndex = 0,
    this.isQuizCompleted = false,
  });

  QuizState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<QuizSection>? sections,
    List<QuizQuestion>? questions,
    QuizResult? result,
    int? currentQuestionIndex,
    bool? isQuizCompleted,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
      questions: questions ?? this.questions,
      result: result ?? this.result,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isQuizCompleted: isQuizCompleted ?? this.isQuizCompleted,
    );
  }
}

// Quiz notifier
class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(QuizState()) {
    loadQuizSections();
  }

  // Load quiz sections
  Future<void> loadQuizSections() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');

      // Mock data - in real app, fetch from API
      final sections = [
        QuizSection(
          id: '1',
          title: 'General Knowledge',
          description:
              'Test your General Knowledge with these challenging questions',
          imageUrl: 'assets/images/gk.jpg',
          questionsCount: 15,
        ),
        QuizSection(
          id: '2',
          title: 'World History',
          description: 'Everything about World History and records',
          imageUrl: 'assets/images/wh.jpg',
          questionsCount: 12,
        ),
        QuizSection(
          id: '3',
          title: 'Science & Technology',
          description: 'Test your knowledge about Science & Technology',
          imageUrl: 'assets/images/st.jpg',
          questionsCount: 18,
        ),
        QuizSection(
          id: '4',
          title: 'Current Affairs',
          description: 'How well do you know the Current Affairs?',
          imageUrl: 'assets/images/ca.jpg',
          questionsCount: 10,
        ),
      ];

      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      state = state.copyWith(isLoading: false, sections: sections);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load quiz sections: ${e.toString()}',
      );
    }
  }

  // Load quiz questions for a section
  Future<void> loadQuizQuestions(String sectionId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: '',
        currentQuestionIndex: 0,
        isQuizCompleted: false,
        result: null,
      );

      // Get 10 random questions from our question bank for the selected section
      final mcqQuestions =
          QuizQuestionBank.getRandomQuestionsForSection(sectionId, 10);

      // Convert MCQQuestion to QuizQuestion
      final questions = mcqQuestions
          .map((mcq) => QuizQuestion(
                id: mcq.id,
                question: mcq.question,
                options: mcq.options,
                correctOptionIndex: mcq.correctOptionIndex,
              ))
          .toList();

      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      state = state.copyWith(isLoading: false, questions: questions);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load quiz questions: ${e.toString()}',
      );
    }
  }

  // Answer a question
  void answerQuestion(int questionIndex, int selectedOptionIndex) {
    if (questionIndex < 0 || questionIndex >= state.questions.length) return;

    final updatedQuestions = [...state.questions];
    updatedQuestions[questionIndex] = updatedQuestions[questionIndex].copyWith(
      selectedOptionIndex: selectedOptionIndex,
    );

    state = state.copyWith(questions: updatedQuestions);
  }

  // Move to next question
  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state =
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  // Move to previous question
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state =
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  // Submit quiz and calculate results
  void submitQuiz() {
    int correctAnswers = 0;
    int totalPoints = 0;

    for (var question in state.questions) {
      if (question.selectedOptionIndex == question.correctOptionIndex) {
        correctAnswers++;
        totalPoints += 10; // 10 points per correct answer
      }
    }

    String award = 'Participant';
    if (correctAnswers >= 8) {
      award = 'Champion';
    } else if (correctAnswers >= 6) {
      award = 'Expert';
    } else if (correctAnswers >= 4) {
      award = 'Enthusiast';
    }

    final result = QuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: state.questions.length,
      points: totalPoints,
      award: award,
    );

    // Store quiz points and date locally
    _saveQuizPointsLocally(totalPoints);

    state = state.copyWith(
      isQuizCompleted: true,
      result: result,
    );
  }

  // Save quiz points to local storage
  void _saveQuizPointsLocally(int points) {
    // Only save if points are higher than previously stored points
    int? existingPoints = Prefs.getInt(PrefNames.quizPoints) ?? 0;
    if (points > existingPoints) {
      Prefs.setInt(PrefNames.quizPoints, points);
    }

    // Store the current date as last quiz date
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Prefs.setString(PrefNames.lastQuizDate, today);
  }

  // Reset quiz
  void resetQuiz() {
    // Load a new set of random questions for the current section
    final currentSectionId = _getCurrentSectionId();
    if (currentSectionId != null) {
      loadQuizQuestions(currentSectionId);
    } else {
      state = state.copyWith(
        currentQuestionIndex: 0,
        isQuizCompleted: false,
        result: null,
        questions: state.questions
            .map((q) => q.copyWith(selectedOptionIndex: null))
            .toList(),
      );
    }
  }

  // Helper method to identify the current section ID
  String? _getCurrentSectionId() {
    if (state.questions.isEmpty) return null;

    // Try to determine the section based on the first question ID prefix
    final firstQuestionId = state.questions.first.id;
    if (firstQuestionId.startsWith('gk')) return '1';
    if (firstQuestionId.startsWith('wh')) return '2';
    if (firstQuestionId.startsWith('st')) return '3';
    if (firstQuestionId.startsWith('ca')) return '4';

    return null;
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});
