import "dart:async";

import "package:flutter/material.dart";

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
    if (oldWidget.selectedWeekStart != widget.selectedWeekStart) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _selectedKey.currentContext;
      if (!mounted || context == null) return;
      unawaited(
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            for (final week in widget.weeks)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  showCheckmark: false,
                  key: week.start == widget.selectedWeekStart
                      ? _selectedKey
                      : null,
                  label: Text("${week.number} нед. (${week.shortRange})"),
                  selected: week.start == widget.selectedWeekStart,
                  avatar: CircleAvatar(
                    backgroundColor: week.color == WeekColor.red
                        ? Colors.red
                        : Theme.of(context).colorScheme.onSurface,
                    radius: 8,
                  ),
                  onSelected: (_) => widget.onWeekSelected(week.start),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
