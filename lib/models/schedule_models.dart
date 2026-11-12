import "package:asu_schedule/models/enums.dart";

class const ScheduleTeacher({
  required final int id,
  required final String shortName,
}) {
  factory ScheduleTeacher.fromJson(Map<String, dynamic> json) =>
      ScheduleTeacher(
        id: json["id"] as int,
        shortName: json["shortName"] as String,
      );
}

class const ScheduleLesson({
  required final int id,
  required final String date,
  required final int pair,
  required final LessonKind kind,
  required final int disciplineId,
  required final String discipline,
  required final List<int> associationGroupIds,
  required final List<ScheduleTeacher> teachers,
  final String? room,
  final int? subgroup,
  final int? groupId,
  final String? groupName,
  final int? course,
  final String? associationName,
  final String? cancellationReason,
}) {
  bool get isCancelled => cancellationReason?.trim().isNotEmpty ?? false;

  factory ScheduleLesson.fromJson(Map<String, dynamic> json) => ScheduleLesson(
    id: json["id"] as int,
    date: json["date"] as String,
    pair: json["pair"] as int,
    kind: LessonKind.fromString(json["kind"] as String?),
    disciplineId: json["disciplineId"] as int,
    discipline: json["discipline"] as String,
    room: json["room"] as String?,
    subgroup: json["subgroup"] as int?,
    groupId: json["groupId"] as int?,
    groupName: json["groupName"] as String?,
    course: json["course"] as int?,
    associationName: json["associationName"] as String?,
    associationGroupIds:
        (json["associationGroupIds"] as List<dynamic>?)?.cast<int>().toList(
          growable: false,
        ) ??
        const <int>[],
    teachers:
        (json["teachers"] as List<dynamic>?)
            ?.map((e) => ScheduleTeacher.fromJson(e as Map<String, dynamic>))
            .toList(growable: false) ??
        const <ScheduleTeacher>[],
    cancellationReason: json["cancellationReason"] as String?,
  );
}

class const ScheduleCancellation({
  required final String startDate,
  required final String endDate,
  required final List<int> pairs,
  required final String reason,
  required final String scope,
  final int? groupId,
  final int? course,
}) {
  factory ScheduleCancellation.fromJson(Map<String, dynamic> json) =>
      ScheduleCancellation(
        startDate: json["startDate"] as String,
        endDate: json["endDate"] as String,
        pairs: (json["pairs"] as List<dynamic>).cast<int>().toList(
          growable: false,
        ),
        reason: json["reason"] as String,
        scope: json["scope"] as String,
        groupId: json["groupId"] as int?,
        course: json["course"] as int?,
      );
}

class const GroupItem({
  required final int id,
  required final String name,
  required final int course,
  final String? description,
}) {
  factory GroupItem.fromJson(Map<String, dynamic> json) => GroupItem(
    id: json["id"] as int,
    name: json["name"] as String,
    description: json["description"] as String?,
    course: json["course"] as int,
  );
}

class const TeacherItem({
  required final int id,
  required final String fullName,
  final String? shortName,
}) {
  factory TeacherItem.fromJson(Map<String, dynamic> json) => TeacherItem(
    id: json["id"] as int,
    fullName: json["fullName"] as String,
    shortName: json["shortName"] as String?,
  );
}

class const ScheduleFilters({
  required final List<GroupItem> groups,
  required final List<TeacherItem> teachers,
  required final List<int> courses,
}) {
  factory ScheduleFilters.fromJson(Map<String, dynamic> json) =>
      ScheduleFilters(
        groups: (json["groups"] as List<dynamic>)
            .map((e) => GroupItem.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        teachers: (json["teachers"] as List<dynamic>)
            .map((e) => TeacherItem.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        courses: (json["courses"] as List<dynamic>).cast<int>().toList(
          growable: false,
        ),
      );
}

class const ScheduleWeek({
  required final String weekStart,
  required final String weekEnd,
  required final List<ScheduleLesson> lessons,
  required final List<ScheduleCancellation> cancellations,
  required final ScheduleFilters filters,
  final String? nextLessonDate,
}) {
  factory ScheduleWeek.fromJson(Map<String, dynamic> json) => ScheduleWeek(
    weekStart: json["weekStart"] as String,
    weekEnd: json["weekEnd"] as String,
    lessons: (json["lessons"] as List<dynamic>)
        .map((e) => ScheduleLesson.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    cancellations: (json["cancellations"] as List<dynamic>)
        .map((e) => ScheduleCancellation.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    filters: ScheduleFilters.fromJson(json["filters"] as Map<String, dynamic>),
    nextLessonDate: json["nextLessonDate"] as String?,
  );
}
