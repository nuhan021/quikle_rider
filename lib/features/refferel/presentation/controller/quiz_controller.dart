import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';
import 'package:quikle_rider/features/refferel/models/quiz_question.dart';

class QuizController extends GetxController {
  QuizController({ProfileServices? profileServices})
    : _profileServices = profileServices ?? ProfileServices();

  final ProfileServices _profileServices;

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final RxList<QuizQuestion> questions = <QuizQuestion>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxMap<int, String> selectedOptions = <int, String>{}.obs;
  final RxBool isSubmitting = false.obs;
  final RxnInt attemptId = RxnInt();
  final RxnInt lastScore = RxnInt();
  final RxnInt lastCorrect = RxnInt();
  final RxnInt lastTotal = RxnInt();
  final RxBool lastPassed = false.obs;

  double get progressPercent {
    if (questions.isEmpty) return 0;
    return (currentIndex.value + 1) / questions.length;
  }

  QuizQuestion? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex.value];

  int get correctCount {
    if (questions.isEmpty) return 0;
    int count = 0;
    for (var i = 0; i < questions.length; i++) {
      final selected = selectedOptions[i];
      if (selected != null &&
          selected.toUpperCase() == questions[i].correctAnswer.toUpperCase()) {
        count++;
      }
    }
    return count;
  }

  double get scorePercent =>
      questions.isEmpty ? 0 : correctCount / questions.length;

  Future<void> startQuiz() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      error.value = 'Missing credentials. Please login again.';
      return;
    }

    isLoading.value = true;
    error.value = null;
    selectedOptions.clear();
    currentIndex.value = 0;
    try {
      final response = await _profileServices.startQuiz(
        accessToken: accessToken,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        if (body is List) {
          final parsed = body
              .whereType<Map<String, dynamic>>()
              .map(QuizQuestion.fromJson)
              .toList();
          if (parsed.isNotEmpty) {
            questions.assignAll(parsed);
          } else {
            error.value = 'No quiz questions available.';
          }
        } else if (body is Map<String, dynamic>) {
          final payloadQuestions = body['questions'];
          if (payloadQuestions is List) {
            final parsed = payloadQuestions
                .whereType<Map<String, dynamic>>()
                .map(QuizQuestion.fromJson)
                .toList();
            questions.assignAll(parsed);
          } else {
            questions.assignAll([QuizQuestion.fromJson(body)]);
          }
          if (body['attempt_id'] != null) {
            attemptId.value = int.tryParse(body['attempt_id'].toString());
          }
        } else {
          error.value = 'Unexpected quiz response.';
        }
      } else {
        error.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to start quiz.';
      }
    } catch (e) {
      error.value = 'Unable to start quiz.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectOption(String optionId) {
    selectedOptions[currentIndex.value] = optionId.toUpperCase();
  }

  bool get hasSelection => selectedOptions[currentIndex.value]?.isNotEmpty == true;

  bool get isLastQuestion =>
      questions.isNotEmpty && currentIndex.value == questions.length - 1;

  void goNext() {
    if (isLastQuestion) return;
    currentIndex.value++;
  }

  void goPrevious() {
    if (currentIndex.value == 0) return;
    currentIndex.value--;
  }

  void resetQuiz() {
    questions.clear();
    selectedOptions.clear();
    currentIndex.value = 0;
    error.value = null;
    attemptId.value = null;
    lastScore.value = null;
    lastCorrect.value = null;
    lastTotal.value = null;
    lastPassed.value = false;
  }

  Future<bool> submitQuiz() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      error.value = 'Missing credentials. Please login again.';
      return false;
    }

    if (questions.isEmpty) {
      error.value = 'No quiz to submit.';
      return false;
    }

    isSubmitting.value = true;
    try {
      final answers = <String, dynamic>{};
      for (var i = 0; i < questions.length; i++) {
        final selected = selectedOptions[i];
        final questionKey = questions[i].answerKey;
        if (selected != null && questionKey != null) {
          answers[questionKey] = selected.toUpperCase();
        }
      }

      final payload = <String, dynamic>{}
        ..addAll(answers)
        ..addAll({
          if (attemptId.value != null) 'attempt_id': attemptId.value,
        });

      final response = await _profileServices.submitQuiz(
        accessToken: accessToken,
        payload: payload,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final body = response.responseData as Map<String, dynamic>;
        attemptId.value = body['attempt_id'] is int
            ? body['attempt_id'] as int
            : int.tryParse(body['attempt_id']?.toString() ?? '');
        lastScore.value = (body['score'] as num?)?.toInt();
        lastCorrect.value = (body['correct'] as num?)?.toInt();
        lastTotal.value = (body['total'] as num?)?.toInt();
        lastPassed.value = body['passed'] == true;
        return true;
      } else {
        error.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to submit quiz.';
        return false;
      }
    } catch (_) {
      error.value = 'Unable to submit quiz.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
