// lib/services/version_service.dart

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class VersionService {
  static const String _key = 'app_version';

  /// Get current app version (e.g., "1.0.5")
  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version; // From pubspec.yaml
  }

  /// Parse version string to Version object for comparison
  static Version parseVersion(String versionString) {
    try {
      return Version.parse(versionString);
    } catch (e) {
      return Version(1, 0, 0); // Fallback
    }
  }

  /// Check if current version is less than required version
  static Future<bool> isUpdateRequired(String requiredVersion) async {
    try {
      final current = await getCurrentVersion();
      final currentVer = parseVersion(current);
      final requiredVer = parseVersion(requiredVersion);

      return currentVer < requiredVer;
    } catch (e) {
      print('Version check error: $e');
      return false; // Don't force update on error
    }
  }

  /// Check if current version is less than minimum version
  static Future<bool> isVersionSupported(String minimumVersion) async {
    return !(await isUpdateRequired(minimumVersion));
  }
}
