import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinde_flutter_sdk/kinde_flutter_sdk.dart';
import 'package:nawah_teachers/features/auth/data/data_source/auth_remote_data_source.dart'
    show AuthRemoteDataSource, AuthRemoteDataSourceImpl;
import 'package:nawah_teachers/features/auth/data/repository/auth_repository.dart'
    show AuthRepository;
import 'package:nawah_teachers/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:nawah_teachers/features/auth/presentation/screens/auth_wrapper.dart'
    show AuthWrapper;
import 'package:nawah_teachers/features/quizzes/presentation/screens/add_quiz_screen.dart';
import 'core/firebase/firebase_service.dart';
import 'init_dependences.dart';

import 'features/quizzes/presentation/cubits/add_quizzes/add_quiz_cubit.dart';
import 'features/videos/presentation/cubits/add_videos/add_video_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  initDependencies();

  // await KindeFlutterSDK.initializeSDK(
  //   authDomain: "https://easyresume.kinde.com",
  //   authClientId: "19ed3e255474413ba6a20e24338041fd",
  //   loginRedirectUri: "com.kinde.myapp://kinde_callback",
  //   logoutRedirectUri: "com.kinde.myapp://kinde_logoutcallback",
  //   scopes: ["email", "profile", "offline", "openid"],
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nawah Teachers',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator<AddVideoCubit>(),
          ),
          BlocProvider(
            create: (context) => AuthCubit(
              AuthRepository(
                AuthRemoteDataSourceImpl(
                  FirebaseService(),
                ),
              ),
            ),
          ),
        ],
        child: BlocProvider(
          create: (context) => serviceLocator<AddQuizCubit>(),
          child: const AddQuizScreen(),
        ),
      ),
    );
  }
}
