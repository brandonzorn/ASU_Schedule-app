// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Расписание АГУ';

  @override
  String get scheduleTitle => 'Расписание';

  @override
  String get today => 'Сегодня';

  @override
  String get themeTooltip => 'Тема оформления';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get lessonCanceled => 'Занятие отменено';

  @override
  String get lessonsCanceled => 'Занятия отменены';

  @override
  String get canceledPairs => 'Отменены пары';

  @override
  String canceledReason(String? reason) {
    return 'Отменено: $reason';
  }

  @override
  String get noLessonsThisWeek => 'На этой неделе занятий нет';

  @override
  String nextLessonDate(String date) {
    return 'Ближайшее занятие: $date';
  }

  @override
  String get retry => 'Повторить';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сбросить';

  @override
  String get filtersTitle => 'Фильтры расписания';

  @override
  String get courseLabel => 'Курс';

  @override
  String get allCourses => 'Все курсы';

  @override
  String courseNumber(int course) {
    return '$course курс';
  }

  @override
  String get groupLabel => 'Группа';

  @override
  String get allGroups => 'Все группы';

  @override
  String get teacherLabel => 'Преподаватель';

  @override
  String get allTeachers => 'Все преподаватели';

  @override
  String pairNumber(int number) {
    return '$number пара';
  }

  @override
  String weekShort(int number, String range) {
    return '$number нед. ($range)';
  }

  @override
  String weekHeader(int number, String color) {
    return '$number неделя • $color';
  }

  @override
  String roomNumber(String? room) {
    return 'Ауд. $room';
  }

  @override
  String subgroupNumber(int? subgroup) {
    return 'Подгр. $subgroup';
  }

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get kindNone => 'Не указан';

  @override
  String get kindLecture => 'Лекция';

  @override
  String get kindSeminar => 'Семинар';

  @override
  String get kindLaboratory => 'Лабораторная';

  @override
  String get kindPractical => 'Практика';

  @override
  String get kindSelfStudy => 'Сам. работа';

  @override
  String get colorBlack => 'Чёрная неделя';

  @override
  String get colorRed => 'Красная неделя';

  @override
  String get errorRequest => 'Ошибка запроса';

  @override
  String errorServer(Object status) {
    return 'Ошибка сервера ($status)';
  }

  @override
  String get errorConnection => 'Ошибка соединения с сервером';

  @override
  String get errorInvalidData => 'Сервер вернул некорректные данные';
}
