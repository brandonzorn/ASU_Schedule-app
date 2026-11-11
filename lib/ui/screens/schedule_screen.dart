import "dart:async";

import "package:material_ui/material_ui.dart";

import "../../controllers/schedule_controller.dart";
import "../../controllers/theme_controller.dart";
import "../../i18n/app_localizations.dart";
import "../../models/enums.dart";
import "../../models/schedule_models.dart";
import "../../utils/date_format.dart";
import "../widgets/day_schedule_card.dart";
import "../widgets/filter_bottom_sheet.dart";
import "../widgets/week_selector_bar.dart";

class ScheduleScreen extends StatelessWidget {
  final ScheduleController controller;
  final ThemeController themeController;

  const ScheduleScreen({
    super.key,
    required this.controller,
    required this.themeController,
  });

  static String _weekdayName(AppLocalizations i18n, int index) =>
      switch (index) {
        0 => i18n.monday,
        1 => i18n.tuesday,
        2 => i18n.wednesday,
        3 => i18n.thursday,
        4 => i18n.friday,
        5 => i18n.saturday,
        6 => i18n.sunday,
        _ => "",
      };

  static String _formatErrorMessage(AppLocalizations i18n, String msg) {
    if (msg == "errorConnection") return i18n.errorConnection;
    if (msg == "errorInvalidData") return i18n.errorInvalidData;
    if (msg == "errorRequest") return i18n.errorRequest;
    if (msg.startsWith("errorServer:")) {
      final status = msg.substring("errorServer:".length);
      return i18n.errorServer(status);
    }
    return msg;
  }

  static String _isoDate(DateTime d) {
    final month = d.month.toString().padLeft(2, "0");
    final day = d.day.toString().padLeft(2, "0");
    return "${d.year.toString().padLeft(4, "0")}-$month-$day";
  }

  static IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  int get _activeFiltersCount => [
    controller.selectedCourse,
    controller.selectedGroupId,
    controller.selectedTeacherId,
  ].whereType<int>().length;

  void _showFilters(BuildContext context) {
    final filters = controller.schedule?.filters;
    if (filters == null) return;

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
    final i18n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, themeController]),
      builder: (context, _) {
        final currentWeek = controller.currentWeekItem;
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        final filterCount = _activeFiltersCount;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i18n.scheduleTitle),
                if (currentWeek != null)
                  Text(
                    i18n.weekHeader(
                      currentWeek.number,
                      currentWeek.color.localizedName(i18n),
                    ),
                    style: textTheme.labelMedium?.copyWith(
                      color: currentWeek.color == WeekColor.red
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            actions: [
              MenuAnchor(
                builder: (context, menuController, child) => IconButton(
                  icon: Icon(_themeIcon(themeController.themeMode)),
                  tooltip: i18n.themeTooltip,
                  onPressed: () {
                    if (menuController.isOpen) {
                      menuController.close();
                    } else {
                      menuController.open();
                    }
                  },
                ),
                menuChildren: [
                  for (final (mode, label, icon) in [
                    (
                      ThemeMode.system,
                      i18n.themeSystem,
                      Icons.brightness_auto_outlined,
                    ),
                    (
                      ThemeMode.light,
                      i18n.themeLight,
                      Icons.light_mode_outlined,
                    ),
                    (ThemeMode.dark, i18n.themeDark, Icons.dark_mode_outlined),
                  ])
                    MenuItemButton(
                      leadingIcon: Icon(icon),
                      trailingIcon: themeController.themeMode == mode
                          ? const Icon(Icons.check, size: 18)
                          : null,
                      onPressed: () =>
                          unawaited(themeController.setThemeMode(mode)),
                      child: Text(label),
                    ),
                ],
              ),
              IconButton(
                tooltip: i18n.filtersTitle,
                onPressed: controller.schedule != null
                    ? () => _showFilters(context)
                    : null,
                icon: Badge.count(
                  count: filterCount,
                  isLabelVisible: filterCount > 0,
                  child: const Icon(Icons.tune),
                ),
              ),
            ],
            bottom: controller.weekList != null
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(54),
                    child: WeekSelectorBar(
                      weeks: controller.weekList!.items,
                      selectedWeekStart: controller.selectedWeek,
                      onWeekSelected: controller.selectWeek,
                    ),
                  )
                : null,
          ),
          body: _buildContent(context),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final schedule = controller.schedule;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (schedule == null) {
      if (controller.errorMessage == null) return const SizedBox.shrink();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              Text(
                _formatErrorMessage(i18n, controller.errorMessage!),
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              FilledButton.icon(
                onPressed: controller.initialize,
                icon: const Icon(Icons.refresh),
                label: Text(i18n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final start = DateTime.parse("${schedule.weekStart}T00:00:00Z");
    final cards = <Widget>[];

    final lessonsByDate = <String, List<ScheduleLesson>>{};
    for (final lesson in schedule.lessons) {
      (lessonsByDate[lesson.date] ??= []).add(lesson);
    }

    for (var i = 0; i < 7; i++) {
      final dateStr = _isoDate(
        DateTime.utc(start.year, start.month, start.day + i),
      );

      final dayLessons =
          List<ScheduleLesson>.from(lessonsByDate[dateStr] ?? const [])
            ..sort((a, b) => a.pair.compareTo(b.pair));

      final dayCancellations = schedule.cancellations.where((c) {
        return dateStr.compareTo(c.startDate) >= 0 &&
            dateStr.compareTo(c.endDate) <= 0;
      }).toList();

      if (dayLessons.isEmpty && dayCancellations.isEmpty) continue;

      cards.add(
        DayScheduleCard(
          weekdayName: _weekdayName(i18n, i),
          dateStr: dateStr,
          lessons: dayLessons,
          cancellations: dayCancellations,
          pairs: controller.pairs,
        ),
      );
    }

    final nextDate = schedule.nextLessonDate;

    return RefreshIndicator(
      onRefresh: () => controller.loadSchedule(showLoading: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                spacing: 12,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.onErrorContainer,
                  ),
                  Expanded(
                    child: Text(
                      _formatErrorMessage(i18n, controller.errorMessage!),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (cards.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 64),
              child: Column(
                spacing: 8,
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  Text(
                    i18n.noLessonsThisWeek,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium,
                  ),
                  if (nextDate != null)
                    Text(
                      i18n.nextLessonDate(formatIsoDate(nextDate)),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            )
          else
            ...cards,
        ],
      ),
    );
  }
}
