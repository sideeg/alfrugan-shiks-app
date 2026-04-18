// Path: lib/data/datasources/local/auth_local_datasource.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/auth/sheikh_model.dart';

abstract class AuthLocalDataSource {
  // ── Existing ──────────────────────────────────────────────────────────────
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(SheikhModel user);
  Future<SheikhModel?> getUser();
  Future<void> saveMinimumRequiredVersion(String? version);
  Future<String?> getMinimumRequiredVersion();
  Future<void> clearAuthData();

  // ── NEW: FCM Token ─────────────────────────────────────────────────────────
  // The FCM token is the device's push notification address.
  // It must be persisted so we can:
  //   1. Avoid re-registering on every app launch unnecessarily.
  //   2. Know which token to delete from the backend on logout.
  //   3. Detect token rotation (Firebase rotates tokens periodically).
  Future<void> saveFcmToken(String token);
  Future<String?> getFcmToken();
  Future<void> clearFcmToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  // ── Auth Token ─────────────────────────────────────────────────────────────

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

  // ── User ───────────────────────────────────────────────────────────────────

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

  // ── App Version ────────────────────────────────────────────────────────────

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
    return sharedPreferences.getString(AppConstants.VERSION_KEY);
  }

  // ── FCM Token (NEW) ────────────────────────────────────────────────────────

  @override
  Future<void> saveFcmToken(String token) async {
    try {
      await sharedPreferences.setString(AppConstants.FCM_TOKEN_KEY, token);
    } catch (e) {
      throw CacheException(message: 'فشل في حفظ رمز الإشعارات');
    }
  }

  @override
  Future<String?> getFcmToken() async {
    try {
      return sharedPreferences.getString(AppConstants.FCM_TOKEN_KEY);
    } catch (e) {
      throw CacheException(message: 'فشل في جلب رمز الإشعارات');
    }
  }

  @override
  Future<void> clearFcmToken() async {
    try {
      await sharedPreferences.remove(AppConstants.FCM_TOKEN_KEY);
    } catch (e) {
      throw CacheException(message: 'فشل في مسح رمز الإشعارات');
    }
  }

  // ── Clear All ──────────────────────────────────────────────────────────────

  @override
  Future<void> clearAuthData() async {
    try {
      await sharedPreferences.remove(AppConstants.TOKEN_KEY);
      await sharedPreferences.remove(AppConstants.USER_KEY);
      await sharedPreferences.remove(AppConstants.VERSION_KEY);
      // FCM token has its own clear method (called separately in FcmService
      // during logout BEFORE the backend delete call, so we keep it
      // independent here rather than wiping it automatically).
    } catch (e) {
      throw CacheException(message: 'فشل في مسح بيانات المصادقة');
    }
  }
}
