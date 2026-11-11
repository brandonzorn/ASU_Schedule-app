import "package:asu_schedule/models/reference_models.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/ui/widgets/cancellation_banner.dart";
import "package:asu_schedule/ui/widgets/lesson_tile.dart";
import "package:asu_schedule/utils/date_format.dart";
import "package:material_ui/material_ui.dart";

class DayScheduleCard extends StatelessWidget {
  final String weekdayName;
  final String dateStr;
  final List<ScheduleLesson> lessons;
  final List<ScheduleCancellation> cancellations;
  final Map<int, PairItem> pairs;

  const DayScheduleCard({
    required this.weekdayName, required this.dateStr, required this.lessons, required this.cancellations, required this.pairs, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(weekdayName, style: textTheme.titleMedium),
                Text(
                  formatIsoDate(dateStr),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 8),

            for (final ScheduleCancellation c in cancellations) CancellationBanner(cancellation: c),
            for (final (int index, ScheduleLesson lesson) in lessons.indexed) ...<Widget>[
              LessonTile(lesson: lesson, pairInfo: pairs[lesson.pair]),
              if (index != lessons.length - 1) const Divider(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
