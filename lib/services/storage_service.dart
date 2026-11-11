import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

class StorageService {
  static const String _courseKey = "saved_course";
  static const String _groupKey = "saved_group";
  static const String _teacherKey = "saved_teacher";

  static const String _themeKey = "theme_mode";

  Future<String?> loadThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  Future<void> saveThemeMode(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, name);
  }

  Future<({int? course, int? groupId, int? teacherId})>
  loadSavedFilters() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (
      course: prefs.getInt(_courseKey),
      groupId: prefs.getInt(_groupKey),
      teacherId: prefs.getInt(_teacherKey),
    );
  }

  Future<void> _setOrRemove(
    SharedPreferences prefs,
    String key,
    int? value,
  ) async {
    if (value != null) {
      await prefs.setInt(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  Future<void> saveFilters({int? course, int? groupId, int? teacherId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _setOrRemove(prefs, _courseKey, course);
    await _setOrRemove(prefs, _groupKey, groupId);
    await _setOrRemove(prefs, _teacherKey, teacherId);
  }

  Future<void> saveJsonCache(String key, Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getJsonCache(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(key);
    if (raw == null) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      // Выбрасываем поврежденный кэш
    }
    await prefs.remove(key);
    return null;
  }
}
