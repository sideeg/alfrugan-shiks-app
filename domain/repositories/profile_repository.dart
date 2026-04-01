// path: lib/domain/repositories/profile_repository.dart

import 'dart:io';
import 'package:quran_sheikh_app/core/errors/failures.dart';

import '../entities/profile_entity.dart';
import '../entities/profile_update_request.dart';

import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile(
      ProfileUpdateRequest request);
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, String>> uploadProfileImage(File imageFile);
}
