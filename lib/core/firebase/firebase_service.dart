import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import '../../firebase_options.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../erorr/failure.dart';

class FirebaseFailure extends Failure {
  FirebaseFailure(super.message);
}

// Abstract class defining the contract
abstract class IFirebaseService {
  Future<void> init();

  Future<Either<FirebaseFailure, T>> create<T>({
    required String collection,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromMap,
    String? documentId,
  });

  Future<Either<FirebaseFailure, T>> read<T>({
    required String collection,
    required String documentId,
    required T Function(Map<String, dynamic>) fromMap,
  });

  Future<Either<FirebaseFailure, List<T>>> readAll<T>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>>)? query,
  });

  Future<Either<FirebaseFailure, T>> update<T>({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromMap,
  });

  Future<Either<FirebaseFailure, Unit>> delete({
    required String collection,
    required String documentId,
  });

  Future<Either<FirebaseFailure, String>> uploadFile({
    required String path,
    required dynamic file,
  });

  Future<Either<FirebaseFailure, Unit>> deleteFile({
    required String path,
  });

  Stream<Either<FirebaseFailure, List<T>>> streamCollection<T>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>>)? query,
  });
}

// Concrete implementation
class FirebaseService implements IFirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;

  @override
  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
  }

  @override
  Future<Either<FirebaseFailure, T>> create<T>({
    required String collection,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromMap,
    String? documentId,
  }) async {
    try {
      DocumentSnapshot doc;
      if (documentId != null) {
        await _firestore.collection(collection).doc(documentId).set(data);
        doc = await _firestore.collection(collection).doc(documentId).get();
      } else {
        final docRef = await _firestore.collection(collection).add(data);
        doc = await docRef.get();
      }
      return Right(fromMap({...data, 'id': doc.id}));
    } catch (e) {
      return Left(FirebaseFailure('Failed to create document: $e'));
    }
  }

  @override
  Future<Either<FirebaseFailure, T>> read<T>({
    required String collection,
    required String documentId,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      if (!doc.exists) {
        return Left(FirebaseFailure('Document does not exist'));
      }
      return Right(fromMap({...doc.data()!, 'id': doc.id}));
    } catch (e) {
      return Left(FirebaseFailure('Failed to read document: $e'));
    }
  }

  @override
  Future<Either<FirebaseFailure, List<T>>> readAll<T>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>>)? query,
  }) async {
    try {
      Query<Map<String, dynamic>> ref = _firestore.collection(collection);
      if (query != null) {
        ref = query(ref) ?? ref;
      }
      final querySnapshot = await ref.get();
      return Right(
        querySnapshot.docs
            .map((doc) => fromMap({...doc.data(), 'id': doc.id}))
            .toList(),
      );
    } catch (e) {
      return Left(FirebaseFailure('Failed to read documents: $e'));
    }
  }

  @override
  Future<Either<FirebaseFailure, T>> update<T>({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return Right(fromMap({...doc.data()!, 'id': doc.id}));
    } catch (e) {
      return Left(FirebaseFailure('Failed to update document: $e'));
    }
  }

  @override
  Future<Either<FirebaseFailure, Unit>> delete({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      return const Right(unit);
    } catch (e) {
      return Left(FirebaseFailure('Failed to delete document: $e'));
    }
  }

  @override
  Future<Either<FirebaseFailure, String>> uploadFile({
    required String path,
    required dynamic file,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      UploadTask uploadTask;

      if (kIsWeb) {
        // For web, file is Uint8List
        uploadTask = ref.putData(file as Uint8List);
      } else {
        // For mobile, file is File
        uploadTask = ref.putFile(file as File);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return Right(downloadUrl);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<FirebaseFailure, Unit>> deleteFile({
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
      return const Right(unit);
    } catch (e) {
      return Left(FirebaseFailure('Failed to delete file: $e'));
    }
  }

  @override
  Stream<Either<FirebaseFailure, List<T>>> streamCollection<T>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>>)? query,
  }) {
    try {
      Query<Map<String, dynamic>> ref = _firestore.collection(collection);
      if (query != null) {
        ref = query(ref) ?? ref;
      }
      return ref.snapshots().map((snapshot) {
        try {
          return Right<FirebaseFailure, List<T>>(
            snapshot.docs
                .map((doc) => fromMap({...doc.data(), 'id': doc.id}))
                .toList(),
          );
        } catch (e) {
          return Left<FirebaseFailure, List<T>>(
            FirebaseFailure('Failed to parse documents: $e'),
          );
        }
      }).handleError(
        (error) => Left<FirebaseFailure, List<T>>(
          FirebaseFailure('Stream error: $error'),
        ),
      );
    } catch (e) {
      return Stream.value(
        Left(FirebaseFailure('Failed to stream collection: $e')),
      );
    }
  }
}
