import "package:flutter/material.dart";

import "../../models/schedule_models.dart";

class CancellationBanner extends StatelessWidget {
  final ScheduleCancellation cancellation;

  const CancellationBanner({super.key, required this.cancellation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? Colors.amber.shade900.withValues(alpha: 0.35)
        : Colors.amber.shade100;
    final foreground = isDark ? Colors.amber.shade100 : Colors.black;

    final text = cancellation.pairs.isEmpty
        ? "Занятия отменены (${cancellation.scope}): ${cancellation.reason}"
        : "Отменены пары ${cancellation.pairs.join(", ")} "
              "(${cancellation.scope}): ${cancellation.reason}";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w500, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
