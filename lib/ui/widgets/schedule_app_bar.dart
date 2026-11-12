import "package:asu_schedule/controllers/schedule_controller.dart";
import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/models/enums.dart";
import "package:asu_schedule/models/reference_models.dart";
import "package:asu_schedule/ui/widgets/filters_button.dart";
import "package:asu_schedule/ui/widgets/theme_mode_menu.dart";
import "package:asu_schedule/ui/widgets/week_selector_bar.dart";
import "package:material_ui/material_ui.dart";

class ScheduleAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double _weekBarHeight = 54;

  final ScheduleController controller;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final int activeFiltersCount;
  final VoidCallback? onFiltersPressed;

  const ScheduleAppBar({
    required this.controller,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.activeFiltersCount,
    required this.onFiltersPressed,
    super.key,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (controller.weekList != null ? _weekBarHeight : 0),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: _ScheduleTitle(currentWeek: controller.currentWeekItem),
      actions: <Widget>[
        ThemeModeMenu(themeMode: themeMode, onChanged: onThemeModeChanged),
        FiltersButton(count: activeFiltersCount, onPressed: onFiltersPressed),
      ],
      bottom: switch (controller.weekList) {
        final weekList? => PreferredSize(
          preferredSize: const Size.fromHeight(_weekBarHeight),
          child: WeekSelectorBar(
            weeks: weekList.items,
            selectedWeekStart: controller.selectedWeek,
            onWeekSelected: controller.selectWeek,
          ),
        ),
        null => null,
      },
    );
  }
}

class _ScheduleTitle extends StatelessWidget {
  final WeekItem? currentWeek;

  const _ScheduleTitle({required this.currentWeek});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final WeekItem? week = currentWeek;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(i18n.scheduleTitle),
        if (week != null)
          Text(
            i18n.weekHeader(week.number, week.color.localizedName(i18n)),
            style: textTheme.labelMedium?.copyWith(
              color: week.color == WeekColor.red
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
