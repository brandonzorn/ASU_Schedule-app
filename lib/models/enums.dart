import "package:asu_schedule/i18n/app_localizations.dart";

enum LessonKind {
  none("Не указан"),
  lecture("Лекция"),
  seminar("Семинар"),
  laboratory("Лабораторная"),
  practical("Практика"),
  selfStudy("Сам. работа");

  final String label;
  const LessonKind(this.label);

  String localizedName(AppLocalizations i18n) => switch (this) {
        LessonKind.none => i18n.kindNone,
        LessonKind.lecture => i18n.kindLecture,
        LessonKind.seminar => i18n.kindSeminar,
        LessonKind.laboratory => i18n.kindLaboratory,
        LessonKind.practical => i18n.kindPractical,
        LessonKind.selfStudy => i18n.kindSelfStudy,
      };

  static LessonKind fromString(String? value) {
    return LessonKind.values.firstWhere(
      (LessonKind e) => e.name == value,
      orElse: () => LessonKind.none,
    );
  }
}

enum WeekColor {
  black("Чёрная неделя"),
  red("Красная неделя");

  final String label;
  const WeekColor(this.label);

  String localizedName(AppLocalizations i18n) => switch (this) {
        WeekColor.black => i18n.colorBlack,
        WeekColor.red => i18n.colorRed,
      };

  static WeekColor fromString(String? value) {
    return value == "red" ? WeekColor.red : WeekColor.black;
  }
}
