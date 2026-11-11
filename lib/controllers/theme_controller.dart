import "package:flutter/material.dart";

import "../services/storage_service.dart";

class ThemeController extends ChangeNotifier {
  final StorageService _storage;

  ThemeController(this._storage);

  ThemeMode themeMode = ThemeMode.system;

  Future<void> initialize() async {
    final name = await _storage.loadThemeMode();
    themeMode = ThemeMode.values.asNameMap()[name] ?? ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == themeMode) return;
    themeMode = mode;
    notifyListeners();
    await _storage.saveThemeMode(mode.name);
  }
}
