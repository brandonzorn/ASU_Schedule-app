import "package:asu_schedule/models/schedule_models.dart";

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

String _isoDate(DateTime d) {
  final String year = d.year.toString().padLeft(4, "0");
  final String month = d.month.toString().padLeft(2, "0");
  final String day = d.day.toString().padLeft(2, "0");
  return "$year-$month-$day";
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
    final String dateStr = _isoDate(
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
