import "dart:developer";

import "package:asu_schedule/models/cached_json.dart";
import "package:asu_schedule/models/reference_models.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/services/api/api_config.dart";
import "package:asu_schedule/services/storage_service.dart";
import "package:dio/dio.dart";

typedef CachedResult<T> = ({T data, bool fromCache, DateTime? savedAt});

class SchedionApiService {
  static const String _logName = "SchedionApi";

  final Dio _dio;
  final StorageService _storage;

  SchedionApiService(this._storage, {Dio? dio})
    : _dio = dio ?? SchedionApiConfig.createDio();

  Future<Response<dynamic>> _requestWithRetry(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.response?.statusCode != 429) {
        rethrow;
      }

      final int retryAfter =
          int.tryParse(e.response?.headers.value("Retry-After") ?? "") ?? 1;
      await Future<void>.delayed(Duration(seconds: retryAfter.clamp(1, 10)));
      return await request();
    }
  }

  bool _canUseCache(DioException e) {
    final int? status = e.response?.statusCode;
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.unknown:
        return status == null || status == 429 || status >= 500;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
        return status != null && (status == 429 || status >= 500);
    }
  }

  String _errorMessage(DioException e) {
    final dynamic data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final String title = data["title"]?.toString().trim() ?? "";
      final String detail = data["detail"]?.toString().trim() ?? "";
      if (title.isNotEmpty && detail.isNotEmpty) {
        return "$title. $detail";
      }
      if (title.isNotEmpty) {
        return title;
      }
      if (detail.isNotEmpty) {
        return detail;
      }
      return "errorRequest";
    }
    final int? status = e.response?.statusCode;
    if (status != null) {
      return "errorServer:$status";
    }
    return "errorConnection";
  }

  Future<CachedResult<T>?> _readCache<T>(
    String cacheKey,
    T Function(Map<String, dynamic> json) parser,
  ) async {
    try {
      final CachedJson? cached = await _storage.getJsonCache(cacheKey);
      if (cached == null) {
        return null;
      }
      return (data: parser(cached.data), fromCache: true, savedAt: cached.savedAt);
    } catch (e, st) {
      log(
        "Failed to read cache $cacheKey",
        name: _logName,
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<CachedResult<T>> _fetchWithCache<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(Map<String, dynamic> json) parser,
    required String cacheKey,
  }) async {
    try {
      final Response<dynamic> response = await _requestWithRetry(request);
      final dynamic data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException("Unexpected response");
      }

      final T result = parser(data);
      try {
        await _storage.saveJsonCache(cacheKey, data);
      } catch (e, st) {
        log(
          "Failed to write cache $cacheKey",
          name: _logName,
          error: e,
          stackTrace: st,
        );
      }
      return (data: result, fromCache: false, savedAt: null);
    } on DioException catch (e) {
      if (_canUseCache(e)) {
        final CachedResult<T>? cached = await _readCache(cacheKey, parser);
        if (cached != null) {
          return cached;
        }
      }
      throw Exception(_errorMessage(e));
    } catch (e, st) {
      log(
        "Invalid data for $cacheKey",
        name: _logName,
        error: e,
        stackTrace: st,
      );
      throw Exception("errorInvalidData");
    }
  }

  Future<Map<int, PairItem>> getPairs() async {
    final CachedResult<Map<int, PairItem>> result =
        await _fetchWithCache<Map<int, PairItem>>(
          request: () => _dio.get("/pairs"),
          cacheKey: "cache_pairs",
          parser: (Map<String, dynamic> json) {
            final Iterable<PairItem> items = (json["items"] as List<dynamic>)
                .map((e) => PairItem.fromJson(e as Map<String, dynamic>));
            return <int, PairItem>{
              for (final PairItem item in items) item.number: item,
            };
          },
        );
    return result.data;
  }

  Future<WeekList> getWeeks() async {
    final CachedResult<WeekList> result = await _fetchWithCache<WeekList>(
      request: () => _dio.get("/weeks"),
      cacheKey: "cache_weeks",
      parser: WeekList.fromJson,
    );
    return result.data;
  }

  Future<CachedResult<ScheduleWeek>> getSchedule({
    String? week,
    int? groupId,
    int? course,
    int? teacherId,
  }) {
    final Map<String, dynamic> query = <String, dynamic>{
      "week": ?week,
      "group": ?groupId,
      "course": ?course,
      "teacher": ?teacherId,
    };

    return _fetchWithCache<ScheduleWeek>(
      request: () => _dio.get("/schedule", queryParameters: query),
      cacheKey: "cache_sched_${week ?? 'def'}_${groupId}_${course}_$teacherId",
      parser: ScheduleWeek.fromJson,
    );
  }
}
