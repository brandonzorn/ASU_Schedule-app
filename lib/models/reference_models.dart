import "package:asu_schedule/models/enums.dart";

String _hoursMinutes(String time) =>
    time.length >= 5 ? time.substring(0, 5) : time;

String _dayMonth(String isoDate) => isoDate.length >= 10
    ? "${isoDate.substring(8, 10)}.${isoDate.substring(5, 7)}"
    : isoDate;

class const PairItem({
  required final int number,
  required final String start,
  required final String end,
}) {
  String get formattedTime => "${_hoursMinutes(start)} - ${_hoursMinutes(end)}";

  factory PairItem.fromJson(Map<String, dynamic> json) => PairItem(
    number: json["number"] as int,
    start: json["start"] as String,
    end: json["end"] as String,
  );
}

class const WeekItem({
  required final String start,
  required final String end,
  required final int number,
  required final WeekColor color,
}) {
  String get shortRange => "${_dayMonth(start)}\u2013${_dayMonth(end)}";

  factory WeekItem.fromJson(Map<String, dynamic> json) => WeekItem(
    start: json["start"] as String,
    end: json["end"] as String,
    number: json["number"] as int,
    color: WeekColor.fromString(json["color"] as String?),
  );
}

class const WeekList({
  required final String semesterTitle,
  required final String currentWeekStart,
  required final String defaultWeekStart,
  required final List<WeekItem> items,
}) {
  factory WeekList.fromJson(Map<String, dynamic> json) => WeekList(
    semesterTitle: (json["semester"]?["title"] as String?) ?? "",
    currentWeekStart: json["currentWeekStart"] as String,
    defaultWeekStart: json["defaultWeekStart"] as String,
    items: (json["items"] as List<dynamic>)
        .map((e) => WeekItem.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );
}
