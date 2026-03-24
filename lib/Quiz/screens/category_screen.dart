import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/Quiz/screens/question_screen.dart';
import 'package:sm_project/router/routes_names.dart';

import '../../utils/colors.dart';
import '../model/category.dart';
import '../selectedanswers_provider.dart';
import '../utils/progress_utils.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryProvider);
    final answers = ref.watch(selectedAnswersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      ///  APPBAR
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Select Category",
          style: GoogleFonts.poppins(
            color: Colors.white,fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: categoryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (err, _) => const Center(
          child: Text("Error loading categories"),
        ),

        data: (categories) {
          final completedCategories =
          getCompletedCategories(categories, answers);

          final totalCategories = categories.length;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 TITLE ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    /// 🔢 COUNT
                    Text(
                      "Lvl $completedCategories / $totalCategories",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// GRID
                Expanded(
                  child: GridView.builder(
                    itemCount: categories.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      mainAxisExtent: 195,
                    ),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final completed =
                      getCompletedSubCategories(cat, answers);
                      final total = cat.subCategories.length;

                      final isCategoryComplete = completed == total;

                      /// 🔥 STATUS LOGIC
                      final status = getStatus(completed, total,);
                      final progress = total == 0
                          ? 0.0
                          : completed / total;

                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(selectedCategoryProvider.notifier)
                              .state = cat.category;
                          context.pushNamed(
                              RouteNames.subcategoryQuiz, extra: cat);

                        },
                        /// ✨ TAP ANIMATION
                        child: TweenAnimationBuilder(
                          tween: Tween(begin: 1.0, end: 1.0),
                          duration: const Duration(milliseconds: 150),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },

                          child: Container(
                            padding: const EdgeInsets.all(12),
                            // padding: const EdgeInsets.all( 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 4),

                                /// ICON
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getCategoryBgColor(cat.category),
                                  ),
                                  child: Icon(
                                    getCategoryIcon(cat.category),
                                    size: 35,
                                    color: getCategoryColor(cat.category),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                /// TITLE
                                Text(
                                  cat.category.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                /// PROGRESS TEXT
                                Text(
                                  "$completed / $total",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),

                                // const SizedBox(height: 8),
                                //
                                // /// 📊 PROGRESS BAR
                                // ClipRRect(
                                //   borderRadius: BorderRadius.circular(10),
                                //   child: LinearProgressIndicator(
                                //     value: progress,
                                //     minHeight: 6,
                                //     backgroundColor: Colors.grey[200],
                                //     valueColor:
                                //     AlwaysStoppedAnimation<Color>(
                                //       isCategoryComplete
                                //           ? Colors.green
                                //           : Colors.orange,
                                //     ),
                                //   ),
                                // ),

                                const Spacer(),
                                // const SizedBox(height: 8),

                                /// 🔥 STATUS BADGE
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: status.bgColor,
                                    borderRadius:
                                    BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    status.text,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: status.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SubCategoryScreen extends ConsumerWidget {
  final CategoryModel category;

  const SubCategoryScreen({super.key, required this.category});

  /// ✅ Correct count function
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// ✅ answers yaha read karo
    final answers = ref.watch(selectedAnswersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor:darkBlue,
        title: Text(category.category.toUpperCase(),style: TextStyle(
          color: Colors.white,fontSize: 18,
        ),),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.subCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final sub = category.subCategories[index];

          /// ✅ correct/total calculate
          final correct = getCorrectCount(sub, answers);
          final total = sub.questions.length;
          final percentage = total == 0 ? 0 : (correct / total) * 100;
          final isCompleted = percentage >= 60;
          return GestureDetector(
            onTap: () {
              /// SAVE SUBCATEGORY
              ref.read(selectedSubCategoryProvider.notifier).state = sub;

              context.pushNamed(
                  RouteNames.questionscreen, );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => const QuestionScreen(),
              //   ),
              // );
            },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(2, 4),
                    ),
                  ],
                  // border: Border.all(
                  //   color: isCompleted ? Colors.green.shade300 : Colors.grey.shade200,
                  //   width: 1.2,
                  // ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// 📘 TITLE
                      Text(
                        sub.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 📊 SCORE BOX
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$correct / $total",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// ✅ STATUS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.timelapse,
                            color: isCompleted ? Colors.green : Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompleted ? "Completed" : "In Progress",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
          );
        },
      ),
    );
  }
}