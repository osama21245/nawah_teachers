import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kinde_flutter_sdk/kinde_flutter_sdk.dart';
import 'package:nawah_teachers/core/utils/crud.dart';
import 'package:nawah_teachers/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:nawah_teachers/features/auth/data/repository/auth_repository.dart';
import 'package:nawah_teachers/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:nawah_teachers/features/quizzes/data/data_souce/quizzes_remote_data_souce.dart';
import 'package:nawah_teachers/features/quizzes/data/repository/quizzes_repository.dart';
import 'package:nawah_teachers/features/quizzes/presentation/cubits/add_quizzes/add_quiz_cubit.dart';
import 'package:nawah_teachers/features/videos/data/data_souce/videos_remote_data_souce.dart'
    show VideosRemoteDataSouce, VideosRemoteDataSouceImpl;
import 'package:nawah_teachers/features/videos/data/repository/videos_repository.dart';
import 'package:nawah_teachers/features/videos/presentation/cubits/add_videos/add_video_cubit.dart';
import 'package:nawah_teachers/features/videos/presentation/cubits/get_videos/get_videos_cubit.dart';
import 'package:nawah_teachers/firebase_options.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'core/comman/app_user/app_user_cubit.dart';
import 'core/comman/helpers/bloc_observer.dart';
import 'core/utils/custom_error_screen.dart';
import 'core/firebase/firebase_service.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Service
  final firebaseService = FirebaseService();
  await firebaseService.init();
  serviceLocator.registerLazySingleton<IFirebaseService>(() => firebaseService);

  // Initialize other services
  _initFirebase();
  _initAuth();
  _initAddQuizCubit();
  _initVideoCubits();
  customErorrScreen();
  addDioInterceptors();
  await _initKinde();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  Bloc.observer = MyBlocObserver();

  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void addDioInterceptors() {
  final dio = serviceLocator<Dio>();

  if (kDebugMode) {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
  }

  dio.interceptors.add(RetryInterceptor(
    dio: dio,
    logPrint: print,
    retries: 3,
    retryDelays: const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  ));
}

void _initAddQuizCubit() {
  // Register Quizzes Data Source
  serviceLocator.registerFactory<QuizzesRemoteDataSouce>(
    () => QuizzesRemoteDataSouceImpl(
      serviceLocator<IFirebaseService>(),
    ),
  );

  // Register Quizzes Repository
  serviceLocator.registerFactory<QuizzesRepository>(
    () => QuizzesRepository(serviceLocator<QuizzesRemoteDataSouce>()),
  );

  // Register AddQuizCubit
  serviceLocator.registerFactory<AddQuizCubit>(
    () => AddQuizCubit(serviceLocator<QuizzesRepository>()),
  );
}

void _initVideoCubits() {
  // Register data sources
  serviceLocator.registerFactory<VideosRemoteDataSouce>(
      () => VideosRemoteDataSouceImpl(serviceLocator<Crud>()));

  // Register repositories
  serviceLocator.registerFactory(
      () => VideosRepository(serviceLocator<VideosRemoteDataSouce>()));

  // Register cubits
  serviceLocator
      .registerFactory(() => AddVideoCubit(serviceLocator<VideosRepository>()));
  serviceLocator.registerFactory(
      () => GetVideosCubit(serviceLocator<VideosRepository>()));
}

Future<void> _initKinde() async {
  // Initialize Kinde SDK with the domain exactly as provided in .env
}

void _initAuth() {
  serviceLocator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(serviceLocator()),
  );

  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(serviceLocator()),
  );

  serviceLocator.registerFactory<AuthCubit>(
    () => AuthCubit(serviceLocator()),
  );
}

void _initFirebase() {
  serviceLocator.registerLazySingleton<IFirebaseService>(
    () => FirebaseService(),
  );
}
