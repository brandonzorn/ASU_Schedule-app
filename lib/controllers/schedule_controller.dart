import "dart:async";

import "package:flutter/foundation.dart";

import "../models/reference_models.dart";
import "../models/schedule_models.dart";
import "../services/schedion_api_service.dart";
import "../services/storage_service.dart";

class ScheduleController extends ChangeNotifier {
  final SchedionApiService _api;
  final StorageService _storage;

  ScheduleController({required this._api, required this._storage});

  Map<int, PairItem> pairs = {};
  WeekList? weekList;
  ScheduleWeek? schedule;

  String? selectedWeek;
  int? selectedCourse;
  int? selectedGroupId;
  int? selectedTeacherId;

  bool isLoading = true;
  String? errorMessage;

  int _requestId = 0;
  bool _disposed = false;

  WeekItem? get currentWeekItem =>
      weekList?.items.where((w) => w.start == selectedWeek).firstOrNull;

  String _messageOf(Object e) => e.toString().replaceFirst("Exception: ", "");

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final saved = await _storage.loadSavedFilters();
      selectedCourse = saved.course;
      selectedGroupId = saved.groupId;
      selectedTeacherId = saved.teacherId;

      final (pairsData, weekListData) = await (
        _api.getPairs(),
        _api.getWeeks(),
      ).wait;
      pairs = pairsData;
      weekList = weekListData;

      selectedWeek ??= weekList!.defaultWeekStart;

      await loadSchedule();
    } catch (e) {
      errorMessage = _messageOf(e);
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchedule({bool showLoading = true}) async {
    final requestId = ++_requestId;

    if (showLoading) isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.getSchedule(
        week: selectedWeek,
        course: selectedCourse,
        groupId: selectedGroupId,
        teacherId: selectedTeacherId,
      );
      if (requestId != _requestId) return;

      schedule = result;
      selectedWeek = result.weekStart;
    } catch (e) {
      if (requestId != _requestId) return;

      errorMessage = _messageOf(e);
      if (showLoading) schedule = null;
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void selectWeek(String weekStart) {
    if (selectedWeek == weekStart) return;
    selectedWeek = weekStart;
    unawaited(loadSchedule());
  }

  Future<void> applyFilters({int? course, int? groupId, int? teacherId}) async {
    if (selectedCourse == course &&
        selectedGroupId == groupId &&
        selectedTeacherId == teacherId) {
      return;
    }
    selectedCourse = course;
    selectedGroupId = groupId;
    selectedTeacherId = teacherId;
    try {
      await _storage.saveFilters(
        course: course,
        groupId: groupId,
        teacherId: teacherId,
      );
    } catch (_) {
      // Не удалось сохранить фильтры - расписание всё равно загружаем.
    }
    await loadSchedule();
  }
}
