import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kinde_flutter_sdk/kinde_flutter_sdk.dart';
import '../../../data/model/user_model.dart';
import '../../../data/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final KindeFlutterSDK _kindeSDK = KindeFlutterSDK.instance;
  final AuthRepository _authRepository;
  bool _isAuthenticating = false;
  DateTime? _lastAuthAttempt;
  Timer? _authCheckTimer;

  AuthCubit(this._authRepository) : super(const AuthInitial()) {
    initialize();
  }

  @override
  Future<void> close() {
    _authCheckTimer?.cancel();
    return super.close();
  }

  // Initialize the SDK
  Future<void> initialize() async {
    print('Initializing Kinde SDK');

    try {
      // Check authentication status
      final isAuthenticated = await _kindeSDK.isAuthenticate();
      print('Is authenticated: $isAuthenticated');

      if (isAuthenticated) {
        await _fetchUserProfile();
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('Error initializing Kinde SDK: $e');
      emit(AuthError('Failed to initialize: $e'));
      // Fallback to unauthenticated state
      emit(const AuthUnauthenticated());
    }
  }

  // Login with Kinde
  Future<void> login() async {
    // Prevent multiple authentication attempts in quick succession
    final now = DateTime.now();
    if (_isAuthenticating ||
        (_lastAuthAttempt != null &&
            now.difference(_lastAuthAttempt!).inSeconds < 5)) {
      print(
        'Authentication already in progress or attempted too recently, ignoring login request',
      );
      return;
    }

    try {
      _isAuthenticating = true;
      _lastAuthAttempt = now;
      emit(const AuthLoading());

      print('Starting login process');

      // Simple login flow
      await _kindeSDK.login();
      print('Login flow initiated');

      // Wait longer for token processing - give more time for the redirect to complete
      await Future.delayed(const Duration(seconds: 2));

      // Check authentication after login attempt
      final isAuthenticated = await _kindeSDK.isAuthenticate();
      print('Login completed. Is authenticated: $isAuthenticated');

      if (isAuthenticated) {
        await _fetchUserProfile();
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('Error logging in: $e');
      emit(AuthError('Login failed: $e'));
      emit(const AuthUnauthenticated());
    } finally {
      _isAuthenticating = false;
    }
  }

  // Register with Kinde
  Future<void> register() async {
    // Prevent multiple authentication attempts in quick succession
    final now = DateTime.now();
    if (_isAuthenticating ||
        (_lastAuthAttempt != null &&
            now.difference(_lastAuthAttempt!).inSeconds < 5)) {
      print(
        'Authentication already in progress or attempted too recently, ignoring register request',
      );
      return;
    }

    try {
      _isAuthenticating = true;
      _lastAuthAttempt = now;
      emit(const AuthLoading());

      print('Starting registration process');

      // Simple register flow
      await _kindeSDK.register();
      print('Registration flow initiated');

      // Wait longer for token processing - give more time for the redirect to complete
      await Future.delayed(const Duration(seconds: 2));

      // Check authentication after registration attempt
      final isAuthenticated = await _kindeSDK.isAuthenticate();
      print('Registration completed. Is authenticated: $isAuthenticated');

      if (isAuthenticated) {
        await _fetchUserProfile();
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('Error registering: $e');
      emit(AuthError('Registration failed: $e'));
      emit(const AuthUnauthenticated());
    } finally {
      _isAuthenticating = false;
    }
  }

  // Logout from Kinde
  Future<void> logout() async {
    try {
      emit(const AuthLoading());
      print('Starting logout process');
      await _kindeSDK.logout();
      print('Logout completed');
      emit(const AuthUnauthenticated());
    } catch (e) {
      print('Error logging out: $e');
      // Force logout even if there's an error
      emit(const AuthUnauthenticated());
    }
  }

  // Fetch user profile and save to Firestore
  Future<void> _fetchUserProfile() async {
    try {
      print('Fetching user profile');
      final userProfile = await _kindeSDK.getUserProfileV2();
      print(
        'User profile fetched successfully: ${userProfile?.givenName} ${userProfile?.familyName}',
      );

      if (userProfile != null) {
        // Convert Kinde profile to our UserModel
        final userModel = UserModel.fromKindeProfile(userProfile);

        // Save user data to Firestore
        final result = await _authRepository.saveUser(userModel);
        result.fold(
          (failure) {
            print('Error saving user data: ${failure.message}');
            // Still emit authenticated state even if Firestore save fails
            emit(AuthAuthenticated(userProfile: userProfile));
          },
          (savedUser) {
            print('User data saved successfully: ${savedUser.email}');
            emit(AuthAuthenticated(userProfile: userProfile));
          },
        );
      } else {
        emit(const AuthAuthenticated(userProfile: null));
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      // Still consider the user authenticated even if profile fetch fails
      emit(const AuthAuthenticated(userProfile: null));
    }
  }

  // Check and update authentication status
  Future<void> checkAuthStatus() async {
    if (_isAuthenticating || state is AuthLoading) return;

    try {
      final isAuthenticated = await _kindeSDK.isAuthenticate();

      // Only update state if there's a change in authentication status
      if (isAuthenticated && state is! AuthAuthenticated) {
        print('Authentication status changed: authenticated');
        await _fetchUserProfile();
      } else if (!isAuthenticated && state is! AuthUnauthenticated) {
        print('Authentication status changed: unauthenticated');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
  }

  // Check if user is currently authenticating
  bool get isAuthenticating => _isAuthenticating;
}
