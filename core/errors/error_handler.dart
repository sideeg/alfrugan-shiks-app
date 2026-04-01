// Path: lib/core/errors/error_handler.dart
import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(message: exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    } else if (exception is AuthException) {
      return AuthFailure(message: exception.message);
    } else {
      return ServerFailure(message: "حدث خطأ غير متوقع");
    }
  }

  static Exception handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: "انتهت مهلة الاتصال");
      case DioExceptionType.badResponse:
        return ServerException(
          message: error.response?.data['message'] ?? "خطأ في الخادم",
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return NetworkException(message: "تم إلغاء الطلب");
      case DioExceptionType.unknown:
        return NetworkException(message: "تحقق من اتصال الإنترنت");
      default:
        return ServerException(message: "حدث خطأ غير متوقع");
    }
  }
}

