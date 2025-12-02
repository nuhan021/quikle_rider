class QuizQuestion {
  QuizQuestion({
    this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.explanation,
    List<QuizOption>? options,
  }) : options = options ??
          <QuizOption>[
            QuizOption(id: 'A', text: optionA),
            QuizOption(id: 'B', text: optionB),
            QuizOption(id: 'C', text: optionC),
            QuizOption(id: 'D', text: optionD),
          ];

  final int? id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String explanation;
  final List<QuizOption> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    List<QuizOption>? parsedOptions;
    if (rawOptions is List) {
      parsedOptions = rawOptions
          .whereType<Map<String, dynamic>>()
          .map(
            (opt) => QuizOption(
              id: opt['key']?.toString() ?? '',
              text: opt['text']?.toString() ?? '',
            ),
          )
          .where((opt) => opt.id.isNotEmpty && opt.text.isNotEmpty)
          .toList();
    }

    return QuizQuestion(
      id: (json['id'] as num?)?.toInt(),
      question: json['question']?.toString() ?? '',
      optionA: json['option_a']?.toString() ?? '',
      optionB: json['option_b']?.toString() ?? '',
      optionC: json['option_c']?.toString() ?? '',
      optionD: json['option_d']?.toString() ?? '',
      correctAnswer: json['correct_answer']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      options: parsedOptions,
    );
  }
}

class QuizOption {
  QuizOption({required this.id, required this.text});

  final String id;
  final String text;
}
