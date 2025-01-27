import 'dart:convert';

class QuizModel {
  final String? id;
  final String title;
  final String description;
  final String teacherId;
  final List<QuestionModel> questions;

  QuizModel({
    this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'teacher_id': teacherId,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id']?.toString(),
      title: map['title'],
      description: map['description'],
      teacherId: map['teacher_id'].toString(),
      questions: (map['questions'] as List)
          .map((q) => QuestionModel.fromMap(q))
          .toList(),
    );
  }
}

class QuestionModel {
  final String questionText;
  final List<AnswerModel> answers;

  QuestionModel({
    required this.questionText,
    required this.answers,
  });

  Map<String, dynamic> toMap() {
    return {
      'question_text': questionText,
      'answers': answers.map((a) => a.toMap()).toList(),
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      questionText: map['question_text'],
      answers:
          (map['answers'] as List).map((a) => AnswerModel.fromMap(a)).toList(),
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
      'is_correct': isCorrect,
    };
  }

  factory AnswerModel.fromMap(Map<String, dynamic> map) {
    return AnswerModel(
      answerText: map['answer_text'],
      isCorrect: map['is_correct'],
    );
  }
}
