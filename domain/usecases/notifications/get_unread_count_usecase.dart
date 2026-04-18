// Path: lib/domain/usecases/notifications/get_unread_count_usecase.dart

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/notifications_repository.dart';

class GetUnreadCountUseCase {
  final NotificationsRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<Either<Failure, int>> call() {
    return repository.getUnreadCount();
  }
}
