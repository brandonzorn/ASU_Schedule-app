import "package:dio/dio.dart";

abstract final class SchedionApiConfig {
  static const String baseUrl = "https://schedion.ru/api/public/v1";
  static const Duration timeout = Duration(seconds: 10);

  static Dio createDio() => Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      sendTimeout: timeout,
      receiveTimeout: timeout,
      headers: <String, String>{"Accept": "application/json"},
    ),
  );
}
