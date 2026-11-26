import "package:asu_schedule/models/enums.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/utils/schedule_day_grouping.dart";
import "package:flutter_test/flutter_test.dart";

ScheduleLesson _lesson({
  required int id,
  required String date,
  required int pair,
  int? subgroup,
}) => ScheduleLesson(
  id: id,
  date: date,
  pair: pair,
  kind: LessonKind.lecture,
  disciplineId: 1,
  discipline: "Math",
  associationGroupIds: const <int>[],
  teachers: const <ScheduleTeacher>[],
  subgroup: subgroup,
);

void main() {
  const ScheduleFilters emptyFilters = ScheduleFilters(
    groups: <GroupItem>[],
    teachers: <TeacherItem>[],
    courses: <int>[],
  );

  test("groups and sorts lessons by pair, subgroup, and id", () {
    final ScheduleWeek week = ScheduleWeek(
      weekStart: "2026-11-23",
      weekEnd: "2026-11-29",
      lessons: <ScheduleLesson>[
        _lesson(id: 3, date: "2026-11-23", pair: 2),
        _lesson(id: 2, date: "2026-11-23", pair: 1, subgroup: 2),
        _lesson(id: 1, date: "2026-11-23", pair: 1, subgroup: 1),
      ],
      cancellations: const <ScheduleCancellation>[],
      filters: emptyFilters,
    );

    final List<DaySchedule> days = groupScheduleByDay(week);
    expect(days, hasLength(1));
    expect(days.first.weekdayIndex, 0);
    expect(
      days.first.lessons.map((ScheduleLesson l) => l.id).toList(),
      <int>[1, 2, 3],
    );
  });

  test("derives weekdayIndex from calendar date and normalizes timestamps", () {
    // 2026-11-25 is a Wednesday (weekday == 3 -> index 2).
    final ScheduleWeek week = ScheduleWeek(
      weekStart: "2026-11-25T00:00:00Z",
      weekEnd: "2026-12-01T00:00:00Z",
      lessons: <ScheduleLesson>[
        _lesson(id: 1, date: "2026-11-25T08:00:00Z", pair: 1),
      ],
      cancellations: const <ScheduleCancellation>[
        ScheduleCancellation(
          startDate: "2026-11-25T00:00:00Z",
          endDate: "2026-11-26T00:00:00Z",
          pairs: <int>[1],
          reason: "Holiday",
          scope: "All",
        ),
      ],
      filters: emptyFilters,
    );

    final List<DaySchedule> days = groupScheduleByDay(week);
    expect(days, hasLength(2));
    expect(days[0].weekdayIndex, 2);
    expect(days[0].lessons, hasLength(1));
    expect(days[0].cancellations, hasLength(1));
    expect(days[1].weekdayIndex, 3);
    expect(days[1].lessons, isEmpty);
    expect(days[1].cancellations, hasLength(1));
  });

  test("returns empty list on malformed weekStart without throwing", () {
    const ScheduleWeek week = ScheduleWeek(
      weekStart: "not-a-date",
      weekEnd: "not-a-date",
      lessons: <ScheduleLesson>[],
      cancellations: <ScheduleCancellation>[],
      filters: emptyFilters,
    );

    expect(groupScheduleByDay(week), isEmpty);
  });

  test("ScheduleWeek.fromJson validates weekStart and handles null lists", () {
    expect(
      () => ScheduleWeek.fromJson(<String, dynamic>{
        "weekStart": "invalid",
        "weekEnd": "2026-11-29",
        "filters": <String, dynamic>{},
      }),
      throwsFormatException,
    );

    final ScheduleWeek parsed = ScheduleWeek.fromJson(<String, dynamic>{
      "weekStart": "2026-11-23T00:00:00Z",
      "weekEnd": "2026-11-29T00:00:00Z",
      "lessons": null,
      "cancellations": null,
      "filters": <String, dynamic>{
        "groups": null,
        "teachers": null,
        "courses": null,
      },
    });
    expect(parsed.weekStart, "2026-11-23");
    expect(parsed.weekEnd, "2026-11-29");
    expect(parsed.lessons, isEmpty);
    expect(parsed.cancellations, isEmpty);
  });
}
