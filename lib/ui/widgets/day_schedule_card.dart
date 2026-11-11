import "package:material_ui/material_ui.dart";

import "../../models/reference_models.dart";
import "../../models/schedule_models.dart";
import "../../utils/date_format.dart";
import "cancellation_banner.dart";
import "lesson_tile.dart";

class DayScheduleCard extends StatelessWidget {
  final String weekdayName;
  final String dateStr;
  final List<ScheduleLesson> lessons;
  final List<ScheduleCancellation> cancellations;
  final Map<int, PairItem> pairs;

  const DayScheduleCard({
    super.key,
    required this.weekdayName,
    required this.dateStr,
    required this.lessons,
    required this.cancellations,
    required this.pairs,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weekdayName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  formatIsoDate(dateStr),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Divider(height: 8),

            for (final c in cancellations) CancellationBanner(cancellation: c),
            for (final (index, lesson) in lessons.indexed) ...[
              LessonTile(lesson: lesson, pairInfo: pairs[lesson.pair]),
              if (index != lessons.length - 1)
                Divider(
                  height: 8,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
