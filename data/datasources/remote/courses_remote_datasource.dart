// Path: lib/data/datasources/remote/courses_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/network/api_client.dart';
import '../../models/courses/course_model.dart';

abstract class CoursesRemoteDataSource {
  Future<List<CourseModel>> getCourses();
  Future<CourseModel> getCourseDetails(int courseId);
}

class CoursesRemoteDataSourceImpl implements CoursesRemoteDataSource {
  final ApiClient apiClient;

  CoursesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await apiClient.get(ApiConstants.COURSES_ENDPOINT);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> coursesJson = data['data'];
          return coursesJson.map((json) => CourseModel.fromJson(json)).toList();
        } else {
          throw ServerException(message: data['message'] ?? 'فشل في جلب الدورات');
        }
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في جلب الدورات',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'حدث خطأ غير متوقع');
    }
  }

  @override
  Future<CourseModel> getCourseDetails(int courseId) async {
    try {
      final response = await apiClient.get('${ApiConstants.COURSES_ENDPOINT}/$courseId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return CourseModel.fromJson(data['data']);
        } else {
          throw ServerException(message: data['message'] ?? 'فشل في جلب تفاصيل الدورة');
        }
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'فشل في جلب تفاصيل الدورة',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'حدث خطأ غير متوقع');
    }
  }
}

