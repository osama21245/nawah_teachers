import 'dart:async';


import '../../../../core/constants/api_links.dart';
import '../../../../core/utils/crud.dart';
import '../../../../core/utils/try_and_catch.dart';
import '../model/quiz_model.dart';

abstract class QuizzesRemoteDataSouce {
//  Future<Either<Failure, List<QuizModel>>> getQuizzes();
  Future< Map<String, dynamic>> addQuiz(QuizModel quiz);
}

class QuizzesRemoteDataSouceImpl extends QuizzesRemoteDataSouce {
  final Crud crud;

  QuizzesRemoteDataSouceImpl(this.crud);

  // @override
  // Future<Either<Failure, List<QuizModel>>> getQuizzes() async {
  //   return executeTryAndCatchForDataLayer(() async {
  //     final response = await crud.getData(ApiLinks.getQuizzes);
  //     return (response['data'] as List)
  //         .map((quiz) => QuizModel.fromJson(quiz))
  //         .toList();
  //   });
  // }

  @override
  Future<Map<String, dynamic>> addQuiz(QuizModel quiz) async {
    return executeTryAndCatchForDataLayer(() async {
      final response = await crud.postData(
        ApiLinks.addQuiz,
        quiz.toMap(),
      );
      return response as Map<String, dynamic>;
    });
  }
}
