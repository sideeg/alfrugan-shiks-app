// Path: lib/data/repositories/notifications_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/notifications/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/remote/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(
          message: 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.'));
    }
    try {
      final models = await remoteDataSource.getNotifications(page: page);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markNotificationAsRead(
      int notificationId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
    try {
      final success =
          await remoteDataSource.markNotificationAsRead(notificationId);
      return Right(success);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllNotificationsAsRead() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'));
    }
    try {
      final success = await remoteDataSource.markAllNotificationsAsRead();
      return Right(success);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    if (!await networkInfo.isConnected) return const Right(0);
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
