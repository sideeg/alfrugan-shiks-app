import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_sheikh_app/core/network/api_client.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../config/dependency_injection.dart'; // ← gives us the ready-made instances
import 'package:get_it/get_it.dart'; // <-- Add this import for getIt

// Remote data-source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(
    apiClient: GetIt.instance<ApiClient>(), // ← named + from DI
  ),
);

// Local data-source
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => GetIt.instance<AuthLocalDataSource>(),
);

// Repository (needs BOTH remote + local)
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
  ),
);

// Use-cases
final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.read(authRepositoryProvider)),
);
