// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/refferel/presentation/controller/quiz_controller.dart';
import 'package:quikle_rider/features/refferel/screens/quiz_selection_page.dart';

class QuizResultPage extends StatelessWidget {
  const QuizResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizController>();
    final score = controller.lastScore.value ?? (controller.scorePercent * 100).round();
    final total = controller.lastTotal.value ?? controller.questions.length;
    final correct = controller.lastCorrect.value ?? controller.correctCount;
    final isPassed = controller.lastPassed.value;
    const passMark = 80;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const UnifiedProfileAppBar(title: 'Quiz Results'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 68.w,
                    height: 68.w,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 42,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Congratulations!',
                    style: getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "You've passed the certification quiz\nwith ${score}%",
                    style: getTextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18.h),
                  _scoreCard(
                    score: score,
                    passMark: passMark,
                    correct: correct,
                    total: total,
                  ),
                  SizedBox(height: 18.h),
                  _statusButton(isPassed),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () {
                            controller.resetQuiz();
                            Get.off(() => const QuizSelectionPage());
                          },
                          child: Text(
                            'Retake',
                            style: getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: Text(
                            'Done',
                            style: getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ).copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreCard({
    required int score,
    required int passMark,
    required int correct,
    required int total,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          _scoreRow(label: 'Your Score', value: '$score%'),
          SizedBox(height: 8.h),
          _scoreRow(label: 'Pass Mark', value: '$passMark%'),
          SizedBox(height: 8.h),
          _scoreRow(label: 'Correct Answers', value: '$correct / $total'),
        ],
      ),
    );
  }

  Widget _scoreRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _statusButton(bool passed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: passed ? AppColors.greenbutton2 : Colors.orange,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 0,
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.verify5, color: Colors.white, size: 18),
          SizedBox(width: 8.w),
          Text(
            passed ? 'Certified Partner' : 'Review Needed',
            style: getTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ).copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
