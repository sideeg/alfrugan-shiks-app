// Path: lib/data/datasources/local/auth_local_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/auth/sheikh_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(SheikhModel user);
  Future<void> saveMinimumRequiredVersion(String? version);
  Future<SheikhModel?> getUser();
  Future<String?> getMinimumRequiredVersion();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveToken(String token) async {
    try {
      await sharedPreferences.setString(AppConstants.TOKEN_KEY, token);
    } catch (e) {
      throw CacheException(message: 'فشل في حفظ الرمز المميز');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(AppConstants.TOKEN_KEY);
    } catch (e) {
      throw CacheException(message: 'فشل في جلب الرمز المميز');
    }
  }

  @override
  Future<void> saveUser(SheikhModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await sharedPreferences.setString(AppConstants.USER_KEY, userJson);
    } catch (e) {
      throw CacheException(message: 'فشل في حفظ بيانات المستخدم');
    }
  }

  @override
  Future<SheikhModel?> getUser() async {
    try {
      final userJson = sharedPreferences.getString(AppConstants.USER_KEY);
      if (userJson != null) {
        final userMap = json.decode(userJson);
        return SheikhModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'فشل في جلب بيانات المستخدم');
    }
  }

  @override
  Future<void> saveMinimumRequiredVersion(String? version) async {
    if (version != null) {
      await sharedPreferences.setString(AppConstants.VERSION_KEY, version);
    } else {
      await sharedPreferences.remove(AppConstants.VERSION_KEY);
    }
  }

  @override
  Future<String?> getMinimumRequiredVersion() async {
    return sharedPreferences.getString(AppConstants.VERSION_KEY); // ✅ NEW
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await sharedPreferences.remove(AppConstants.TOKEN_KEY);
      await sharedPreferences.remove(AppConstants.USER_KEY);
      await sharedPreferences.remove(AppConstants.VERSION_KEY);
    } catch (e) {
      throw CacheException(message: 'فشل في مسح بيانات المصادقة');
    }
  }
}
