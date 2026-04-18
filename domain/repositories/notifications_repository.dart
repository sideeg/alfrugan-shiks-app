// Path: lib/domain/repositories/notifications_repository.dart

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/notifications/notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
      {int page = 1});
  Future<Either<Failure, bool>> markNotificationAsRead(int notificationId);
  Future<Either<Failure, bool>> markAllNotificationsAsRead(); // NEW
  Future<Either<Failure, int>> getUnreadCount();
}
