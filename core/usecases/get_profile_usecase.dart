// path: lib/core/usecases/get_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:quran_sheikh_app/core/errors/failures.dart';
import 'package:quran_sheikh_app/domain/entities/profile_entity.dart';
import 'package:quran_sheikh_app/domain/repositories/profile_repository.dart';

import '../../core/usecases/usecase.dart';

class GetProfileUseCase implements UseCase<ProfileEntity, NoParams> {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
