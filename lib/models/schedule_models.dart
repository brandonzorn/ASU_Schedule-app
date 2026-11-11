import "package:asu_schedule/models/enums.dart";

class ScheduleTeacher {
  final int id;
  final String shortName;

  const ScheduleTeacher({required this.id, required this.shortName});

  factory ScheduleTeacher.fromJson(Map<String, dynamic> json) =>
      ScheduleTeacher(
        id: json["id"] as int,
        shortName: json["shortName"] as String,
      );
}

class ScheduleLesson {
  final int id;
  final String date;
  final int pair;
  final LessonKind kind;
  final int disciplineId;
  final String discipline;
  final String? room;
  final int? subgroup;
  final int? groupId;
  final String? groupName;
  final int? course;
  final String? associationName;
  final List<int> associationGroupIds;
  final List<ScheduleTeacher> teachers;
  final String? cancellationReason;

  const ScheduleLesson({
    required this.id,
    required this.date,
    required this.pair,
    required this.kind,
    required this.disciplineId,
    required this.discipline,
    required this.associationGroupIds, required this.teachers, this.room,
    this.subgroup,
    this.groupId,
    this.groupName,
    this.course,
    this.associationName,
    this.cancellationReason,
  });

  bool get isCancelled => cancellationReason != null;

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
        (json["associationGroupIds"] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        <int>[],
    teachers:
        (json["teachers"] as List<dynamic>?)
            ?.map((e) => ScheduleTeacher.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <ScheduleTeacher>[],
    cancellationReason: json["cancellationReason"] as String?,
  );
}

class ScheduleCancellation {
  final String startDate;
  final String endDate;
  final List<int> pairs;
  final String reason;
  final String scope;
  final int? groupId;
  final int? course;

  const ScheduleCancellation({
    required this.startDate,
    required this.endDate,
    required this.pairs,
    required this.reason,
    required this.scope,
    this.groupId,
    this.course,
  });

  factory ScheduleCancellation.fromJson(Map<String, dynamic> json) =>
      ScheduleCancellation(
        startDate: json["startDate"] as String,
        endDate: json["endDate"] as String,
        pairs: (json["pairs"] as List<dynamic>).map((e) => e as int).toList(),
        reason: json["reason"] as String,
        scope: json["scope"] as String,
        groupId: json["groupId"] as int?,
        course: json["course"] as int?,
      );
}

class GroupItem {
  final int id;
  final String name;
  final String? description;
  final int course;

  const GroupItem({
    required this.id,
    required this.name,
    required this.course, this.description,
  });

  factory GroupItem.fromJson(Map<String, dynamic> json) => GroupItem(
    id: json["id"] as int,
    name: json["name"] as String,
    description: json["description"] as String?,
    course: json["course"] as int,
  );
}

class TeacherItem {
  final int id;
  final String fullName;
  final String? shortName;

  const TeacherItem({required this.id, required this.fullName, this.shortName});

  factory TeacherItem.fromJson(Map<String, dynamic> json) => TeacherItem(
    id: json["id"] as int,
    fullName: json["fullName"] as String,
    shortName: json["shortName"] as String?,
  );
}

class ScheduleFilters {
  final List<GroupItem> groups;
  final List<TeacherItem> teachers;
  final List<int> courses;

  const ScheduleFilters({
    required this.groups,
    required this.teachers,
    required this.courses,
  });

  factory ScheduleFilters.fromJson(Map<String, dynamic> json) =>
      ScheduleFilters(
        groups: (json["groups"] as List<dynamic>)
            .map((e) => GroupItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        teachers: (json["teachers"] as List<dynamic>)
            .map((e) => TeacherItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        courses: (json["courses"] as List<dynamic>)
            .map((e) => e as int)
            .toList(),
      );
}

class ScheduleWeek {
  final String weekStart;
  final String weekEnd;
  final List<ScheduleLesson> lessons;
  final List<ScheduleCancellation> cancellations;
  final ScheduleFilters filters;
  final String? nextLessonDate;

  const ScheduleWeek({
    required this.weekStart,
    required this.weekEnd,
    required this.lessons,
    required this.cancellations,
    required this.filters,
    this.nextLessonDate,
  });

  factory ScheduleWeek.fromJson(Map<String, dynamic> json) => ScheduleWeek(
    weekStart: json["weekStart"] as String,
    weekEnd: json["weekEnd"] as String,
    lessons: (json["lessons"] as List<dynamic>)
        .map((e) => ScheduleLesson.fromJson(e as Map<String, dynamic>))
        .toList(),
    cancellations: (json["cancellations"] as List<dynamic>)
        .map((e) => ScheduleCancellation.fromJson(e as Map<String, dynamic>))
        .toList(),
    filters: ScheduleFilters.fromJson(json["filters"] as Map<String, dynamic>),
    nextLessonDate: json["nextLessonDate"] as String?,
  );
}
