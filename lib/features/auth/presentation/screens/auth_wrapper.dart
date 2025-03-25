import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Show loading indicator while initializing
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate based on authentication state
        if (state is AuthAuthenticated) {
          print('AuthWrapper: User is authenticated, showing HomeScreen');
          return const HomeScreen();
        } else {
          print('AuthWrapper: User is not authenticated, showing AuthScreen');
          return const AuthScreen();
        }
      },
    );
  }
}
