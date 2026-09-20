import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _autoPunctuateKey = 'auto_punctuate';
  static const String _autoCapitalizeKey = 'auto_capitalize';
  static const String _vibrationFeedbackKey = 'vibration_feedback';
  static const String _selectedLanguageKey = 'selected_language';
  static const String _historyKey = 'history';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  bool? getBool(String key) => prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);

  String? getString(String key) => prefs.getString(key);
  Future<bool> setString(String key, String value) => prefs.setString(key, value);

  List<String>? getStringList(String key) => prefs.getStringList(key);
  Future<bool> setStringList(String key, List<String> value) => prefs.setStringList(key, value);

  int? getInt(String key) => prefs.getInt(key);
  Future<bool> setInt(String key, int value) => prefs.setInt(key, value);

  double? getDouble(String key) => prefs.getDouble(key);
  Future<bool> setDouble(String key, double value) => prefs.setDouble(key, value);

  Future<bool> remove(String key) => prefs.remove(key);
  Future<bool> clear() => prefs.clear();
}