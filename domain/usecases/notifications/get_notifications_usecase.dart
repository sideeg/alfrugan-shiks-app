// Path: lib/domain/usecases/notifications/get_notifications_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/notifications/notification_entity.dart';
import '../../repositories/notifications_repository.dart';

class GetNotificationsParams {
  final int page;
  const GetNotificationsParams({this.page = 1});
}

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) {
    return repository.getNotifications(page: params.page);
  }
}
