



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/category.dart';
import '../model/status_model.dart';
import '../selectedanswers_provider.dart';

/// ✅ SubCategory Completion
int getCompletedSubCategories(
    CategoryModel category,
    List<SelectedAnswer> answers,
    ) {
  int completed = 0;

  for (var sub in category.subCategories) {
    int correct = 0;
    int total = sub.questions.length;

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

    double percentage = total == 0 ? 0 : (correct / total) * 100;

    if (percentage >= 60) {
      completed++;
    }
  }

  return completed;
}

/// ✅ Category Completion
int getCompletedCategories(
    List<CategoryModel> categories,
    List<SelectedAnswer> answers,
    ) {
  int completedCategories = 0;

  for (var cat in categories) {
    int completedSub = getCompletedSubCategories(cat, answers);

    /// ✅ reuse above function 🔥
    if (completedSub == cat.subCategories.length) {
      completedCategories++;
    }
  }

  return completedCategories;
}
Color getCategoryBgColor(String category) {
  final baseColor = getCategoryColor(category);

  return baseColor.withOpacity(0.12); // ✅ soft background
}
IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case "technical":
      return Icons.computer; // better than computer (tech feel)

    case "historical":
      return Icons.history_edu; // monument / history vibe

    case "gk":
      return Icons.language; // world / knowledge

    case "maths":
      return Icons.functions; // maths specific (better than calculate)

    case "science":
      return Icons.biotech; // modern science icon

    case "agriculture":
      return Icons.eco; // leaf/nature (clean look)

    default:
      return Icons.quiz; // fallback
  }
}
Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case "technical":
      return const Color(0xFF2979FF); // vibrant blue

    case "historical":
      return const Color(0xFFE53935); // vibrant red

    case "gk":
      return const Color(0xFFAB47BC); // softer purple

    case "maths":
      return const Color(0xFFFF9800); // bright orange

    case "science":
      return const Color(0xFF00C853); // fresh green

    case "agriculture":
      return const Color(0xFF00ACC1); // cyan-teal (fresh look)

    default:
      return const Color(0xFF0F5C81); // blue grey
  }
}
StatusModel getStatus(int completed, int total, ) {
  if (completed == 0) {
    return StatusModel(
      text: "Start",
      color: Colors.blue,
      bgColor: Colors.blue.withOpacity(0.1),
    );
  } else if (completed == total) {
    return StatusModel(
      text: "Completed",
      color: Colors.green,
      bgColor: Colors.green.withOpacity(0.1),
    );
  } else {
    return StatusModel(
      text: "In Progress",
      color: Colors.orange,
      bgColor: Colors.orange.withOpacity(0.1),
    );
  }
}