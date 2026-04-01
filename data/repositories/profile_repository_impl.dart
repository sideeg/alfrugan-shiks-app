// path: lib/data/repositories/profile_repository_impl.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:quran_sheikh_app/core/errors/exceptions.dart';
import 'package:quran_sheikh_app/core/errors/failures.dart';
import 'package:quran_sheikh_app/data/datasources/local/profile_local_data_source.dart';
import 'package:quran_sheikh_app/data/datasources/remote/profile_remote_data_source.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_update_request.dart';
import '../../domain/repositories/profile_repository.dart';

import '../../core/network/network_info.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getProfile();
        await localDataSource.cacheProfile(remoteProfile);
        return Right(remoteProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final localProfile = await localDataSource.getCachedProfile();
        return Right(localProfile);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
      ProfileUpdateRequest request) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedProfile = await remoteDataSource.updateProfile(request);
        await localDataSource.cacheProfile(updatedProfile);
        return Right(updatedProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedProfile = await remoteDataSource.updatePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        // Update cached profile after password change
        await localDataSource.cacheProfile(updatedProfile);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(File imageFile) async {
    // This method is no longer needed since image upload is handled in updateProfile
    // But keeping it for interface compatibility
    return Left(
        ServerFailure(message: 'Use updateProfile method for image upload'));
  }
}
