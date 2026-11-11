import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/models/enums.dart";
import "package:asu_schedule/models/reference_models.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:material_ui/material_ui.dart";

class LessonTile extends StatelessWidget {
  final ScheduleLesson lesson;
  final PairItem? pairInfo;

  const LessonTile({required this.lesson, super.key, this.pairInfo});

  static bool _has(String? value) => value != null && value.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String timeText = pairInfo?.formattedTime ?? "";
    final bool isCancelled = lesson.isCancelled;

    final List<String> metaTags = <String>[
      if (lesson.kind != LessonKind.none) lesson.kind.localizedName(i18n),
      if (_has(lesson.room)) i18n.roomNumber(lesson.room),
      if (lesson.subgroup != null) i18n.subgroupNumber(lesson.subgroup),
      if (_has(lesson.groupName)) lesson.groupName!,
      if (_has(lesson.associationName)) lesson.associationName!,
      if (lesson.teachers.isNotEmpty)
        lesson.teachers.map((ScheduleTeacher t) => t.shortName).join(", "),
    ];

    final String cancellationText = _has(lesson.cancellationReason)
        ? i18n.canceledReason(lesson.cancellationReason)
        : i18n.lessonCanceled;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  i18n.pairNumber(lesson.pair),
                  style: textTheme.titleSmall?.copyWith(
                    color: isCancelled
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                  ),
                ),
                if (timeText.isNotEmpty)
                  Text(
                    timeText,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: <Widget>[
                Text(
                  lesson.discipline,
                  style: textTheme.titleMedium?.copyWith(
                    color: isCancelled
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                    decorationColor: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (metaTags.isNotEmpty)
                  Text(
                    metaTags.join(" • "),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (isCancelled)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cancellationText,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
