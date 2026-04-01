// path: usecases/update_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:quran_sheikh_app/core/errors/failures.dart';
import 'package:quran_sheikh_app/domain/entities/profile_entity.dart';
import 'package:quran_sheikh_app/domain/entities/profile_update_request.dart';
import 'package:quran_sheikh_app/domain/repositories/profile_repository.dart';

import '../../core/usecases/usecase.dart';

class UpdateProfileUseCase
    implements UseCase<ProfileEntity, ProfileUpdateRequest> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(
      ProfileUpdateRequest params) async {
    return await repository.updateProfile(params);
  }
}
