import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckerService {
  /// Compare current app version with server version
  /// Returns true if update is required
  static Future<bool> isUpdateRequired(String serverVersion) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      return _compareVersions(currentVersion, serverVersion);
    } catch (e) {
      // If we can't get package info, assume no update needed
      return false;
    }
  }

  /// Compare two version strings
  /// Returns true if serverVersion is greater than currentVersion
  static bool _compareVersions(String currentVersion, String serverVersion) {
    final current = _parseVersion(currentVersion);
    final server = _parseVersion(serverVersion);

    // Compare major version
    if (server[0] > current[0]) return true;
    if (server[0] < current[0]) return false;

    // Compare minor version
    if (server[1] > current[1]) return true;
    if (server[1] < current[1]) return false;

    // Compare patch version
    if (server[2] > current[2]) return true;

    return false;
  }

  /// Parse version string to list of integers
  static List<int> _parseVersion(String version) {
    try {
      // Remove any build number (e.g., "1.0.0+1" -> "1.0.0")
      final versionOnly = version.split('+').first;

      final parts = versionOnly.split('.');
      return [
        int.parse(parts[0]),
        int.parse(parts.length > 1 ? parts[1] : '0'),
        int.parse(parts.length > 2 ? parts[2] : '0'),
      ];
    } catch (e) {
      return [0, 0, 0];
    }
  }

  /// Get current app version
  static Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '0.0.0';
    }
  }
}
