import "package:asu_schedule/models/reference_models.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/services/storage_service.dart";
import "package:dio/dio.dart";

class SchedionApiService {
  final StorageService _storage;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://schedion.ru/api/public/v1",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: <String, dynamic>{"Accept": "application/json"},
    ),
  );

  SchedionApiService(this._storage);

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
      await Future<Duration>.delayed(
        Duration(seconds: retryAfter.clamp(1, 10)),
      );
      return await request();
    }
  }

  bool _canUseCache(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      default:
        final int? status = e.response?.statusCode;
        return status != null && (status == 429 || status >= 500);
    }
  }

  String _errorMessage(DioException e) {
    final dynamic data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final String title = data["title"]?.toString() ?? "errorRequest";
      final String detail = data["detail"]?.toString() ?? "";
      return detail.isEmpty ? title : "$title. $detail";
    }
    final int? status = e.response?.statusCode;
    if (status != null) {
      return "errorServer:$status";
    }
    return "errorConnection";
  }

  Future<T?> _readCache<T>(
    String cacheKey,
    T Function(Map<String, dynamic> json) parser,
  ) async {
    try {
      final Map<String, dynamic>? cached = await _storage.getJsonCache(cacheKey);
      return cached == null ? null : parser(cached);
    } catch (_) {
      return null;
    }
  }

  Future<T> _fetchWithCache<T>({
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
      } catch (_) {}
      return result;
    } on DioException catch (e) {
      if (_canUseCache(e)) {
        final T? cached = await _readCache(cacheKey, parser);
        if (cached != null) {
          return cached;
        }
      }
      throw Exception(_errorMessage(e));
    } catch (_) {
      throw Exception("errorInvalidData");
    }
  }

  Future<Map<int, PairItem>> getPairs() {
    return _fetchWithCache<Map<int, PairItem>>(
      request: () => _dio.get("/pairs"),
      cacheKey: "cache_pairs",
      parser: (Map<String, dynamic> json) {
        final Iterable<PairItem> items = (json["items"] as List<dynamic>).map(
          (e) => PairItem.fromJson(e as Map<String, dynamic>),
        );
        return <int, PairItem>{for (final PairItem item in items) item.number: item};
      },
    );
  }

  Future<WeekList> getWeeks() {
    return _fetchWithCache<WeekList>(
      request: () => _dio.get("/weeks"),
      cacheKey: "cache_weeks",
      parser: WeekList.fromJson,
    );
  }

  Future<ScheduleWeek> getSchedule({
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
