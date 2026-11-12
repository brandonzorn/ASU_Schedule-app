import "package:asu_schedule/i18n/app_localizations.dart";
import "package:material_ui/material_ui.dart";

class FiltersButton extends StatelessWidget {
  final int count;
  final VoidCallback? onPressed;

  const FiltersButton({
    required this.count,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;

    return IconButton(
      tooltip: i18n.filtersTitle,
      onPressed: onPressed,
      icon: Badge.count(
        count: count,
        isLabelVisible: count > 0,
        child: const Icon(Icons.tune),
      ),
    );
  }
}
