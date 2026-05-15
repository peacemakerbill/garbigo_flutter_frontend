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
      state = state.copyWith(isLoading: false, error: e.toString());
      Helpers.showToast('Failed to load profile', isError: true);
    }
  }

  /// Set user directly from login/signup response (avoids extra network call)
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
      state = state.copyWith(isLoading: false, error: e.toString());
      Helpers.showToast('Failed to load users', isError: true);
    }
  }

  // ==================== ADMIN: USER MANAGEMENT ====================
  Future<void> toggleUserStatus(String userId, String action) async {
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.usersBase;

      await dio.put('/$userId/$action');
      await getAllUsers();
      Helpers.showToast('$action successful');
    } catch (e) {
      Helpers.showToast('Action failed: ${e.toString()}', isError: true);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final dio = ref.read(dioProvider);
      dio.options.baseUrl = AppConfig.usersBase;

      await dio.delete('/$userId');
      await getAllUsers();
      Helpers.showToast('User deleted successfully');
    } catch (e) {
      Helpers.showToast('Delete failed', isError: true);
    }
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
      Helpers.showToast('Profile update failed', isError: true);
    }
  }

  void clear() {
    state = UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>(
      (ref) => UserNotifier(ref),
);