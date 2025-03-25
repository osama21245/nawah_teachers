class AnswerModel {
  final String answerText;
  final bool isCorrect;

  const AnswerModel({
    required this.answerText,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() {
    return {
      'answerText': answerText,
      'isCorrect': isCorrect,
    };
  }

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      answerText: json['answerText'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }

  AnswerModel copyWith({
    String? answerText,
    bool? isCorrect,
  }) {
    return AnswerModel(
      answerText: answerText ?? this.answerText,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}
