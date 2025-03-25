import 'package:fpdart/fpdart.dart';
import '../../../../core/erorr/failure.dart';
import '../../../../core/utils/try_and_catch.dart';
import '../data_source/auth_remote_data_source.dart';
import '../model/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository(this.remoteDataSource);

  Future<Either<Failure, UserModel>> saveUser(UserModel user) async {
    return executeTryAndCatchForRepository(() async {
      final result = await remoteDataSource.saveUser(user);
      return result.fold(
        (firebaseFailure) => throw Exception(firebaseFailure.message),
        (user) => user,
      );
    });
  }

  Future<Either<Failure, UserModel>> getUser(String email) async {
    return executeTryAndCatchForRepository(() async {
      final result = await remoteDataSource.getUser(email);
      return result.fold(
        (firebaseFailure) => throw Exception(firebaseFailure.message),
        (user) => user,
      );
    });
  }

  Future<Either<Failure, Unit>> deleteUser(String email) async {
    return executeTryAndCatchForRepository(() async {
      final result = await remoteDataSource.deleteUser(email);
      return result.fold(
        (firebaseFailure) => throw Exception(firebaseFailure.message),
        (_) => unit,
      );
    });
  }
}
