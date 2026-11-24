import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/utils/date_format.dart";

class DaySchedule {
  final int weekdayIndex;
  final String dateStr;
  final List<ScheduleLesson> lessons;
  final List<ScheduleCancellation> cancellations;

  const DaySchedule({
    required this.weekdayIndex,
    required this.dateStr,
    required this.lessons,
    required this.cancellations,
  });
}

List<DaySchedule> groupScheduleByDay(ScheduleWeek schedule) {
  final DateTime start = DateTime.parse("${schedule.weekStart}T00:00:00Z");

  final Map<String, List<ScheduleLesson>> lessonsByDate =
      <String, List<ScheduleLesson>>{};
  for (final ScheduleLesson lesson in schedule.lessons) {
    (lessonsByDate[lesson.date] ??= <ScheduleLesson>[]).add(lesson);
  }

  final List<DaySchedule> days = <DaySchedule>[];
  for (int i = 0; i < 7; i++) {
    final String dateStr = toIsoDate(
      DateTime.utc(start.year, start.month, start.day + i),
    );

    final List<ScheduleLesson> lessons = List<ScheduleLesson>.from(
      lessonsByDate[dateStr] ?? const <ScheduleLesson>[],
    )..sort((ScheduleLesson a, ScheduleLesson b) => a.pair.compareTo(b.pair));

    final List<ScheduleCancellation> cancellations = schedule.cancellations
        .where(
          (ScheduleCancellation c) =>
              dateStr.compareTo(c.startDate) >= 0 &&
              dateStr.compareTo(c.endDate) <= 0,
        )
        .toList();

    if (lessons.isEmpty && cancellations.isEmpty) {
      continue;
    }

    days.add(
      DaySchedule(
        weekdayIndex: i,
        dateStr: dateStr,
        lessons: lessons,
        cancellations: cancellations,
      ),
    );
  }
  return days;
}
