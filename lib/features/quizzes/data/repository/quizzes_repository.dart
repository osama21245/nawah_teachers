import 'package:fpdart/fpdart.dart';

import '../../../../core/erorr/failure.dart';
import '../../../../core/utils/try_and_catch.dart';
import '../data_souce/quizzes_remote_data_souce.dart';
import '../model/quiz_model.dart';

class QuizzesRepository {
  final QuizzesRemoteDataSouce remoteDataSouce;

  QuizzesRepository(this.remoteDataSouce);

  Future<Either<Failure, QuizModel>> addQuiz(
      QuizModel quiz, String teacherId) async {
    return executeTryAndCatchForRepository(() async {
      final result = await remoteDataSouce.addQuiz(quiz, teacherId);
      return result.fold(
        (firebaseFailure) => throw Exception(firebaseFailure.message),
        (quiz) => quiz,
      );
    });
  }

  Future<Either<Failure, List<QuizModel>>> getTeacherQuizzes(
      String teacherId) async {
    return executeTryAndCatchForRepository(() async {
      final result = await remoteDataSouce.getTeacherQuizzes(teacherId);
      return result.fold(
        (firebaseFailure) => throw Exception(firebaseFailure.message),
        (quizzes) => quizzes,
      );
    });
  }

  Future<Either<Failure, QuizModel>> getQuiz(
      String quizId, String teacherId) async {
    return executeTryAndCatchForRepository(() async {
      final result = await remoteDataSouce.getQuiz(quizId, teacherId);
      return result.fold(
        (firebaseFailure) => throw Exception(firebaseFailure.message),
        (quiz) => quiz,
      );
    });
  }

  Future<Either<Failure, QuizModel>> updateQuiz(
      String quizId, QuizModel quiz, String teacherId) async {
    return executeTryAndCatchForRepository(() async {
      final result = await remoteDataSouce.updateQuiz(quizId, quiz, teacherId);
      return result.fold(
        (firebaseFailure) => throw Exception(firebaseFailure.message),
        (quiz) => quiz,
      );
    });
  }

  Future<Either<Failure, Unit>> deleteQuiz(
      String quizId, String teacherId) async {
    return executeTryAndCatchForRepository(() async {
      final result = await remoteDataSouce.deleteQuiz(quizId, teacherId);
      return result.fold(
        (firebaseFailure) => throw Exception(firebaseFailure.message),
        (_) => unit,
      );
    });
  }

  Stream<Either<Failure, List<QuizModel>>> watchTeacherQuizzes(
      String teacherId) {
    return remoteDataSouce
        .watchTeacherQuizzes(teacherId)
        .map((result) => result.fold(
              (firebaseFailure) => Left(Failure(firebaseFailure.message)),
              (quizzes) => Right(quizzes),
            ));
  }
}
