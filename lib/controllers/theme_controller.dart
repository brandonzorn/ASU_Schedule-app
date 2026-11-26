import "dart:developer";

import "package:asu_schedule/services/storage_service.dart";
import "package:material_ui/material_ui.dart";

class ThemeController extends ChangeNotifier {
  final StorageService _storage;

  ThemeController(this._storage);

  ThemeMode themeMode = ThemeMode.system;

  Future<void> initialize() async {
    try {
      final String? name = await _storage.loadThemeMode();
      themeMode = ThemeMode.values.asNameMap()[name] ?? ThemeMode.system;
    } on Object catch (e, st) {
      log(
        "Failed to load theme",
        name: "ThemeController",
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == themeMode) {
      return;
    }
    themeMode = mode;
    notifyListeners();
    try {
      await _storage.saveThemeMode(mode.name);
    } on Object catch (e, st) {
      log(
        "Failed to save theme",
        name: "ThemeController",
        error: e,
        stackTrace: st,
      );
    }
  }
}
