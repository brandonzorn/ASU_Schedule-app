import "package:asu_schedule/controllers/schedule_controller.dart";
import "package:asu_schedule/models/enums.dart";
import "package:asu_schedule/models/reference_models.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/services/schedion_api_service.dart";
import "package:asu_schedule/services/storage_service.dart";
import "package:flutter_test/flutter_test.dart";

class _FakeStorage extends StorageService {
  bool throwOnLoadFilters = false;
  int? savedCourse;
  int? savedGroupId;
  int? savedTeacherId;

  @override
  Future<({int? course, int? groupId, int? teacherId})>
  loadSavedFilters() async {
    if (throwOnLoadFilters) {
      throw StateError("Corrupted storage");
    }
    return (
      course: savedCourse,
      groupId: savedGroupId,
      teacherId: savedTeacherId,
    );
  }

  @override
  Future<void> saveFilters({int? course, int? groupId, int? teacherId}) async {
    savedCourse = course;
    savedGroupId = groupId;
    savedTeacherId = teacherId;
  }
}

class _FakeApi extends SchedionApiService {
  _FakeApi(super.storage);

  Future<CachedResult<ScheduleWeek>> Function({
    String? week,
    int? groupId,
    int? course,
    int? teacherId,
  })?
  onGetSchedule;

  @override
  Future<Map<int, PairItem>> getPairs() async => <int, PairItem>{
    1: const PairItem(number: 1, start: "08:30", end: "10:00"),
  };

  @override
  Future<WeekList> getWeeks() async => const WeekList(
    semesterTitle: "Fall",
    currentWeekStart: "2026-11-23",
    defaultWeekStart: "2026-11-23",
    items: <WeekItem>[
      WeekItem(
        start: "2026-11-23",
        end: "2026-11-29",
        number: 1,
        color: WeekColor.black,
      ),
    ],
  );

  @override
  Future<CachedResult<ScheduleWeek>> getSchedule({
    String? week,
    int? groupId,
    int? course,
    int? teacherId,
  }) => onGetSchedule!(
    week: week,
    groupId: groupId,
    course: course,
    teacherId: teacherId,
  );
}

ScheduleWeek _sampleSchedule() => const ScheduleWeek(
  weekStart: "2026-11-23",
  weekEnd: "2026-11-29",
  lessons: <ScheduleLesson>[],
  cancellations: <ScheduleCancellation>[],
  filters: ScheduleFilters(
    groups: <GroupItem>[GroupItem(id: 10, name: "101", course: 1)],
    teachers: <TeacherItem>[],
    courses: <int>[1],
  ),
);

void main() {
  test("recovers when saved filters storage fails during initialize", () async {
    final _FakeStorage storage = _FakeStorage()..throwOnLoadFilters = true;
    final _FakeApi api = _FakeApi(storage)
      ..onGetSchedule =
          ({String? week, int? groupId, int? course, int? teacherId}) async => (
            data: _sampleSchedule(),
            fromCache: true,
            savedAt: DateTime.utc(2026, 11, 25, 10, 30),
          );

    final ScheduleController controller = ScheduleController(
      api: api,
      storage: storage,
    );

    await controller.initialize();

    expect(controller.errorMessage, isNull);
    expect(controller.schedule, isNotNull);
    expect(controller.isFromCache, isTrue);
    expect(controller.cacheSavedAt, DateTime.utc(2026, 11, 25, 10, 30));
  });

  test("preserves filters and allows resetFilters after error", () async {
    final _FakeStorage storage = _FakeStorage()..savedGroupId = 999;
    final _FakeApi api = _FakeApi(storage)
      ..onGetSchedule =
          ({String? week, int? groupId, int? course, int? teacherId}) async {
            if (groupId == 999) {
              throw Exception("Group not found");
            }
            return (data: _sampleSchedule(), fromCache: false, savedAt: null);
          };

    final ScheduleController controller = ScheduleController(
      api: api,
      storage: storage,
    );

    await controller.initialize();
    expect(controller.schedule, isNull);
    expect(controller.errorMessage, "Group not found");
    expect(controller.hasActiveFilters, isTrue);

    await controller.resetFilters();
    expect(controller.schedule, isNotNull);
    expect(controller.errorMessage, isNull);
    expect(controller.hasActiveFilters, isFalse);
    expect(controller.availableFilters, isNotNull);
  });
}
