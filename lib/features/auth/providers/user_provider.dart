import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/core/network/api_client.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/models/user_model.dart';

import 'auth_provider.dart';

class UserState {
  final UserModel? user;
  final List<UserModel> allUsers;
  final bool isLoading;
  final String? error;

  UserState({this.user, this.allUsers = const [], this.isLoading = false, this.error});

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

  Future<void> fetchCurrentUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.usersBase));
      final token = ref.read(authProvider).token;
      final response = await dio.get('/profile', options: Options(headers: {'Authorization': 'Bearer $token'}));
      final user = UserModel.fromJson(response.data);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getAllUsers({String search = ''}) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider)..options.baseUrl = AppConfig.usersBase;
      final response = await dio.get('', queryParameters: search.isNotEmpty ? {'search': search} : null);
      final List usersJson = response.data;
      final users = usersJson.map((json) => UserModel.fromJson(json)).toList();
      state = state.copyWith(allUsers: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data, [String? imagePath]) async {
    try {
      final dio = ref.read(dioProvider)..options.baseUrl = AppConfig.usersBase;
      FormData formData = FormData.fromMap(data);
      if (imagePath != null) {
        formData.files.add(MapEntry('profilePicture', await MultipartFile.fromFile(imagePath)));
      }
      await dio.put('/profile', data: formData);
      await fetchCurrentUser();
      Helpers.showToast('Profile updated');
    } catch (e) {
      Helpers.showToast('Update failed', isError: true);
    }
  }

  Future<void> toggleUserStatus(String userId, String action) async {
    try {
      final dio = ref.read(dioProvider)..options.baseUrl = AppConfig.usersBase;
      await dio.put('/$userId/$action');
      await getAllUsers();
      Helpers.showToast('User $action successful');
    } catch (e) {
      Helpers.showToast('Action failed', isError: true);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final dio = ref.read(dioProvider)..options.baseUrl = AppConfig.usersBase;
      await dio.delete('/$userId');
      await getAllUsers();
      Helpers.showToast('User deleted');
    } catch (e) {
      Helpers.showToast('Delete failed', isError: true);
    }
  }

  void clear() {
    state = UserState();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) => UserNotifier(ref));