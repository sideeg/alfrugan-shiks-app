// path: providers/profile_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quran_sheikh_app/core/errors/failures.dart';
import 'package:quran_sheikh_app/core/usecases/get_profile_usecase.dart';
import 'package:quran_sheikh_app/core/usecases/update_password_usecase.dart';
import 'package:quran_sheikh_app/core/usecases/update_profile_usecase.dart';
import 'package:quran_sheikh_app/domain/entities/profile_entity.dart';
import 'package:quran_sheikh_app/domain/entities/profile_update_request.dart';

import 'package:quran_sheikh_app/core/usecases/usecase.dart';
import 'package:quran_sheikh_app/presentation/providers/use_case_providers.dart';

// Profile state classes
class ProfileState {
  final ProfileEntity? profile;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    ProfileEntity? profile,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

// Profile notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;

  ProfileNotifier({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _updatePasswordUseCase = updatePasswordUseCase,
        super(const ProfileState());

  Future<void> getProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getProfileUseCase(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: _mapFailureToMessage(failure),
      ),
      (profile) => state = state.copyWith(
        isLoading: false,
        profile: profile,
      ),
    );
  }

  Future<void> updateProfile(ProfileUpdateRequest request) async {
    state =
        state.copyWith(isUpdating: true, clearError: true, clearSuccess: true);

    final result = await _updateProfileUseCase(request);

    result.fold(
      (failure) => state = state.copyWith(
        isUpdating: false,
        error: _mapFailureToMessage(failure),
      ),
      (profile) => state = state.copyWith(
        isUpdating: false,
        profile: profile,
        successMessage: 'تم تحديث الملف الشخصي بنجاح',
      ),
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state =
        state.copyWith(isUpdating: true, clearError: true, clearSuccess: true);

    final result = await _updatePasswordUseCase(
      UpdatePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isUpdating: false,
        error: _mapFailureToMessage(failure),
      ),
      (_) => state = state.copyWith(
        isUpdating: false,
        successMessage: 'تم تحديث كلمة المرور بنجاح',
      ),
    );
  }

  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      state = state.copyWith(error: 'فشل في اختيار الصورة');
      return null;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case NetworkFailure:
        return 'تحقق من الاتصال بالإنترنت';
      case CacheFailure:
        return 'فشل في تحميل البيانات المحفوظة';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}

// Provider definitions
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    getProfileUseCase: ref.watch(getProfileUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
    updatePasswordUseCase: ref.watch(updatePasswordUseCaseProvider),
  );
});
