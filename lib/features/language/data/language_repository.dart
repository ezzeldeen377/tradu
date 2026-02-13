import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class LanguageRepository {
  static const String _languageKey = 'selected_language';
  static const String _firstTimeKey = 'is_first_time';

  final FlutterSecureStorage _storage;

  LanguageRepository(this._storage);

  Future<String?> getSavedLanguage() async {
    try {
      return await _storage.read(key: _languageKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveLanguage(String languageCode) async {
    try {
      await _storage.write(key: _languageKey, value: languageCode);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isFirstTime() async {
    try {
      final value = await _storage.read(key: _firstTimeKey);
      return value == null;
    } catch (e) {
      return true;
    }
  }

  Future<void> setNotFirstTime() async {
    try {
      await _storage.write(key: _firstTimeKey, value: 'false');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearLanguageData() async {
    try {
      await _storage.delete(key: _languageKey);
      await _storage.delete(key: _firstTimeKey);
    } catch (e) {
      rethrow;
    }
  }
}
