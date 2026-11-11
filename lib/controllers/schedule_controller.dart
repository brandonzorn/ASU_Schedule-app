import "package:flutter/foundation.dart";

import "../models/reference_models.dart";
import "../models/schedule_models.dart";
import "../services/schedion_api_service.dart";
import "../services/storage_service.dart";

class ScheduleController extends ChangeNotifier {
  final SchedionApiService _api;
  final StorageService _storage;

  ScheduleController({
    required this._api,
    required this._storage,
  });

  Map<int, PairItem> pairs = {};
  WeekList? weekList;
  ScheduleWeek? schedule;

  String? selectedWeek;
  int? selectedCourse;
  int? selectedGroupId;
  int? selectedTeacherId;

  bool isLoading = true;
  String? errorMessage;

  WeekItem? get currentWeekItem =>
      weekList?.items.where((w) => w.start == selectedWeek).firstOrNull;

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final saved = await _storage.loadSavedFilters();
      selectedCourse = saved.course;
      selectedGroupId = saved.groupId;
      selectedTeacherId = saved.teacherId;

      final results = await Future.wait([_api.getPairs(), _api.getWeeks()]);

      pairs = results[0] as Map<int, PairItem>;
      weekList = results[1] as WeekList;
      selectedWeek ??= weekList!.defaultWeekStart;

      await loadSchedule();
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchedule() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      schedule = await _api.getSchedule(
        week: selectedWeek,
        course: selectedCourse,
        groupId: selectedGroupId,
        teacherId: selectedTeacherId,
      );
      selectedWeek = schedule!.weekStart;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectWeek(String weekStart) {
    if (selectedWeek == weekStart) return;
    selectedWeek = weekStart;
    loadSchedule();
  }

  Future<void> applyFilters({int? course, int? groupId, int? teacherId}) async {
    selectedCourse = course;
    selectedGroupId = groupId;
    selectedTeacherId = teacherId;
    await _storage.saveFilters(
      course: course,
      groupId: groupId,
      teacherId: teacherId,
    );
    await loadSchedule();
  }
}
