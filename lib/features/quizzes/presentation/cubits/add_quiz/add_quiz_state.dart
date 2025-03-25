import 'package:equatable/equatable.dart';
import '../../../data/model/quiz_model.dart';

class AddQuizState extends Equatable {
  final String title;
  final String? titleError;
  final List<QuestionModel> questions;
  final bool isLoading;
  final String? error;

  const AddQuizState({
    this.title = '',
    this.titleError,
    this.questions = const [],
    this.isLoading = false,
    this.error,
  });

  AddQuizState copyWith({
    String? title,
    String? titleError,
    List<QuestionModel>? questions,
    bool? isLoading,
    String? error,
  }) {
    return AddQuizState(
      title: title ?? this.title,
      titleError: titleError,
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [title, titleError, questions, isLoading, error];
}
