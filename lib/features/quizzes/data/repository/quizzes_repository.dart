import 'package:fpdart/fpdart.dart';

import '../../../../core/erorr/failure.dart';
import '../../../../core/utils/try_and_catch.dart';
import '../data_souce/quizzes_remote_data_souce.dart';
import '../model/quiz_model.dart';

class QuizzesRepository {
  final QuizzesRemoteDataSouce remoteDataSouce;

  QuizzesRepository(this.remoteDataSouce);

  Future<Either<Failure, QuizModel>> addQuiz(QuizModel quiz) async {
    return executeTryAndCatchForRepository(() async {
      return QuizModel.fromMap(await remoteDataSouce.addQuiz(quiz));
    });
  }

  // Future<Either<Failure, List<QuizModel>>> getQuizzes() async {
  //   return executeTryAndCatchForRepository(() async {
  //     return (await remoteDataSouce.getQuizzes()).map((quiz) => QuizModel.fromMap(quiz));
  //   });
  // }
}
