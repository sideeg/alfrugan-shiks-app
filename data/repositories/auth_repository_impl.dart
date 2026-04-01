// Path: lib/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/error_handler.dart';
import '../../domain/entities/auth/sheikh_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth/login_request_model.dart';
import '../../domain/usecases/auth/login_usecase.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, LoginResponse>> login(
      String email, String password) async {
    try {
      final request = LoginRequestModel(email: email, password: password);
      final response = await remoteDataSource.login(request);

      // ✅ Save all data
      await localDataSource.saveToken(response.data.token);
      await localDataSource.saveUser(response.data.user);
      await localDataSource.saveMinimumRequiredVersion(
          response.data.minimumRequiredVersion); // ✅ NEW

      // ✅ Create and return LoginResponse
      final loginResponse = LoginResponse(
        user: SheikhEntity.fromModel(response.data.user),
        minimumRequiredVersion: response.data.minimumRequiredVersion,
      );

      return Right(loginResponse);
    } catch (e) {
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAuthData();
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, LoginResponse?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      final version = await localDataSource.getMinimumRequiredVersion();
      final loginResponse = LoginResponse(
        user: SheikhEntity.fromModel(user),
        minimumRequiredVersion: version,
      );

      return Right(loginResponse);
    } catch (e) {
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e as Exception));
    }
  }
}
