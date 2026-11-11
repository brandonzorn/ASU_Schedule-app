import "dart:async";

import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/models/enums.dart";
import "package:asu_schedule/models/reference_models.dart";
import "package:material_ui/material_ui.dart";

class WeekSelectorBar extends StatefulWidget {
  final List<WeekItem> weeks;
  final String? selectedWeekStart;
  final ValueChanged<String> onWeekSelected;

  const WeekSelectorBar({
    required this.weeks, required this.selectedWeekStart, required this.onWeekSelected, super.key,
  });

  @override
  State<WeekSelectorBar> createState() => _WeekSelectorBarState();
}

class _WeekSelectorBarState extends State<WeekSelectorBar> {
  final GlobalKey<State<StatefulWidget>> _selectedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollToSelected(animate: false);
  }

  @override
  void didUpdateWidget(WeekSelectorBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWeekStart != widget.selectedWeekStart ||
        oldWidget.weeks.length != widget.weeks.length) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? targetContext = _selectedKey.currentContext;
      if (!mounted || targetContext == null) {
        return;
      }
      unawaited(
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.5,
          duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
          curve: Curves.easeInOutCubicEmphasized,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double scaledHeight = MediaQuery.textScalerOf(context).scale(54);
    return SizedBox(
      height: scaledHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            for (final (int index, WeekItem week) in widget.weeks.indexed)
              Padding(
                padding: EdgeInsets.only(
                  right: index < widget.weeks.length - 1 ? 8 : 0,
                ),
                child: ChoiceChip(
                  showCheckmark: false,
                  key: week.start == widget.selectedWeekStart
                      ? _selectedKey
                      : null,
                  selected: week.start == widget.selectedWeekStart,
                  avatar: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: week.color == WeekColor.red
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  label: Text(i18n.weekShort(week.number, week.shortRange)),
                  onSelected: (_) => widget.onWeekSelected(week.start),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
