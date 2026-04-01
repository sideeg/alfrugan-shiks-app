// Path: lib/data/models/auth/login_response_model.dart
import 'sheikh_model.dart';

class LoginResponseModel {
  final bool success;
  final String message;
  final LoginDataModel data;

  LoginResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: LoginDataModel.fromJson(json['data'] ?? {}),
    );
  }
}

class LoginDataModel {
  final SheikhModel user;
  final String token;
  final String? minimumRequiredVersion;

  LoginDataModel({
    required this.user,
    required this.token,
    this.minimumRequiredVersion,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      user: SheikhModel.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
      minimumRequiredVersion: json['minimum_required_version'], // ✅ NEW
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}
