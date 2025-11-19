import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String isLogin = "isLogin";
  static const String isToken = "isToken";
  static const String isName = "isName";

  // ===========================
  // SAVE DATA
  // ===========================

  static Future<void> saveLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(isLogin, value);
  }

  static Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(isToken, value);
  }

  static Future<void> saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(isName, value);
  }

  // ===========================
  // GET DATA
  // ===========================

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLogin);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(isToken);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(isName);
  }

  // ===========================
  // REMOVE DATA (individual)
  // ===========================

  static Future<void> removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isLogin);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isToken);
  }

  static Future<void> removeName() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isName);
  }

  // ===========================
  // CLEAR ALL (LOGOUT)
  // ===========================
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // <-- Hapus seluruh data
  }

  // DARK MODE
  static const String themeMode = "themeMode"; // "light" / "dark"

  // simpan
  static Future<void> saveTheme(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(themeMode, mode);
  }

  // ambil
  static Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(themeMode);
  }
}
