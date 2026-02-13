import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Onboarding
  static Future<void> setOnboardingCompleted() async {
    await _storage.write(key: _onboardingCompletedKey, value: 'true');
  }

  static Future<bool> isOnboardingCompleted() async {
    final value = await _storage.read(key: _onboardingCompletedKey);
    return value == 'true';
  }

  // Token Management
  static Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // Clear all cache (useful for testing or logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
