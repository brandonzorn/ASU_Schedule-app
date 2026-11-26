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

int _compareLessons(ScheduleLesson a, ScheduleLesson b) {
  final int byPair = a.pair.compareTo(b.pair);
  if (byPair != 0) {
    return byPair;
  }
  final int bySubgroup = (a.subgroup ?? 0).compareTo(b.subgroup ?? 0);
  return bySubgroup != 0 ? bySubgroup : a.id.compareTo(b.id);
}

String _dateOnly(String iso) => iso.length >= 10 ? iso.substring(0, 10) : iso;

List<DaySchedule> groupScheduleByDay(ScheduleWeek schedule) {
  final DateTime? start = DateTime.tryParse(
    "${_dateOnly(schedule.weekStart)}T00:00:00Z",
  );
  if (start == null) {
    return const <DaySchedule>[];
  }

  final Map<String, List<ScheduleLesson>> lessonsByDate =
      <String, List<ScheduleLesson>>{};
  for (final ScheduleLesson lesson in schedule.lessons) {
    final String lessonDate = _dateOnly(lesson.date);
    (lessonsByDate[lessonDate] ??= <ScheduleLesson>[]).add(lesson);
  }

  final List<DaySchedule> days = <DaySchedule>[];
  for (int i = 0; i < 7; i++) {
    final DateTime dayDate = DateTime.utc(start.year, start.month, start.day + i);
    final String dateStr = toIsoDate(dayDate);

    final List<ScheduleLesson> lessons = List<ScheduleLesson>.from(
      lessonsByDate[dateStr] ?? const <ScheduleLesson>[],
    )..sort(_compareLessons);

    final List<ScheduleCancellation> cancellations = schedule.cancellations
        .where(
          (ScheduleCancellation c) =>
              dateStr.compareTo(_dateOnly(c.startDate)) >= 0 &&
              dateStr.compareTo(_dateOnly(c.endDate)) <= 0,
        )
        .toList(growable: false);

    if (lessons.isEmpty && cancellations.isEmpty) {
      continue;
    }

    days.add(
      DaySchedule(
        weekdayIndex: dayDate.weekday - 1,
        dateStr: dateStr,
        lessons: lessons,
        cancellations: cancellations,
      ),
    );
  }
  return days;
}
