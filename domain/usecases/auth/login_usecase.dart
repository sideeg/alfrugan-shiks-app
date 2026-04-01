// Path: lib/domain/usecases/auth/login_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/auth/sheikh_entity.dart';
import '../../repositories/auth_repository.dart';

class LoginResponse {
  final SheikhEntity user;
  final String? minimumRequiredVersion;

  LoginResponse({
    required this.user,
    this.minimumRequiredVersion,
  });
}

class LoginUseCase implements UseCase<LoginResponse, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, LoginResponse>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
