import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/quiz_model.dart';
import '../../../data/repository/quizzes_repository.dart';
import 'add_quiz_state.dart';

class AddQuizCubit extends Cubit<AddQuizState> {
  final QuizzesRepository quizzesRepository;

  AddQuizCubit(this.quizzesRepository) : super(const AddQuizState());

  void updateTitle(String title) {
    String? titleError;
    if (title.isEmpty) {
      titleError = 'Title is required';
    } else if (title.length < 3) {
      titleError = 'Title must be at least 3 characters';
    } else if (title.length > 100) {
      titleError = 'Title must be less than 100 characters';
    }
    emit(state.copyWith(title: title, titleError: titleError));
  }

  void addQuestion(QuestionModel question) {
    final updatedQuestions = List<QuestionModel>.from(state.questions)
      ..add(question);
    emit(state.copyWith(questions: updatedQuestions));
  }

  void updateQuestion(int index, QuestionModel question) {
    final updatedQuestions = List<QuestionModel>.from(state.questions);
    updatedQuestions[index] = question;
    emit(state.copyWith(questions: updatedQuestions));
  }

  void removeQuestion(int index) {
    final updatedQuestions = List<QuestionModel>.from(state.questions)
      ..removeAt(index);
    emit(state.copyWith(questions: updatedQuestions));
  }

  Future<void> saveQuiz(String teacherId) async {
    if (!_isValid()) {
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    final quiz = QuizModel(
      title: state.title,
      description: '', // You might want to add description field later
      questions: state.questions,
    );

    final result = await quizzesRepository.addQuiz(quiz, teacherId);
    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
      (quiz) {
        emit(state.copyWith(
          isLoading: false,
          error: null,
        ));
      },
    );
  }

  bool _isValid() {
    if (state.title.isEmpty) {
      emit(state.copyWith(titleError: 'Title is required'));
      return false;
    }
    if (state.title.length < 3) {
      emit(state.copyWith(titleError: 'Title must be at least 3 characters'));
      return false;
    }
    if (state.title.length > 100) {
      emit(
          state.copyWith(titleError: 'Title must be less than 100 characters'));
      return false;
    }
    if (state.questions.isEmpty) {
      emit(state.copyWith(error: 'Add at least one question'));
      return false;
    }
    return true;
  }
}
