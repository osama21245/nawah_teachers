class QuizModel {
  final String? id;
  final String title;
  final String description;
  final List<QuestionModel> questions;

  QuizModel({
    this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      questions: (map['questions'] as List?)
              ?.map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuestionModel {
  final String questionText;
  final List<AnswerModel> answers;
  final String? imageUrl;
  final bool isWrittenQuestion;

  QuestionModel({
    required this.questionText,
    required this.answers,
    this.imageUrl,
    this.isWrittenQuestion = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'question_text': questionText,
      'answers': answers.map((a) => a.toMap()).toList(),
      'image_url': imageUrl,
      'is_written_question': isWrittenQuestion ? 1 : 0,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      questionText: map['question_text'] ?? '',
      answers: (map['answers'] as List?)
              ?.map((a) => AnswerModel.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      imageUrl: map['image_url'],
      isWrittenQuestion: map['is_written_question'] == 1,
    );
  }
}

class AnswerModel {
  final String answerText;
  final bool isCorrect;

  AnswerModel({
    required this.answerText,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'answer_text': answerText,
      'is_correct': isCorrect ? 1 : 0,
    };
  }

  factory AnswerModel.fromMap(Map<String, dynamic> map) {
    return AnswerModel(
      answerText: map['answer_text'] ?? '',
      isCorrect: map['is_correct'] == 1 || map['is_correct'] == true,
    );
  }
}
