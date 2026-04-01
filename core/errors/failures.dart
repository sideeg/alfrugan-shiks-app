// Path: lib/core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  ServerFailure({String message = 'حدث خطأ في الخادم'})
      : super(message: message);
}

class NetworkFailure extends Failure {
  NetworkFailure({String message = 'تحقق من الاتصال بالإنترنت'})
      : super(message: message);
}

class CacheFailure extends Failure {
  CacheFailure({String message = 'فشل في تحميل البيانات المحفوظة'})
      : super(message: message);
}

class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}
