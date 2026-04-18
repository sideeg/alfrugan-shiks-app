// path: lib/data/datasources/remote/profile_remote_data_source.dart

import 'package:quran_sheikh_app/core/constants/api_constants.dart';
import 'package:quran_sheikh_app/core/errors/exceptions.dart';
import 'package:quran_sheikh_app/core/network/api_client.dart';
import 'package:quran_sheikh_app/data/models/auth/profile_model.dart';
import 'package:quran_sheikh_app/domain/entities/profile_update_request.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(ProfileUpdateRequest request);
  Future<ProfileModel> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await apiClient.get(ApiConstants.PROFILE_ENDPOINT);

      if (response.statusCode == 200) {
        final data = response.data;
        return ProfileModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: 'Failed to get profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileUpdateRequest request) async {
    try {
      // Prepare form data for multipart request if image exists
      if (request.profileImageFile != null) {
        final formData = <String, dynamic>{
          'name': request.name,
          'email': request.email,
          if (request.phone != null && request.phone!.isNotEmpty)
            'phone': request.phone,
          if (request.nationalId != null && request.nationalId!.isNotEmpty)
            'national_id': request.nationalId,
          if (request.nationality != null && request.nationality!.isNotEmpty)
            'nationality': request.nationality,
          if (request.qiraat != null && request.qiraat!.isNotEmpty)
            'qiraat': request.qiraat,
          'profile_image': request.profileImageFile,
        };

        final response = await apiClient.post(
          ApiConstants.PROFILE_ENDPOINT,
          data: formData,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          return ProfileModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: 'Failed to update profile',
            statusCode: response.statusCode,
          );
        }
      } else {
        // Regular JSON update without image
        final requestData = <String, dynamic>{
          'name': request.name,
          'email': request.email,
          if (request.phone != null && request.phone!.isNotEmpty)
            'phone': request.phone,
          if (request.nationalId != null && request.nationalId!.isNotEmpty)
            'national_id': request.nationalId,
          if (request.nationality != null && request.nationality!.isNotEmpty)
            'nationality': request.nationality,
          if (request.qiraat != null && request.qiraat!.isNotEmpty)
            'qiraat': request.qiraat,
        };

        final response = await apiClient.put(
          ApiConstants.PROFILE_ENDPOINT,
          data: requestData,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          return ProfileModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: 'Failed to update profile',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProfileModel> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.PROFILE_ENDPOINT,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ProfileModel.fromJson(data['data']);
      } else {
        throw ServerException(
          message: 'Failed to update password',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
