import "package:flutter/material.dart";

import "../../models/reference_models.dart";
import "../../models/schedule_models.dart";
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
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
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const Divider(height: 20),
            ...cancellations.map((c) => CancellationBanner(cancellation: c)),
            ...lessons.map(
              (lesson) =>
                  LessonTile(lesson: lesson, pairInfo: pairs[lesson.pair]),
            ),
          ],
        ),
      ),
    );
  }
}
