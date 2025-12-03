// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/refferel/models/quiz_question.dart';
import 'package:quikle_rider/features/refferel/presentation/controller/quiz_controller.dart';
import 'package:quikle_rider/features/refferel/screens/quiz_result_page.dart';

class QuizSelectionPage extends StatefulWidget {
  const QuizSelectionPage({super.key});

  @override
  State<QuizSelectionPage> createState() => _QuizSelectionPageState();
}

class _QuizSelectionPageState extends State<QuizSelectionPage> {
  late final QuizController _controller;
  final RxBool _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<QuizController>()
        ? Get.find<QuizController>()
        : Get.put(QuizController());
    _controller.startQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: UnifiedProfileAppBar(
        
        title: 'Certification Quiz',
        showActionButton: false,
        isback: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = _controller.error.value;
        if (error != null && error.isNotEmpty) {
          return _ErrorState(message: error, onRetry: _controller.startQuiz);
        }

        final question = _controller.currentQuestion;
        if (question == null) {
          return _ErrorState(
            message: 'No quiz questions available.',
            onRetry: _controller.startQuiz,
          );
        }

        final total = _controller.questions.length;
        final currentIndex = _controller.currentIndex.value;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${currentIndex + 1} of $total',
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${(_controller.progressPercent * 100).round()}%',
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: LinearProgressIndicator(
                      value: _controller.progressPercent,
                      minHeight: 6.h,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryyellow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: [
                    _questionCard(question),
                    SizedBox(height: 16.h),
                    _navigationRow(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _questionCard(QuizQuestion question) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: getTextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 18.h),
          ...question.options.map((option) => _optionTile(option)),
        ],
      ),
    );
  }

  Widget _optionTile(QuizOption option) {
    final selected =
        _controller.selectedOptions[_controller.currentIndex.value];
    final isSelected = selected != null && selected.toUpperCase() == option.id;

    return GestureDetector(
      onTap: () => _controller.selectOption(option.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryyellow : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryyellow
                      : Colors.grey[500]!,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primaryyellow.withOpacity(0.12)
                    : null,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryyellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                option.text,
                style: getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navigationRow() {
    final isFirst = _controller.currentIndex.value == 0;
    final isLast = _controller.isLastQuestion;
    return SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.grey[600],
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              onPressed: isFirst ? null : _controller.goPrevious,
              child: Text(
                'Previous',
                style: getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: (!_controller.hasSelection || _isSubmitting.value)
                  ? null
                  : () {
                      if (isLast) {
                        _submitQuiz();
                      } else {
                        _controller.goNext();
                      }
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSubmitting.value) ...[
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Submitting...',
                      style: getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ).copyWith(color: AppColors.primaryyellow),
                    ),
                  ] else ...[
                    Text(
                      isLast ? 'Submit' : 'Next',
                      style: getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ).copyWith(color: AppColors.primaryyellow),
                    ),
                  ],
                  if (!isLast) ...[
                    SizedBox(width: 8.w),
                    const Icon(Iconsax.arrow_right_3, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuiz() async {
    _isSubmitting.value = true;
    final success = await _controller.submitQuiz();
    _isSubmitting.value = false;
    if (success) {
      Get.to(() => const QuizResultPage());
    } else {
      final err = _controller.error.value ?? 'Unable to submit quiz.';
      Get.snackbar(
        'Quiz',
        err,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.15),
        colorText: Colors.red[800],
      );
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
