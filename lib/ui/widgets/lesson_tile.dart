import "package:flutter/material.dart";

import "../../models/enums.dart";
import "../../models/reference_models.dart";
import "../../models/schedule_models.dart";

class LessonTile extends StatelessWidget {
  final ScheduleLesson lesson;
  final PairItem? pairInfo;

  const LessonTile({super.key, required this.lesson, this.pairInfo});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final timeText = pairInfo?.formattedTime ?? "";

    final metaTags = <String>[
      if (lesson.kind != LessonKind.none) lesson.kind.label,
      if (lesson.room != null) "Ауд. ${lesson.room}",
      if (lesson.subgroup != null) "Подгр. ${lesson.subgroup}",
      if (lesson.groupName != null) lesson.groupName!,
      if (lesson.associationName != null) lesson.associationName!,
      if (lesson.teachers.isNotEmpty)
        lesson.teachers.map((t) => t.shortName).join(", "),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${lesson.pair} пара",
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (timeText.isNotEmpty)
                  Text(
                    timeText,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.discipline,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: lesson.isCancelled
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (metaTags.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    metaTags.join(" • "),
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                if (lesson.isCancelled) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Отменено: ${lesson.cancellationReason}",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
