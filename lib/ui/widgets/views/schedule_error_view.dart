import "package:asu_schedule/i18n/app_localizations.dart";
import "package:material_ui/material_ui.dart";

class ScheduleErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ScheduleErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(i18n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
