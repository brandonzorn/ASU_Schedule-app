// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ASU Schedule';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get today => 'Today';

  @override
  String get themeTooltip => 'Theme mode';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get lessonCanceled => 'Class canceled';

  @override
  String get lessonsCanceled => 'Classes canceled';

  @override
  String get canceledPairs => 'Canceled classes';

  @override
  String canceledReason(String? reason) {
    return 'Canceled: $reason';
  }

  @override
  String get noLessonsThisWeek => 'No classes this week';

  @override
  String nextLessonDate(String date) {
    return 'Next class: $date';
  }

  @override
  String get retry => 'Retry';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get filtersTitle => 'Schedule Filters';

  @override
  String get courseLabel => 'Year';

  @override
  String get allCourses => 'All years';

  @override
  String courseNumber(int course) {
    return 'Year $course';
  }

  @override
  String get groupLabel => 'Group';

  @override
  String get allGroups => 'All groups';

  @override
  String get teacherLabel => 'Teacher';

  @override
  String get allTeachers => 'All teachers';

  @override
  String pairNumber(int number) {
    return 'Class #$number';
  }

  @override
  String weekShort(int number, String range) {
    return 'Wk $number ($range)';
  }

  @override
  String weekHeader(int number, String color) {
    return 'Week $number • $color';
  }

  @override
  String roomNumber(String? room) {
    return 'Rm. $room';
  }

  @override
  String subgroupNumber(int? subgroup) {
    return 'Subgrp. $subgroup';
  }

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get kindNone => 'Not specified';

  @override
  String get kindLecture => 'Lecture';

  @override
  String get kindSeminar => 'Seminar';

  @override
  String get kindLaboratory => 'Lab work';

  @override
  String get kindPractical => 'Practice';

  @override
  String get kindSelfStudy => 'Self-study';

  @override
  String get colorBlack => 'Black week';

  @override
  String get colorRed => 'Red week';

  @override
  String get errorRequest => 'Request error';

  @override
  String errorServer(Object status) {
    return 'Server error ($status)';
  }

  @override
  String get errorConnection => 'Connection error';

  @override
  String get errorInvalidData => 'Server returned invalid data';
}
