// Path: lib/presentation/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/config/dependency_injection.dart';
import 'package:quran_sheikh_app/data/datasources/local/auth_local_datasource.dart';
import 'package:quran_sheikh_app/data/datasources/remote/notifications_remote_datasource.dart';
import 'package:quran_sheikh_app/domain/entities/profile_entity.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/auth/sheikh_entity.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../services/fcm_service.dart';
import '../providers/notifications_provider.dart';
import '../providers/usecase_providers.dart';

// ═════════════════════════════════════════════════════════════════════════════
// STATE
// ═════════════════════════════════════════════════════════════════════════════

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final SheikhEntity? user;
  final String? errorMessage;
  final String? minimumRequiredVersion;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
    this.minimumRequiredVersion,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    SheikhEntity? user,
    String? errorMessage,
    String? minimumRequiredVersion,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage,
      minimumRequiredVersion:
          minimumRequiredVersion ?? this.minimumRequiredVersion,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// NOTIFIER
// ═════════════════════════════════════════════════════════════════════════════

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  // Riverpod ref so we can call other providers (unreadCountProvider)
  final Ref _ref;

  AuthNotifier({
    required this.loginUseCase,
    required this.logoutUseCase,
    required Ref ref,
  })  : _ref = ref,
        super(const AuthState());

  void forceLogout() {
    state = const AuthState();
  }

  // ── Restore session on app launch ──────────────────────────────────────────

  Future<void> restoreSession() async {
    final localDataSource = getIt<AuthLocalDataSource>();
    final token = await localDataSource.getToken();
    final user = await localDataSource.getUser();
    final version = await localDataSource.getMinimumRequiredVersion();

    if (token != null && token.isNotEmpty && user != null) {
      state = state.copyWith(
        isAuthenticated: true,
        user: SheikhEntity.fromModel(user),
        minimumRequiredVersion: version,
        isLoading: false,
      );
      _initFcm();
    } else {
      state = const AuthState();
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result =
        await loginUseCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (loginResponse) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: loginResponse.user,
          minimumRequiredVersion: loginResponse.minimumRequiredVersion,
          errorMessage: null,
        );
        _initFcm();
      },
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (!kIsWeb) {
        await FcmService.instance.dispose(
          localDataSource: getIt<AuthLocalDataSource>(),
        );
      }
      await logoutUseCase(NoParams());
      await getIt<AuthLocalDataSource>().clearAuthData();

      // Reset badge count on logout
      _ref.read(unreadCountProvider.notifier).reset();

      state = const AuthState();
    } catch (_) {
      await getIt<AuthLocalDataSource>().clearAuthData();
      state = const AuthState();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void updateUserProfile(ProfileEntity profile) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        nationalId: profile.nationalId,
        qiraat: profile.qiraat,
        profileImage: profile.profileImage,
      );
      state = state.copyWith(user: updatedUser);
    }
  }

  void _initFcm() {
    if (!kIsWeb) {
      FcmService.instance.initialize(
        localDataSource: getIt<AuthLocalDataSource>(),
        remoteDataSource: getIt<NotificationsRemoteDataSource>(),
      );
    }

    // Fetch unread count immediately after authentication.
    // This populates the badge on the dashboard and bottom nav
    // without waiting for the user to navigate to the notifications screen.
    _ref.read(unreadCountProvider.notifier).refresh();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═════════════════════════════════════════════════════════════════════════════

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.read(loginUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
    ref: ref,
  );
});
