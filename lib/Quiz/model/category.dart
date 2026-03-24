
import '../selectedanswers_provider.dart';

class CategoryModel {
  final String category;
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.category,
    required this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      category: json['category'],
      subCategories: (json['subCategories'] as List)
          .map((e) => SubCategoryModel.fromJson(e))
          .toList(),
    );
  }
}
class SubCategoryModel {
  final String id;
  final String name;
  final List<QuestionModel> questions;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.questions,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'],
      name: json['name'],
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q))
          .toList(),
    );
  }
  int getCorrectCount(
      SubCategoryModel sub,
      List<SelectedAnswer> answers,
      ) {
    int correct = 0;

    for (var q in sub.questions) {
      final ans = answers.firstWhere(
            (a) =>
        a.questionId == q.id &&
            a.subCategoryId == sub.id,
        orElse: () => SelectedAnswer(
          questionId: '',
          selectedIndex: -1,
          subCategoryId: '',
        ),
      );

      if (ans.selectedIndex == q.correctAnswerIndex) {
        correct++;
      }
    }

    return correct;
  }
}
class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }

  List<String> shuffleAnswers() {
    final shuffled = List.of(options);
    shuffled.shuffle();
    return shuffled;
  }

  /// ✅ Get correct answer string
  String get correctAnswer => options[correctAnswerIndex];
}
class AnswerOption {
  final String text;
  final bool isCorrect;

  AnswerOption({required this.text, required this.isCorrect});
}