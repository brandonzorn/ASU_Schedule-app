import "dart:async";

import "package:flutter/material.dart";

import "controllers/schedule_controller.dart";
import "controllers/theme_controller.dart";
import "services/schedion_api_service.dart";
import "services/storage_service.dart";
import "ui/screens/schedule_screen.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final apiService = SchedionApiService(storageService);

  final themeController = ThemeController(storageService);
  await themeController.initialize();

  final scheduleController = ScheduleController(
    api: apiService,
    storage: storageService,
  );
  unawaited(scheduleController.initialize());

  runApp(
    SchedionApp(
      controller: scheduleController,
      themeController: themeController,
    ),
  );
}

class SchedionApp extends StatelessWidget {
  final ScheduleController controller;
  final ThemeController themeController;

  const SchedionApp({
    super.key,
    required this.controller,
    required this.themeController,
  });

  static const _seedColor = Color(0xFF2563EB);

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: "Расписание АГУ",
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: themeController.themeMode,
        home: ScheduleScreen(
          controller: controller,
          themeController: themeController,
        ),
      ),
    );
  }
}
