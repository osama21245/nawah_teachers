import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nawah_teachers/core/utils/crud.dart';
import 'package:nawah_teachers/features/quizzes/data/data_souce/quizzes_remote_data_souce.dart';
import 'package:nawah_teachers/features/quizzes/data/repository/quizzes_repository.dart';
import 'package:nawah_teachers/features/quizzes/presentation/cubits/add_quizzes/add_quiz_cubit.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'core/comman/app_user/app_user_cubit.dart';
import 'core/comman/helpers/bloc_observer.dart';
import 'core/utils/custom_error_screen.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAddQuizCubit();
  customErorrScreen();
  addDioInterceptors();
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
  final dio = Dio(BaseOptions(
    // baseUrl: 'http://127.0.0.1:8000', // Your base URL
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (status) {
      return status != null && status < 500;
    },
  ));

  serviceLocator.registerLazySingleton(() => dio);

  // Register Crud with the configured Dio
  serviceLocator.registerLazySingleton(() => Crud(dio: serviceLocator<Dio>()));

  serviceLocator.registerFactory<QuizzesRemoteDataSouce>(
      () => QuizzesRemoteDataSouceImpl(serviceLocator<Crud>()));

  serviceLocator.registerFactory(
      () => QuizzesRepository(serviceLocator<QuizzesRemoteDataSouce>()));

  serviceLocator
      .registerFactory(() => AddQuizCubit(serviceLocator<QuizzesRepository>()));
}
