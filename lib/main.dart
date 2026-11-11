import "dart:async";

import "package:asu_schedule/controllers/schedule_controller.dart";
import "package:asu_schedule/controllers/theme_controller.dart";
import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/services/schedion_api_service.dart";
import "package:asu_schedule/services/storage_service.dart";
import "package:asu_schedule/ui/screens/schedule_screen.dart";
import "package:dynamic_color/dynamic_color.dart";
import "package:material_ui/material_ui.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final StorageService storageService = StorageService();
  final SchedionApiService apiService = SchedionApiService(storageService);

  final ThemeController themeController = ThemeController(storageService);
  await themeController.initialize();

  final ScheduleController scheduleController = ScheduleController(
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
    required this.controller,
    required this.themeController,
    super.key,
  });

  static const Color _seedColor = Color(0xFF2563EB);

  ThemeData _buildTheme(Brightness brightness, ColorScheme? dynamicScheme) {
    return ThemeData(
      colorScheme:
          dynamicScheme?.harmonized() ??
          ColorScheme.fromSeed(seedColor: _seedColor, brightness: brightness),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (BuildContext context, _) => DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) =>
            MaterialApp(
              onGenerateTitle: (BuildContext context) =>
                  AppLocalizations.of(context)!.appTitle,
              theme: _buildTheme(Brightness.light, lightDynamic),
              darkTheme: _buildTheme(Brightness.dark, darkDynamic),
              themeMode: themeController.themeMode,
              localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: ScheduleScreen(
                controller: controller,
                themeController: themeController,
              ),
            ),
      ),
    );
  }
}
