import "package:material_ui/material_ui.dart";

import "../../i18n/app_localizations.dart";
import "../../models/schedule_models.dart";

class CancellationBanner extends StatelessWidget {
  final ScheduleCancellation cancellation;

  const CancellationBanner({super.key, required this.cancellation});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final background = colorScheme.tertiaryContainer;
    final foreground = colorScheme.onTertiaryContainer;

    final text = cancellation.pairs.isEmpty
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
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: foreground),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
