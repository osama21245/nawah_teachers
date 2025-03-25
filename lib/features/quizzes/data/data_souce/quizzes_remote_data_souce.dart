import 'package:fpdart/fpdart.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../model/quiz_model.dart';

abstract class QuizzesRemoteDataSouce {
  Future<Either<FirebaseFailure, QuizModel>> addQuiz(
      QuizModel quiz, String teacherId);
  Future<Either<FirebaseFailure, List<QuizModel>>> getTeacherQuizzes(
      String teacherId);
  Future<Either<FirebaseFailure, QuizModel>> getQuiz(
      String quizId, String teacherId);
  Future<Either<FirebaseFailure, QuizModel>> updateQuiz(
      String quizId, QuizModel quiz, String teacherId);
  Future<Either<FirebaseFailure, Unit>> deleteQuiz(
      String quizId, String teacherId);
  Stream<Either<FirebaseFailure, List<QuizModel>>> watchTeacherQuizzes(
      String teacherId);
}

class QuizzesRemoteDataSouceImpl implements QuizzesRemoteDataSouce {
  final IFirebaseService _firebaseService;

  QuizzesRemoteDataSouceImpl(this._firebaseService);

  @override
  Future<Either<FirebaseFailure, QuizModel>> addQuiz(
      QuizModel quiz, String teacherId) async {
    return await _firebaseService.create(
      collection: 'users/$teacherId/quizzes',
      data: quiz.toMap(),
      fromMap: QuizModel.fromMap,
    );
  }

  @override
  Future<Either<FirebaseFailure, List<QuizModel>>> getTeacherQuizzes(
      String teacherId) async {
    return await _firebaseService.readAll(
      collection: 'users/$teacherId/quizzes',
      fromMap: QuizModel.fromMap,
    );
  }

  @override
  Future<Either<FirebaseFailure, QuizModel>> getQuiz(
      String quizId, String teacherId) async {
    return await _firebaseService.read(
      collection: 'users/$teacherId/quizzes',
      documentId: quizId,
      fromMap: QuizModel.fromMap,
    );
  }

  @override
  Future<Either<FirebaseFailure, QuizModel>> updateQuiz(
      String quizId, QuizModel quiz, String teacherId) async {
    return await _firebaseService.update(
      collection: 'users/$teacherId/quizzes',
      documentId: quizId,
      data: quiz.toMap(),
      fromMap: QuizModel.fromMap,
    );
  }

  @override
  Future<Either<FirebaseFailure, Unit>> deleteQuiz(
      String quizId, String teacherId) async {
    return await _firebaseService.delete(
      collection: 'users/$teacherId/quizzes',
      documentId: quizId,
    );
  }

  @override
  Stream<Either<FirebaseFailure, List<QuizModel>>> watchTeacherQuizzes(
      String teacherId) {
    return _firebaseService.streamCollection(
      collection: 'users/$teacherId/quizzes',
      fromMap: QuizModel.fromMap,
    );
  }
}
