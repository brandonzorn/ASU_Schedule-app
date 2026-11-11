enum LessonKind {
  none("Не указан"),
  lecture("Лекция"),
  seminar("Семинар"),
  laboratory("Лабораторная"),
  practical("Практика"),
  selfStudy("Сам. работа");

  final String label;
  const LessonKind(this.label);

  static LessonKind fromString(String? value) {
    return LessonKind.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LessonKind.none,
    );
  }
}

enum WeekColor {
  black("Чёрная неделя"),
  red("Красная неделя");

  final String label;
  const WeekColor(this.label);

  static WeekColor fromString(String? value) {
    return value == "red" ? WeekColor.red : WeekColor.black;
  }
}
