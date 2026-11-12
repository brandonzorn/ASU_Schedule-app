import "package:asu_schedule/i18n/app_localizations.dart";
import "package:material_ui/material_ui.dart";

extension ScheduleLocalizations on AppLocalizations {
  String weekdayName(int index) => switch (index) {
    0 => monday,
    1 => tuesday,
    2 => wednesday,
    3 => thursday,
    4 => friday,
    5 => saturday,
    6 => sunday,
    _ => "",
  };

  String themeModeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => themeSystem,
    ThemeMode.light => themeLight,
    ThemeMode.dark => themeDark,
  };

  String errorText(String code) {
    switch (code) {
      case "errorConnection":
        return errorConnection;
      case "errorInvalidData":
        return errorInvalidData;
      case "errorRequest":
        return errorRequest;
    }
    const String serverPrefix = "errorServer:";
    if (code.startsWith(serverPrefix)) {
      return errorServer(code.substring(serverPrefix.length));
    }
    return code;
  }
}
