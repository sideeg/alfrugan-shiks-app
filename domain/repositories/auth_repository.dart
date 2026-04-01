// Path: lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/usecases/auth/login_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, LoginResponse?>> getCurrentUser();
  Future<Either<Failure, bool>> isLoggedIn();
}
