import 'package:fpdart/fpdart.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../model/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<FirebaseFailure, UserModel>> saveUser(UserModel user);
  Future<Either<FirebaseFailure, UserModel>> getUser(String email);
  Future<Either<FirebaseFailure, Unit>> deleteUser(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final IFirebaseService _firebaseService;

  AuthRemoteDataSourceImpl(this._firebaseService);

  @override
  Future<Either<FirebaseFailure, UserModel>> saveUser(UserModel user) async {
    return await _firebaseService.create(
      collection: 'users',
      documentId: user.email, // Using email as document ID
      data: user.toMap(),
      fromMap: UserModel.fromMap,
    );
  }

  @override
  Future<Either<FirebaseFailure, UserModel>> getUser(String email) async {
    return await _firebaseService.read(
      collection: 'users',
      documentId: email,
      fromMap: UserModel.fromMap,
    );
  }

  @override
  Future<Either<FirebaseFailure, Unit>> deleteUser(String email) async {
    return await _firebaseService.delete(
      collection: 'users',
      documentId: email,
    );
  }
}
