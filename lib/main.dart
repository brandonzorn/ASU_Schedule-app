import "dart:async";

import "package:flutter/material.dart";

import "controllers/schedule_controller.dart";
import "services/schedion_api_service.dart";
import "services/storage_service.dart";
import "ui/screens/schedule_screen.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final apiService = SchedionApiService(storageService);
  final scheduleController = ScheduleController(
    api: apiService,
    storage: storageService,
  );
  unawaited(scheduleController.initialize());

  runApp(SchedionApp(controller: scheduleController));
}

class SchedionApp extends StatelessWidget {
  final ScheduleController controller;

  const SchedionApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Расписание АГУ",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: ScheduleScreen(controller: controller),
    );
  }
}
