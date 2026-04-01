// path: usecases/update_password_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:quran_sheikh_app/core/errors/failures.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../core/usecases/usecase.dart';

class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;

  UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

class UpdatePasswordUseCase implements UseCase<void, UpdatePasswordParams> {
  final ProfileRepository repository;

  UpdatePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) async {
    return await repository.updatePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}
