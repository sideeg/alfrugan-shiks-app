// Path: lib/presentation/providers/use_case_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/core/network/api_client.dart';
import 'package:quran_sheikh_app/core/network/network_info.dart';
import 'package:quran_sheikh_app/core/usecases/get_profile_usecase.dart';
import 'package:quran_sheikh_app/core/usecases/update_password_usecase.dart';
import 'package:quran_sheikh_app/core/usecases/update_profile_usecase.dart';
import 'package:quran_sheikh_app/data/datasources/local/profile_local_data_source.dart';
import 'package:quran_sheikh_app/data/datasources/remote/profile_remote_data_source.dart';
import 'package:quran_sheikh_app/data/repositories/profile_repository_impl.dart';
import 'package:quran_sheikh_app/domain/repositories/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

// Core Providers (using GetIt)
final apiClientProvider = Provider<ApiClient>((ref) {
  return GetIt.instance<ApiClient>();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return GetIt.instance<NetworkInfo>();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  return GetIt.instance<SharedPreferences>();
});

// Data Source Providers
final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRemoteDataSourceImpl(apiClient: apiClient);
});

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return ProfileLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

// Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  final localDataSource = ref.watch(profileLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return ProfileRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// Use Case Providers
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetProfileUseCase(repository);
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

final updatePasswordUseCaseProvider = Provider<UpdatePasswordUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdatePasswordUseCase(repository);
});
