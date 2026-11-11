import "package:flutter/material.dart";

import "../../models/enums.dart";
import "../../models/reference_models.dart";

class WeekSelectorBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: weeks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final week = weeks[index];
          final isSelected = week.start == selectedWeekStart;
          final isRed = week.color == WeekColor.red;

          return ChoiceChip(
            label: Text("${week.number} нед. (${week.shortRange})"),
            selected: isSelected,
            avatar: CircleAvatar(
              backgroundColor: isRed ? Colors.red : Colors.black87,
              radius: 5,
            ),
            onSelected: (_) => onWeekSelected(week.start),
          );
        },
      ),
    );
  }
}
