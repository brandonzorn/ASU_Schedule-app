import "dart:convert";
import "dart:developer";

import "package:asu_schedule/models/cached_json.dart";
import "package:shared_preferences/shared_preferences.dart";

class StorageService {
  static const String _logName = "StorageService";

  static const String _courseKey = "saved_course";
  static const String _groupKey = "saved_group";
  static const String _teacherKey = "saved_teacher";

  static const String _themeKey = "theme_mode";

  static const String _scheduleCachePrefix = "cache_sched_";
  static const int _maxScheduleCacheEntries = 20;

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
    final Map<String, dynamic> envelope = <String, dynamic>{
      "savedAt": DateTime.now().toUtc().toIso8601String(),
      "data": data,
    };
    await prefs.setString(key, jsonEncode(envelope));

    if (key.startsWith(_scheduleCachePrefix)) {
      await _pruneScheduleCache(prefs, keepKey: key);
    }
  }

  Future<void> _pruneScheduleCache(
    SharedPreferences prefs, {
    required String keepKey,
  }) async {
    final List<String> scheduleKeys = prefs
        .getKeys()
        .where((String k) => k.startsWith(_scheduleCachePrefix))
        .toList();
    if (scheduleKeys.length <= _maxScheduleCacheEntries) {
      return;
    }

    final List<({String key, DateTime savedAt})> entries =
        <({String key, DateTime savedAt})>[];
    final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    for (final String k in scheduleKeys) {
      if (k == keepKey) {
        continue;
      }
      final DateTime savedAt = _extractSavedAt(prefs.getString(k)) ?? epoch;
      entries.add((key: k, savedAt: savedAt));
    }

    entries.sort(
      (
        ({String key, DateTime savedAt}) a,
        ({String key, DateTime savedAt}) b,
      ) => a.savedAt.compareTo(b.savedAt),
    );

    final int toRemove = scheduleKeys.length - _maxScheduleCacheEntries;
    for (int i = 0; i < toRemove && i < entries.length; i++) {
      await prefs.remove(entries[i].key);
    }
  }

  DateTime? _extractSavedAt(String? raw) {
    if (raw == null) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> && decoded["savedAt"] is String) {
        return DateTime.tryParse(decoded["savedAt"] as String);
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<CachedJson?> getJsonCache(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(key);
    if (raw == null) {
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final dynamic wrappedData = decoded["data"];
        if (wrappedData is Map<String, dynamic> &&
            decoded.containsKey("savedAt")) {
          final String? savedAtRaw = decoded["savedAt"] as String?;
          return CachedJson(
            data: wrappedData,
            savedAt: savedAtRaw != null ? DateTime.tryParse(savedAtRaw) : null,
          );
        }
        return CachedJson(data: decoded);
      }
    } on FormatException catch (e, st) {
      log(
        "Corrupted cache $key removed",
        name: _logName,
        error: e,
        stackTrace: st,
      );
    }
    await prefs.remove(key);
    return null;
  }
}
