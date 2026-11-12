import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/utils/localization_extensions.dart";
import "package:material_ui/material_ui.dart";

class ThemeModeMenu extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  const ThemeModeMenu({
    required this.themeMode,
    required this.onChanged,
    super.key,
  });

  static IconData iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;

    return MenuAnchor(
      builder:
          (BuildContext context, MenuController menuController, Widget? _) =>
              IconButton(
                icon: Icon(iconFor(themeMode)),
                tooltip: i18n.themeTooltip,
                onPressed: () {
                  if (menuController.isOpen) {
                    menuController.close();
                  } else {
                    menuController.open();
                  }
                },
              ),
      menuChildren: <Widget>[
        for (final ThemeMode mode in ThemeMode.values)
          MenuItemButton(
            leadingIcon: Icon(iconFor(mode)),
            trailingIcon: mode == themeMode ? const Icon(Icons.check) : null,
            onPressed: () => onChanged(mode),
            child: Text(i18n.themeModeLabel(mode)),
          ),
      ],
    );
  }
}
