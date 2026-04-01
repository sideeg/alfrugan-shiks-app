// Path: lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'dio_interceptors.dart';

class ApiClient {
  late Dio _dio;

  ApiClient({void Function()? onUnauthorized}) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.BASE_URL,
      connectTimeout:
          const Duration(milliseconds: AppConstants.CONNECTION_TIMEOUT),
      receiveTimeout:
          const Duration(milliseconds: AppConstants.RECEIVE_TIMEOUT),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _dio.interceptors.add(AuthInterceptor(onUnauthorized: onUnauthorized));
    _dio.interceptors.add(LoggingInterceptor());
  }

  Dio get dio => _dio;

  // Extract error message from server response
  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;

      // Case 1: { "success": false, "message": "كلمة المرور الحالية غير صحيحة" }
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }

      // Case 2: Laravel validation errors { "errors": { "field": ["error msg"] } }
      if (data is Map && data.containsKey('errors')) {
        final errors = data['errors'] as Map;
        return errors.values.first.first;
      }
    }

    // Fallback based on status code
    switch (e.response?.statusCode) {
      case 422:
        return 'خطأ في البيانات المُرسلة';
      case 401:
        return 'غير مرخص';
      case 403:
        return 'لا صلاحية';
      case 404:
        return 'لم يُجد';
      case 500:
        return 'حدث خطأ في الخادم';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  // GET request
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'تحقق من الاتصال بالإنترنت');
      }
      throw ServerException(message: _extractErrorMessage(e));
    }
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'تحقق من الاتصال بالإنترنت');
      }
      throw ServerException(message: _extractErrorMessage(e));
    }
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'تحقق من الاتصال بالإنترنت');
      }
      throw ServerException(message: _extractErrorMessage(e));
    }
  }

  // DELETE request
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'تحقق من الاتصال بالإنترنت');
      }
      throw ServerException(message: _extractErrorMessage(e));
    }
  }
}
