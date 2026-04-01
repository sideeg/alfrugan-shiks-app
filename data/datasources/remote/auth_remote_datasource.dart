// Path: lib/data/datasources/remote/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/network/api_client.dart';
import '../../models/auth/login_request_model.dart';
import '../../models/auth/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.LOGIN_ENDPOINT,
        data: request.toJson(),
      );

      // Check if the response contains success flag
      if (response.data['success'] == true) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في تسجيل الدخول',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Extract error message from response
      if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;

        // Get the message from the response
        String errorMessage = data['message'] ?? 'حدث خطأ غير متوقع';

        // If there are validation errors, you can handle them here
        if (data['errors'] != null) {
          // You can format validation errors if needed
          // For now, just use the main message
        }

        throw ServerException(
          message: errorMessage,
          statusCode: e.response?.statusCode,
        );
      }

      // If no response data, use ErrorHandler
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      // Re-throw if it's already a ServerException
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'حدث خطأ غير متوقع');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post('/sheikh/logout');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'حدث خطأ أثناء تسجيل الخروج');
    }
  }
}
