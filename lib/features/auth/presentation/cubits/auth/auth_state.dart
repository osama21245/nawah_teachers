import 'package:equatable/equatable.dart';
import 'package:kinde_flutter_sdk/kinde_flutter_sdk.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserProfileV2? userProfile;

  const AuthAuthenticated({this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
