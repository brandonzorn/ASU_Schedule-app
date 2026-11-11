import "package:dio/dio.dart";
import "../models/reference_models.dart";
import "../models/schedule_models.dart";
import "storage_service.dart";

class SchedionApiService {
  final StorageService _storage;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://schedion.ru/api/public/v1",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Accept": "application/json"},
    ),
  );

  SchedionApiService(this._storage);

  Future<T> _fetchWithCache<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(Map<String, dynamic> json) parser,
    required String cacheKey,
  }) async {
    try {
      Response<dynamic> response;
      try {
        response = await request();
      } on DioException catch (e) {
        if (e.response?.statusCode == 429) {
          final retryAfter = int.tryParse(
                e.response?.headers.value("Retry-After") ?? "1",
              ) ??
              1;
          await Future.delayed(Duration(seconds: retryAfter));
          response = await request();
        } else {
          rethrow;
        }
      }

      final data = response.data as Map<String, dynamic>;
      await _storage.saveJsonCache(cacheKey, data);
      return parser(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.response?.statusCode == 503) {
        final cached = await _storage.getJsonCache(cacheKey);
        if (cached != null) return parser(cached);
      }

      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final title = data["title"] ?? "Ошибка запроса";
        final detail = data["detail"] ?? "";
        throw Exception("$title. $detail".trim());
      }
      throw Exception("Ошибка соединения с сервером");
    }
  }

  Future getPairs() {
    return _fetchWithCache(
      request: () => _dio.get("/pairs"),
      cacheKey: "cache_pairs",
      parser: (json) {
        final items = (json["items"] as List<dynamic>)
            .map((e) => PairItem.fromJson(e as Map<String, dynamic>));
        return {for (final item in items) item.number: item};
      },
    );
  }

  Future<WeekList> getWeeks() {
    return _fetchWithCache(
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
    final query = <String, dynamic>{
      "week": ?week,
      "group": ?groupId,
      "course": ?course,
      "teacher": ?teacherId,
    };

    return _fetchWithCache(
      request: () => _dio.get("/schedule", queryParameters: query),
      cacheKey: 'cache_sched_${week ?? "def"}_${groupId}_${course}_$teacherId',
      parser: ScheduleWeek.fromJson,
    );
  }
}