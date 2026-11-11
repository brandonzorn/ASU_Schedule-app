import "dart:async";

import "package:asu_schedule/controllers/schedule_controller.dart";
import "package:asu_schedule/controllers/theme_controller.dart";
import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/models/enums.dart";
import "package:asu_schedule/models/reference_models.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/ui/widgets/day_schedule_card.dart";
import "package:asu_schedule/ui/widgets/filter_bottom_sheet.dart";
import "package:asu_schedule/ui/widgets/week_selector_bar.dart";
import "package:asu_schedule/utils/date_format.dart";
import "package:material_ui/material_ui.dart";

class ScheduleScreen extends StatelessWidget {
  final ScheduleController controller;
  final ThemeController themeController;

  const ScheduleScreen({
    required this.controller,
    required this.themeController,
    super.key,
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
    if (msg == "errorConnection") {
      return i18n.errorConnection;
    }
    if (msg == "errorInvalidData") {
      return i18n.errorInvalidData;
    }
    if (msg == "errorRequest") {
      return i18n.errorRequest;
    }
    if (msg.startsWith("errorServer:")) {
      final String status = msg.substring("errorServer:".length);
      return i18n.errorServer(status);
    }
    return msg;
  }

  static String _isoDate(DateTime d) {
    final String month = d.month.toString().padLeft(2, "0");
    final String day = d.day.toString().padLeft(2, "0");
    return "${d.year.toString().padLeft(4, "0")}-$month-$day";
  }

  static IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

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
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable?>[controller, themeController]),
      builder: (BuildContext context, _) {
        final WeekItem? currentWeek = controller.currentWeekItem;
        final TextTheme textTheme = Theme.of(context).textTheme;
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        final int filterCount = _activeFiltersCount;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: colorScheme.surfaceContainer,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                    ),
                  ),
              ],
            ),
            actions: <Widget>[
              MenuAnchor(
                builder:
                    (
                      BuildContext context,
                      MenuController menuController,
                      Widget? child,
                    ) => IconButton(
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
                menuChildren: <Widget>[
                  for (final (ThemeMode mode, String label, IconData icon)
                      in <(ThemeMode, String, IconData)>[
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
                        (
                          ThemeMode.dark,
                          i18n.themeDark,
                          Icons.dark_mode_outlined,
                        ),
                      ])
                    MenuItemButton(
                      leadingIcon: Icon(icon),
                      trailingIcon: themeController.themeMode == mode
                          ? const Icon(Icons.check)
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
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final ScheduleWeek? schedule = controller.schedule;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (schedule == null) {
      if (controller.errorMessage == null) {
        return const SizedBox.shrink();
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
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

    final DateTime start = DateTime.parse("${schedule.weekStart}T00:00:00Z");
    final List<Widget> cards = <Widget>[];

    final Map<String, List<ScheduleLesson>> lessonsByDate =
        <String, List<ScheduleLesson>>{};
    for (final ScheduleLesson lesson in schedule.lessons) {
      (lessonsByDate[lesson.date] ??= <ScheduleLesson>[]).add(lesson);
    }

    for (int i = 0; i < 7; i++) {
      final String dateStr = _isoDate(
        DateTime.utc(start.year, start.month, start.day + i),
      );

      final List<ScheduleLesson> dayLessons = List<ScheduleLesson>.from(
        lessonsByDate[dateStr] ?? const <Object?>[],
      )..sort((ScheduleLesson a, ScheduleLesson b) => a.pair.compareTo(b.pair));

      final List<ScheduleCancellation> dayCancellations = schedule.cancellations
          .where((ScheduleCancellation c) {
            return dateStr.compareTo(c.startDate) >= 0 &&
                dateStr.compareTo(c.endDate) <= 0;
          })
          .toList();

      if (dayLessons.isEmpty && dayCancellations.isEmpty) {
        continue;
      }

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

    final String? nextDate = schedule.nextLessonDate;

    return RefreshIndicator(
      onRefresh: () => controller.loadSchedule(showLoading: false),

      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
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
                    children: <Widget>[
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
                    children: <Widget>[
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
        ),
      ),
    );
  }
}
