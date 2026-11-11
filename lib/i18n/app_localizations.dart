import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Расписание АГУ'**
  String get appTitle;

  /// No description provided for @scheduleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get scheduleTitle;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @themeTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Тема оформления'**
  String get themeTooltip;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @lessonCanceled.
  ///
  /// In ru, this message translates to:
  /// **'Занятие отменено'**
  String get lessonCanceled;

  /// No description provided for @lessonsCanceled.
  ///
  /// In ru, this message translates to:
  /// **'Занятия отменены'**
  String get lessonsCanceled;

  /// No description provided for @canceledPairs.
  ///
  /// In ru, this message translates to:
  /// **'Отменены пары'**
  String get canceledPairs;

  /// Причина отмены занятия
  ///
  /// In ru, this message translates to:
  /// **'Отменено: {reason}'**
  String canceledReason(String? reason);

  /// No description provided for @noLessonsThisWeek.
  ///
  /// In ru, this message translates to:
  /// **'На этой неделе занятий нет'**
  String get noLessonsThisWeek;

  /// No description provided for @nextLessonDate.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшее занятие: {date}'**
  String nextLessonDate(String date);

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @filtersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры расписания'**
  String get filtersTitle;

  /// No description provided for @courseLabel.
  ///
  /// In ru, this message translates to:
  /// **'Курс'**
  String get courseLabel;

  /// No description provided for @allCourses.
  ///
  /// In ru, this message translates to:
  /// **'Все курсы'**
  String get allCourses;

  /// No description provided for @courseNumber.
  ///
  /// In ru, this message translates to:
  /// **'{course} курс'**
  String courseNumber(int course);

  /// No description provided for @groupLabel.
  ///
  /// In ru, this message translates to:
  /// **'Группа'**
  String get groupLabel;

  /// No description provided for @allGroups.
  ///
  /// In ru, this message translates to:
  /// **'Все группы'**
  String get allGroups;

  /// No description provided for @teacherLabel.
  ///
  /// In ru, this message translates to:
  /// **'Преподаватель'**
  String get teacherLabel;

  /// No description provided for @allTeachers.
  ///
  /// In ru, this message translates to:
  /// **'Все преподаватели'**
  String get allTeachers;

  /// No description provided for @pairNumber.
  ///
  /// In ru, this message translates to:
  /// **'{number} пара'**
  String pairNumber(int number);

  /// No description provided for @weekShort.
  ///
  /// In ru, this message translates to:
  /// **'{number} нед. ({range})'**
  String weekShort(int number, String range);

  /// Заголовок текущей недели и её типа/цвета
  ///
  /// In ru, this message translates to:
  /// **'{number} неделя • {color}'**
  String weekHeader(int number, String color);

  /// Номер аудитории
  ///
  /// In ru, this message translates to:
  /// **'Ауд. {room}'**
  String roomNumber(String? room);

  /// Номер подгруппы
  ///
  /// In ru, this message translates to:
  /// **'Подгр. {subgroup}'**
  String subgroupNumber(int? subgroup);

  /// No description provided for @monday.
  ///
  /// In ru, this message translates to:
  /// **'Понедельник'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ru, this message translates to:
  /// **'Вторник'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ru, this message translates to:
  /// **'Среда'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In ru, this message translates to:
  /// **'Четверг'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In ru, this message translates to:
  /// **'Пятница'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In ru, this message translates to:
  /// **'Суббота'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In ru, this message translates to:
  /// **'Воскресенье'**
  String get sunday;

  /// No description provided for @kindNone.
  ///
  /// In ru, this message translates to:
  /// **'Не указан'**
  String get kindNone;

  /// No description provided for @kindLecture.
  ///
  /// In ru, this message translates to:
  /// **'Лекция'**
  String get kindLecture;

  /// No description provided for @kindSeminar.
  ///
  /// In ru, this message translates to:
  /// **'Семинар'**
  String get kindSeminar;

  /// No description provided for @kindLaboratory.
  ///
  /// In ru, this message translates to:
  /// **'Лабораторная'**
  String get kindLaboratory;

  /// No description provided for @kindPractical.
  ///
  /// In ru, this message translates to:
  /// **'Практика'**
  String get kindPractical;

  /// No description provided for @kindSelfStudy.
  ///
  /// In ru, this message translates to:
  /// **'Сам. работа'**
  String get kindSelfStudy;

  /// No description provided for @colorBlack.
  ///
  /// In ru, this message translates to:
  /// **'Чёрная неделя'**
  String get colorBlack;

  /// No description provided for @colorRed.
  ///
  /// In ru, this message translates to:
  /// **'Красная неделя'**
  String get colorRed;

  /// No description provided for @errorRequest.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка запроса'**
  String get errorRequest;

  /// Сообщение об ошибке сервера
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сервера ({status})'**
  String errorServer(Object status);

  /// No description provided for @errorConnection.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка соединения с сервером'**
  String get errorConnection;

  /// No description provided for @errorInvalidData.
  ///
  /// In ru, this message translates to:
  /// **'Сервер вернул некорректные данные'**
  String get errorInvalidData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
