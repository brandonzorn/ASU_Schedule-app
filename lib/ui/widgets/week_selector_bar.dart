import "dart:async";

import "package:material_ui/material_ui.dart";

import "../../i18n/app_localizations.dart";
import "../../models/enums.dart";
import "../../models/reference_models.dart";

class WeekSelectorBar extends StatefulWidget {
  final List<WeekItem> weeks;
  final String? selectedWeekStart;
  final ValueChanged<String> onWeekSelected;

  const WeekSelectorBar({
    super.key,
    required this.weeks,
    required this.selectedWeekStart,
    required this.onWeekSelected,
  });

  @override
  State<WeekSelectorBar> createState() => _WeekSelectorBarState();
}

class _WeekSelectorBarState extends State<WeekSelectorBar> {
  final _selectedKey = GlobalKey();

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
      final targetContext = _selectedKey.currentContext;
      if (!mounted || targetContext == null) return;
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
    final i18n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 54,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            for (final (index, week) in widget.weeks.indexed)
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
