import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/utils/date_format.dart";
import "package:material_ui/material_ui.dart";

class EmptyWeekView extends StatelessWidget {
  final String? nextLessonDate;

  const EmptyWeekView({required this.nextLessonDate, super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String? nextDate = nextLessonDate;

    return Padding(
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
    );
  }
}
