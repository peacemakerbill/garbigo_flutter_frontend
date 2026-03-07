import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/models/auth_response_model.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../main.dart';
import '../../location/providers/live_location_provider.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final String? token;
  final String? role;

  AuthState({this.isLoading = false, this.error, this.token, this.role});

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? token,
    String? role,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this.ref) : super(AuthState()) {
    _loadToken();
  }

  final Ref ref;

  Future<void> _loadToken() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');
    if (token != null) {
      state = state.copyWith(token: token);
      await ref.read(userProvider.notifier).fetchCurrentUser();
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('auth_token', token);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.authBase));
      final response = await dio.post('/signin', data: {
        'email': email,
        'password': password,
      });
      final authResponse = AuthResponseModel.fromJson(response.data);
      await _saveToken(authResponse.token);
      state = state.copyWith(
        isLoading: false,
        token: authResponse.token,
        role: authResponse.role,
      );
      ref.read(userProvider.notifier).fetchCurrentUser();
      Helpers.showToast('Login successful');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      Helpers.showToast('Login failed', isError: true);
    }
  }

  Future<void> signup(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.authBase));
      final response = await dio.post('/signup', data: data);
      final authResponse = AuthResponseModel.fromJson(response.data);
      await _saveToken(authResponse.token);
      state = state.copyWith(
        isLoading: false,
        token: authResponse.token,
        role: authResponse.role,
      );
      ref.read(userProvider.notifier).fetchCurrentUser();
      Helpers.showToast('Signup successful');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      Helpers.showToast('Signup failed', isError: true);
    }
  }

  Future<void> googleLogin() async {
    state = state.copyWith(isLoading: true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final dio = Dio(BaseOptions(baseUrl: AppConfig.authBase));
      final response = await dio.post('/social/google', data: {'token': googleAuth?.idToken});
      final authResponse = AuthResponseModel.fromJson(response.data);
      await _saveToken(authResponse.token);
      state = state.copyWith(
        isLoading: false,
        token: authResponse.token,
        role: authResponse.role,
      );
      ref.read(userProvider.notifier).fetchCurrentUser();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> facebookLogin() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final dio = Dio(BaseOptions(baseUrl: AppConfig.authBase));
        final response = await dio.post('/social/facebook', data: {'token': result.accessToken?.tokenString});
        final authResponse = AuthResponseModel.fromJson(response.data);
        await _saveToken(authResponse.token);
        state = state.copyWith(
          isLoading: false,
          token: authResponse.token,
          role: authResponse.role,
        );
        ref.read(userProvider.notifier).fetchCurrentUser();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> appleLogin() async {
    state = state.copyWith(isLoading: true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]);
      final dio = Dio(BaseOptions(baseUrl: AppConfig.authBase));
      final response = await dio.post('/social/apple', data: {'token': credential.identityToken});
      final authResponse = AuthResponseModel.fromJson(response.data);
      await _saveToken(authResponse.token);
      state = state.copyWith(
        isLoading: false,
        token: authResponse.token,
        role: authResponse.role,
      );
      ref.read(userProvider.notifier).fetchCurrentUser();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.authBase));
      await dio.post('/reset-password/request', data: {'email': email});
      Helpers.showToast('Reset link sent');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.authBase));
      await dio.post('/reset-password/confirm?token=$token', data: {'newPassword': newPassword});
      Helpers.showToast('Password reset successful');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyEmail(String token) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.authBase));
      await dio.get('/verify?token=$token');
      Helpers.showToast('Email verified');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.clear();

    state = AuthState(); // Reset auth state
    ref.read(userProvider.notifier).clear(); // Clear user data
    ref.read(liveLocationProvider.notifier).stopTracking(); // Stop location if running

    Helpers.showToast('Logged out successfully');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));