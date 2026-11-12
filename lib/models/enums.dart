import "package:asu_schedule/i18n/app_localizations.dart";

enum LessonKind {
  none,
  lecture,
  seminar,
  laboratory,
  practical,
  selfStudy;

  String localizedName(AppLocalizations i18n) => switch (this) {
    LessonKind.none => i18n.kindNone,
    LessonKind.lecture => i18n.kindLecture,
    LessonKind.seminar => i18n.kindSeminar,
    LessonKind.laboratory => i18n.kindLaboratory,
    LessonKind.practical => i18n.kindPractical,
    LessonKind.selfStudy => i18n.kindSelfStudy,
  };

  static final Map<String, LessonKind> _byName = values.asNameMap();

  static LessonKind fromString(String? value) =>
      _byName[value] ?? LessonKind.none;
}

enum WeekColor {
  black,
  red;

  String localizedName(AppLocalizations i18n) => switch (this) {
    WeekColor.black => i18n.colorBlack,
    WeekColor.red => i18n.colorRed,
  };

  static final Map<String, WeekColor> _byName = values.asNameMap();

  static WeekColor fromString(String? value) =>
      _byName[value] ?? WeekColor.black;
}
