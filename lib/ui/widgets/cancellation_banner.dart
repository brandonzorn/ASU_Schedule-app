import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:material_ui/material_ui.dart";

class CancellationBanner extends StatelessWidget {
  final ScheduleCancellation cancellation;

  const CancellationBanner({required this.cancellation, super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Color background = colorScheme.tertiaryContainer;
    final Color foreground = colorScheme.onTertiaryContainer;

    final String text = cancellation.pairs.isEmpty
        ? "${i18n.lessonsCanceled} (${cancellation.scope}): ${cancellation.reason}"
        : "${i18n.canceledPairs} ${cancellation.pairs.join(", ")} "
              "(${cancellation.scope}): ${cancellation.reason}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: <Widget>[
          Icon(Icons.warning_amber_rounded, color: foreground),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
