import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/router/routes_names.dart';


import '../../utils/colors.dart';
import '../selectedanswers_provider.dart';
import 'category_screen.dart';
class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({super.key});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionState();
}

class _QuestionState extends ConsumerState<QuestionScreen> {
  int currentIndex = 0;
  bool isAnswered = false;

  void selectAnswer(int selectedIndex) {
    if (isAnswered) return;
    isAnswered = true;

    final questions = ref.read(questionsProvider);
    final currentQuestion = questions[currentIndex];


    print("selectAnswer questions ${questions.toString()} currentQuestion -->${currentQuestion} selectedIndex ${selectedIndex}");
    /// ✅ GET SUBCATEGORY
    final subCategory = ref.read(selectedSubCategoryProvider);
    print("selectAnswer questions ${subCategory}");

    /// SAVE ANSWER
    ref.read(selectedAnswersProvider.notifier).chooseAnswer(
      currentQuestion.id,
      selectedIndex,
      subCategory!.id,
    );

    /// NEXT / RESULT
    Future.delayed(const Duration(milliseconds: 300), () {
      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          isAnswered = false;
        });
      } else {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => const ResultScreen(),
        //   ),
        // );
        context.pushReplacementNamed(RouteNames.resultscreen);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsProvider);

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No Questions Found")),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Quiz",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔢 HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Question ${currentIndex + 1}/${questions.length}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${((currentIndex + 1) / questions.length * 100).toInt()}%",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                        color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// 📊 PROGRESS BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / questions.length,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green.shade400,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// ❓ QUESTION CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// 🧠 OPTIONS
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        selectAnswer(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            /// OPTION INDEX (A,B,C,D)
                            Container(
                              height: 30,
                              width: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// OPTION TEXT
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 16, color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final answers = ref.watch(selectedAnswersProvider);

    /// ✅ Convert answers list -> Map (questionId based)
    final answerMap = {
      for (var a in answers) a.questionId: a
    };

    /// ✅ Correct Score Calculation
    int score = 0;
    for (final q in questions) {
      final answer = answerMap[q.id];

      if (answer != null &&
          answer.selectedIndex == q.correctAnswerIndex) {
        score++;
      }
    }
    return WillPopScope(
      onWillPop: () async {
        context.goNamed(RouteNames.mainScreen);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: darkBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.goNamed(RouteNames.mainScreen);            },
          ),
          centerTitle: true,
          foregroundColor: Colors.black,
          title: const Text("Result",style: TextStyle(
            color: Colors.white,fontSize: 18,
            // color: Colors.black,
          ),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// 🏆 SCORE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 40,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your Score",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$score / ${questions.length}",
                      style: const TextStyle(
                        fontSize: 26, color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 📋 ANSWERS LIST
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final answer = answerMap[question.id];
                    final selectedAnswerIndex = answer?.selectedIndex;

                    final isCorrect =
                        selectedAnswerIndex == question.correctAnswerIndex;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCorrect
                              ? Colors.green.shade300
                              : Colors.red.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ❓ QUESTION
                          Text(
                            question.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,  color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// 🧠 YOUR ANSWER
                          Text(
                            selectedAnswerIndex != null
                                ? "Your answer: ${question.options[selectedAnswerIndex]}"
                                : "You didn't answer",
                            style: TextStyle(
                              color:
                              isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 4),

                          /// ✅ CORRECT ANSWER
                          Text(
                            "Correct: ${question.options[question.correctAnswerIndex]}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              /// 🔁 RESTART BUTTON
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       ref.read(selectedAnswersProvider.notifier).restart();
              //
              //       Navigator.pushAndRemoveUntil(
              //         context,
              //         MaterialPageRoute(
              //             builder: (_) => const CategoryScreen()),
              //             (route) => false,
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       padding:
              //       const EdgeInsets.symmetric(vertical: 14),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     child: const Text("Restart Quiz"),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}