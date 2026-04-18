// Path: lib/domain/usecases/notifications/mark_all_as_read_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/notifications_repository.dart';

class MarkAllAsReadUseCase {
  final NotificationsRepository repository;
  MarkAllAsReadUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.markAllNotificationsAsRead();
  }
}
