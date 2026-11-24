import "dart:convert";
import "dart:developer";

import "package:asu_schedule/models/reference_models.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/utils/date_format.dart";
import "package:asu_schedule/utils/schedule_day_grouping.dart";
import "package:flutter/foundation.dart";
import "package:home_widget/home_widget.dart";

/// Передаёт расписание текущей недели в виджет «Сегодня» на домашнем экране
/// Android. Выбор нужного дня делает сам виджет (Kotlin), поэтому в полночь он
/// обновляется без запуска приложения.
class TodayWidgetService {
  static const String _logName = "TodayWidgetService";
  static const String _dataKey = "today_widget_data";
  static const String _androidProvider =
      "com.bzorn.asu_schedule.TodayWidgetProvider";

  bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> publish(ScheduleWeek schedule, Map<int, PairItem> pairs) async {
    if (!_isSupported) {
      return;
    }

    // Не затираем данные текущей недели, если пользователь листает другую.
    final String today = toIsoDate(DateTime.now());
    if (today.compareTo(schedule.weekStart) < 0 ||
        today.compareTo(schedule.weekEnd) > 0) {
      return;
    }

    try {
      final Map<String, Object?> payload = <String, Object?>{
        "savedAt": DateTime.now().toUtc().toIso8601String(),
        "weekStart": schedule.weekStart,
        "weekEnd": schedule.weekEnd,
        "days": <String, Object?>{
          for (final DaySchedule day in groupScheduleByDay(schedule))
            day.dateStr: <String, Object?>{
              "notes": <Object?>[
                for (final ScheduleCancellation c in day.cancellations)
                  <String, Object?>{"pairs": c.pairs, "reason": c.reason},
              ],
              "lessons": <Object?>[
                for (final ScheduleLesson l in day.lessons)
                  <String, Object?>{
                    "pair": l.pair,
                    "time": pairs[l.pair]?.formattedTime ?? "",
                    "discipline": l.discipline,
                    "kind": l.kind.name,
                    "room": l.room,
                    "subgroup": l.subgroup,
                    "teachers": l.teachers
                        .map((ScheduleTeacher t) => t.shortName)
                        .join(", "),
                    "cancelled": l.isCancelled,
                  },
              ],
            },
        },
      };

      await HomeWidget.saveWidgetData<String>(_dataKey, jsonEncode(payload));
      await HomeWidget.updateWidget(qualifiedAndroidName: _androidProvider);
    } on Object catch (e, st) {
      log("Failed to update widget", name: _logName, error: e, stackTrace: st);
    }
  }
}
