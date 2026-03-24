import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static SharedPreferences? _prefs;

  /// INIT (app start pe call karna)
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// SAVE
  static Future setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  /// GET
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// REMOVE
  static Future remove(String key) async {
    await _prefs?.remove(key);
  }


  static Future clearAll() async {
    await _prefs?.clear();
  }
}