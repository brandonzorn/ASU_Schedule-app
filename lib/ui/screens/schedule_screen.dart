import "dart:async";

import "package:asu_schedule/controllers/schedule_controller.dart";
import "package:asu_schedule/controllers/theme_controller.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/ui/widgets/filter_bottom_sheet.dart";
import "package:asu_schedule/ui/widgets/schedule_app_bar.dart";
import "package:asu_schedule/ui/widgets/schedule_body.dart";
import "package:material_ui/material_ui.dart";

class ScheduleScreen extends StatelessWidget {
  final ScheduleController controller;
  final ThemeController themeController;

  const ScheduleScreen({
    required this.controller,
    required this.themeController,
    super.key,
  });

  int get _activeFiltersCount => <int?>[
    controller.selectedCourse,
    controller.selectedGroupId,
    controller.selectedTeacherId,
  ].whereType<int>().length;

  void _showFilters(BuildContext context) {
    final ScheduleFilters? filters = controller.schedule?.filters;
    if (filters == null) {
      return;
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (_) => FilterBottomSheet(
          filters: filters,
          initialCourse: controller.selectedCourse,
          initialGroupId: controller.selectedGroupId,
          initialTeacherId: controller.selectedTeacherId,
          onApply: controller.applyFilters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable?>[controller, themeController]),
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: ScheduleAppBar(
            controller: controller,
            themeMode: themeController.themeMode,
            onThemeModeChanged: (ThemeMode mode) =>
                unawaited(themeController.setThemeMode(mode)),
            activeFiltersCount: _activeFiltersCount,
            onFiltersPressed: controller.schedule != null
                ? () => _showFilters(context)
                : null,
          ),
          body: ScheduleBody(controller: controller),
        );
      },
    );
  }
}
