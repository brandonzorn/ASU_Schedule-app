import "package:asu_schedule/models/cached_json.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/services/schedion_api_service.dart";
import "package:asu_schedule/services/storage_service.dart";
import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

class _FakeAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options)? handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler!(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test("formats error detail without leaking errorRequest key", () async {
    final StorageService storage = StorageService();
    final Dio dio = Dio();
    final _FakeAdapter adapter = _FakeAdapter();
    dio.httpClientAdapter = adapter;

    adapter.handler = (RequestOptions options) async => ResponseBody.fromString(
      '{"detail":"Group not found"}',
      404,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );

    final SchedionApiService api = SchedionApiService(storage, dio: dio);

    await expectLater(
      api.getSchedule(week: "2026-11-23", groupId: 999),
      throwsA(
        isA<Exception>().having(
          (Exception e) => e.toString(),
          "message",
          "Exception: Group not found",
        ),
      ),
    );
  });

  test("returns cached schedule with metadata on connection failure", () async {
    final StorageService storage = StorageService();
    await storage.saveJsonCache(
      "cache_sched_2026-11-23_null_null_null",
      <String, dynamic>{
        "weekStart": "2026-11-23",
        "weekEnd": "2026-11-29",
        "lessons": <dynamic>[],
        "cancellations": <dynamic>[],
        "filters": <String, dynamic>{
          "groups": <dynamic>[],
          "teachers": <dynamic>[],
          "courses": <dynamic>[],
        },
      },
    );

    final Dio dio = Dio();
    final _FakeAdapter adapter = _FakeAdapter();
    dio.httpClientAdapter = adapter;

    adapter.handler = (RequestOptions options) async => throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );

    final SchedionApiService api = SchedionApiService(storage, dio: dio);
    final CachedResult<ScheduleWeek> result = await api.getSchedule(
      week: "2026-11-23",
    );

    expect(result.fromCache, isTrue);
    expect(result.savedAt, isNotNull);
    expect(result.data.weekStart, "2026-11-23");
  });

  test("StorageService prunes old schedule cache entries past limit", () async {
    final StorageService storage = StorageService();

    for (int i = 0; i < 25; i++) {
      await storage.saveJsonCache(
        "cache_sched_2026-11-${(i + 1).toString().padLeft(2, "0")}_null_null_null",
        <String, dynamic>{"index": i},
      );
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> keys = prefs
        .getKeys()
        .where((String k) => k.startsWith("cache_sched_"))
        .toList();
    expect(keys.length, lessThanOrEqualTo(20));

    final CachedJson? newest = await storage.getJsonCache(
      "cache_sched_2026-11-25_null_null_null",
    );
    expect(newest?.data["index"], 24);
  });
}
