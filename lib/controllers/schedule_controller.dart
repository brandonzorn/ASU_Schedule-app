import "dart:async";
import "dart:developer";

import "package:asu_schedule/models/reference_models.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/services/schedion_api_service.dart";
import "package:asu_schedule/services/storage_service.dart";
import "package:asu_schedule/utils/schedule_day_grouping.dart";
import "package:flutter/foundation.dart";

class ScheduleController extends ChangeNotifier {
  static const String _logName = "ScheduleController";

  final SchedionApiService _api;
  final StorageService _storage;

  ScheduleController({required this._api, required this._storage});

  Map<int, PairItem> pairs = <int, PairItem>{};
  WeekList? weekList;
  ScheduleWeek? schedule;
  ScheduleFilters? _lastFilters;
  List<DaySchedule> days = const <DaySchedule>[];

  String? selectedWeek;
  int? selectedCourse;
  int? selectedGroupId;
  int? selectedTeacherId;

  bool isLoading = true;
  bool isFromCache = false;
  DateTime? cacheSavedAt;
  String? errorMessage;

  int _requestId = 0;
  bool _disposed = false;

  ScheduleFilters? get availableFilters => schedule?.filters ?? _lastFilters;

  bool get hasActiveFilters =>
      selectedCourse != null ||
      selectedGroupId != null ||
      selectedTeacherId != null;

  WeekItem? get currentWeekItem => weekList?.items
      .where((WeekItem w) => w.start == selectedWeek)
      .firstOrNull;

  String _messageOf(Object e) {
    final Object cause = _unwrap(e);
    return cause.toString().replaceFirst("Exception: ", "");
  }

  Object _unwrap(Object e) {
    if (e is ParallelWaitError<dynamic, dynamic>) {
      final Object? errors = e.errors;
      if (errors is (AsyncError?, AsyncError?)) {
        return errors.$1?.error ?? errors.$2?.error ?? e;
      }
    }
    return e;
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> initialize() async {
    final int initId = ++_requestId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final ({int? course, int? groupId, int? teacherId}) saved = await _storage
          .loadSavedFilters();
      if (initId != _requestId) {
        return;
      }
      selectedCourse = saved.course;
      selectedGroupId = saved.groupId;
      selectedTeacherId = saved.teacherId;
    } on Object catch (e, st) {
      log(
        "Failed to load saved filters",
        name: _logName,
        error: e,
        stackTrace: st,
      );
    }

    try {
      final (Map<int, PairItem> pairsData, WeekList weekListData) = await (
        _api.getPairs(),
        _api.getWeeks(),
      ).wait;
      if (initId != _requestId) {
        return;
      }

      pairs = pairsData;
      weekList = weekListData;

      selectedWeek ??= weekList!.defaultWeekStart;

      await loadSchedule();
    } catch (e) {
      if (initId != _requestId) {
        return;
      }
      errorMessage = _messageOf(e);
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchedule({bool showLoading = true}) async {
    final int requestId = ++_requestId;

    if (showLoading) {
      isLoading = true;
    }
    errorMessage = null;
    notifyListeners();

    try {
      final CachedResult<ScheduleWeek> result = await _api.getSchedule(
        week: selectedWeek,
        course: selectedCourse,
        groupId: selectedGroupId,
        teacherId: selectedTeacherId,
      );
      if (requestId != _requestId) {
        return;
      }

      schedule = result.data;
      _lastFilters = result.data.filters;
      days = groupScheduleByDay(result.data);
      isFromCache = result.fromCache;
      cacheSavedAt = result.savedAt;
      selectedWeek = result.data.weekStart;
    } catch (e) {
      if (requestId != _requestId) {
        return;
      }

      errorMessage = _messageOf(e);
      if (showLoading) {
        schedule = null;
        days = const <DaySchedule>[];
        isFromCache = false;
        cacheSavedAt = null;
      }
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void retry() {
    if (weekList == null) {
      unawaited(initialize());
    } else {
      unawaited(loadSchedule());
    }
  }

  void selectWeek(String weekStart) {
    if (selectedWeek == weekStart && schedule != null) {
      return;
    }
    selectedWeek = weekStart;
    unawaited(loadSchedule());
  }

  Future<void> resetFilters() => applyFilters();

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
    } catch (e, st) {
      log("Failed to save filters", name: _logName, error: e, stackTrace: st);
    }
    await loadSchedule();
  }
}
