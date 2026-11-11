import "enums.dart";

class PairItem {
  final int number;
  final String start;
  final String end;

  const PairItem({
    required this.number,
    required this.start,
    required this.end,
  });

  String get formattedTime =>
      "${start.substring(0, 5)} – ${end.substring(0, 5)}";

  factory PairItem.fromJson(Map<String, dynamic> json) => PairItem(
    number: json["number"] as int,
    start: json["start"] as String,
    end: json["end"] as String,
  );
}

class WeekItem {
  final String start;
  final String end;
  final int number;
  final WeekColor color;

  const WeekItem({
    required this.start,
    required this.end,
    required this.number,
    required this.color,
  });

  String get shortRange => "${start.substring(8, 10)}.${start.substring(5, 7)}";

  factory WeekItem.fromJson(Map<String, dynamic> json) => WeekItem(
    start: json["start"] as String,
    end: json["end"] as String,
    number: json["number"] as int,
    color: WeekColor.fromString(json["color"] as String?),
  );
}

class WeekList {
  final String semesterTitle;
  final String currentWeekStart;
  final String defaultWeekStart;
  final List<WeekItem> items;

  const WeekList({
    required this.semesterTitle,
    required this.currentWeekStart,
    required this.defaultWeekStart,
    required this.items,
  });

  factory WeekList.fromJson(Map<String, dynamic> json) => WeekList(
    semesterTitle: (json["semester"]?["title"] as String?) ?? "",
    currentWeekStart: json["currentWeekStart"] as String,
    defaultWeekStart: json["defaultWeekStart"] as String,
    items: (json["items"] as List<dynamic>)
        .map((e) => WeekItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
