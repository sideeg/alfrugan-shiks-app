// path: lib/data/datasources/local/profile_local_data_source.dart

import 'dart:convert';
import 'package:quran_sheikh_app/core/errors/exceptions.dart';
import 'package:quran_sheikh_app/data/models/auth/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel> getCachedProfile();
  Future<void> cacheProfile(ProfileModel profile);
  Future<void> clearCachedProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedProfileKey = 'CACHED_PROFILE';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ProfileModel> getCachedProfile() async {
    final jsonString = sharedPreferences.getString(cachedProfileKey);
    if (jsonString != null) {
      final jsonData = json.decode(jsonString);
      return ProfileModel.fromJson(jsonData);
    } else {
      throw CacheException(message: 'No cached profile found');
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    final jsonString = json.encode(profile.toJson());
    await sharedPreferences.setString(cachedProfileKey, jsonString);
  }

  @override
  Future<void> clearCachedProfile() async {
    await sharedPreferences.remove(cachedProfileKey);
  }
}
