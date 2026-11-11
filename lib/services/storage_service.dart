import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class StorageService {
  static const _courseKey = "saved_course";
  static const _groupKey = "saved_group";
  static const _teacherKey = "saved_teacher";

  Future<({int? course, int? groupId, int? teacherId})> loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      course: prefs.getInt(_courseKey),
      groupId: prefs.getInt(_groupKey),
      teacherId: prefs.getInt(_teacherKey),
    );
  }

  Future<void> saveFilters({int? course, int? groupId, int? teacherId}) async {
    final prefs = await SharedPreferences.getInstance();
    course != null
        ? await prefs.setInt(_courseKey, course)
        : await prefs.remove(_courseKey);
    groupId != null
        ? await prefs.setInt(_groupKey, groupId)
        : await prefs.remove(_groupKey);
    teacherId != null
        ? await prefs.setInt(_teacherKey, teacherId)
        : await prefs.remove(_teacherKey);
  }

  Future<void> saveJsonCache(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future? getJsonCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}