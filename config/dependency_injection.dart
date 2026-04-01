// lib/config/dependency_injection.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../data/datasources/local/auth_local_datasource.dart';
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/datasources/remote/courses_remote_datasource.dart';

import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/courses_repository_impl.dart';

import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/courses_repository.dart';

import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/logout_usecase.dart';
import '../domain/usecases/courses/get_courses_usecase.dart';

final authExpiredNotifier = ValueNotifier<bool>(false);
final getIt = GetIt.instance;

class DependencyInjection {
  static late SharedPreferences _sharedPreferences;
  static late ApiClient _apiClient;
  static late NetworkInfo _networkInfo;

  static late AuthLocalDataSource _authLocalDataSource;
  static late AuthRemoteDataSource _authRemoteDataSource;
  static late CoursesRemoteDataSource _coursesRemoteDataSource;

  static late AuthRepository _authRepository;
  static late CoursesRepository _coursesRepository;

  static late LoginUseCase _loginUseCase;
  static late LogoutUseCase _logoutUseCase;
  static late GetCoursesUseCase _getCoursesUseCase;

  static Future<void> init() async {
    /* ---------- External & Core ---------- */
    _sharedPreferences = await SharedPreferences.getInstance();
    _apiClient = ApiClient(
      onUnauthorized: () async {
        // Clear local data and reset auth state
        final localDataSource = AuthLocalDataSourceImpl(
          sharedPreferences: _sharedPreferences,
        );
        await localDataSource.clearAuthData();
        // Trigger navigation to login via a global notifier
        authExpiredNotifier.value = true;
      },
    );
    _networkInfo = NetworkInfoImpl(Connectivity());

    /* ---------- Register them in GetIt ---------- */
    getIt.registerLazySingleton<SharedPreferences>(() => _sharedPreferences);
    getIt.registerLazySingleton<ApiClient>(() => _apiClient);
    getIt.registerLazySingleton<NetworkInfo>(() => _networkInfo);

    /* ---------- Data Sources ---------- */
    _authLocalDataSource = AuthLocalDataSourceImpl(
      sharedPreferences: _sharedPreferences,
    );
    _authRemoteDataSource = AuthRemoteDataSourceImpl(
      apiClient: _apiClient,
    );
    _coursesRemoteDataSource = CoursesRemoteDataSourceImpl(
      apiClient: _apiClient,
    );

    getIt
        .registerLazySingleton<AuthLocalDataSource>(() => _authLocalDataSource);
    getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => _authRemoteDataSource);
    getIt.registerLazySingleton<CoursesRemoteDataSource>(
        () => _coursesRemoteDataSource);

    /* ---------- Repositories ---------- */
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      localDataSource: _authLocalDataSource,
    );
    _coursesRepository = CoursesRepositoryImpl(
      remoteDataSource: _coursesRemoteDataSource,
    );

    getIt.registerLazySingleton<AuthRepository>(() => _authRepository);
    getIt.registerLazySingleton<CoursesRepository>(() => _coursesRepository);

    /* ---------- Use Cases ---------- */
    _loginUseCase = LoginUseCase(_authRepository);
    _logoutUseCase = LogoutUseCase(_authRepository);
    _getCoursesUseCase = GetCoursesUseCase(_coursesRepository);

    getIt.registerLazySingleton<LoginUseCase>(() => _loginUseCase);
    getIt.registerLazySingleton<LogoutUseCase>(() => _logoutUseCase);
    getIt.registerLazySingleton<GetCoursesUseCase>(() => _getCoursesUseCase);
  }

  /* ---------- Static getters (unchanged) ---------- */
  static SharedPreferences get sharedPreferences => _sharedPreferences;
  static ApiClient get apiClient => _apiClient;
  static NetworkInfo get networkInfo => _networkInfo;

  static AuthLocalDataSource get authLocalDataSource => _authLocalDataSource;
  static AuthRemoteDataSource get authRemoteDataSource => _authRemoteDataSource;
  static CoursesRemoteDataSource get coursesRemoteDataSource =>
      _coursesRemoteDataSource;

  static AuthRepository get authRepository => _authRepository;
  static CoursesRepository get coursesRepository => _coursesRepository;

  static LoginUseCase get loginUseCase => _loginUseCase;
  static LogoutUseCase get logoutUseCase => _logoutUseCase;
  static GetCoursesUseCase get getCoursesUseCase => _getCoursesUseCase;
}
