import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/core/network/api_client.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/models/user_model.dart';

class UserState {
  final UserModel? user;
  final List<UserModel> allUsers;
  final bool isLoading;
  final String? error;

  UserState({
    this.user,
    this.allUsers = const [],
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    UserModel? user,
    List<UserModel>? allUsers,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      allUsers: allUsers ?? this.allUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this.ref) : super(UserState());

  final Ref ref;

  // ==================== CURRENT USER ====================
  Future<void> fetchCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.usersBase;

      final response = await dio.get('/profile');
      final user = UserModel.fromJson(response.data);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      state = state.copyWith(isLoading: false, error: errorMsg);
      Helpers.showToast(errorMsg, isError: true);
    }
  }

  void setCurrentUser(UserModel user) {
    state = state.copyWith(user: user, isLoading: false);
  }

  // ==================== ADMIN: GET ALL USERS ====================
  Future<void> getAllUsers({String search = ''}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.usersBase;

      final response = await dio.get(
        '',
        queryParameters: search.isNotEmpty ? {'search': search} : null,
      );

      final List<dynamic> usersJson = response.data;
      final users = usersJson.map((json) => UserModel.fromJson(json)).toList();

      state = state.copyWith(allUsers: users, isLoading: false);
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      state = state.copyWith(isLoading: false, error: errorMsg);
      Helpers.showToast(errorMsg, isError: true);
    }
  }

  // ==================== ADMIN: USER MANAGEMENT ====================
  Future<void> toggleUserStatus(String userId, String action) async {
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.usersBase;

      final response = await dio.put('/$userId/$action');

      final message = _extractSuccessMessage(response.data) ?? '$action successful';
      await getAllUsers();
      Helpers.showToast(message);
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      Helpers.showToast(errorMsg, isError: true);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.usersBase;

      final response = await dio.delete('/$userId');

      final message = _extractSuccessMessage(response.data) ?? 'User deleted successfully';
      await getAllUsers();
      Helpers.showToast(message);
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      Helpers.showToast(errorMsg, isError: true);
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.usersBase;

      final response = await dio.post('', data: userData);

      final message = _extractSuccessMessage(response.data) ?? 'User created successfully';
      await getAllUsers();
      Helpers.showToast(message);
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      Helpers.showToast(errorMsg, isError: true);
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.usersBase;

      final response = await dio.put('/$userId', data: userData);

      final message = _extractSuccessMessage(response.data) ?? 'User updated successfully';
      await getAllUsers();
      Helpers.showToast(message);
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      Helpers.showToast(errorMsg, isError: true);
    }
  }

  // ==================== ROBUST ERROR HANDLING ====================
  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final response = e.response;

      if (response?.data != null) {
        final data = response!.data;

        // Case 1: JSON response with message field
        if (data is Map<String, dynamic>) {
          return data['message'] ??
              data['error'] ??
              data['errorMessage'] ??
              data['details'] ??
              e.message ??
              'Operation failed';
        }

        // Case 2: Raw string response
        if (data is String) {
          return data.trim();
        }
      }

      // Fallback for network/timeout errors
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout. Please check your internet.';
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        return 'Server took too long to respond.';
      }

      if (e.message != null && e.message!.isNotEmpty) {
        return e.message!;
      }
    }

    // Final fallback
    final errorStr = e.toString();
    return errorStr.length > 200 ? 'An unexpected error occurred' : errorStr;
  }

  String? _extractSuccessMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    if (data is String) {
      return data;
    }
    return null;
  }

  // ==================== PROFILE UPDATE ====================
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.usersBase;

      await dio.put('/profile', data: data);
      await fetchCurrentUser();
      Helpers.showToast('Profile updated successfully');
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      Helpers.showToast(errorMsg, isError: true);
    }
  }

  void clear() {
    state = UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>(
      (ref) => UserNotifier(ref),
);