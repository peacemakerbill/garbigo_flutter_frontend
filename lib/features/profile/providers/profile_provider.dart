import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garbigo_frontend/core/config/app_config.dart';
import 'package:garbigo_frontend/core/utils/helpers.dart';
import 'package:garbigo_frontend/features/auth/providers/auth_provider.dart';
import 'package:garbigo_frontend/features/auth/providers/user_provider.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref) : super(ProfileState());

  final Ref ref;

  Future<void> updateProfile({
    Map<String, dynamic>? data,
    XFile? imageFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.usersBase));
      final token = ref.read(authProvider).token;
      if (token == null) throw Exception('Not authenticated');

      final formData = FormData.fromMap(data ?? {});

      if (imageFile != null) {
        MultipartFile multipartFile;

        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          multipartFile = MultipartFile.fromBytes(bytes, filename: imageFile.name);
        } else {
          multipartFile = await MultipartFile.fromFile(imageFile.path, filename: imageFile.name);
        }

        formData.files.add(MapEntry('profilePicture', multipartFile));
      }

      await dio.put(
        '/profile',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await ref.read(userProvider.notifier).fetchCurrentUser();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Profile updated successfully!',
      );
      Helpers.showToast('Profile updated successfully');
    } catch (e) {
      final msg = e is DioException
          ? (e.response?.data?['message'] ?? e.message ?? 'Update failed')
          : e.toString();
      state = state.copyWith(isLoading: false, error: msg);
      Helpers.showToast(msg, isError: true);
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
      (ref) => ProfileNotifier(ref),
);