import "package:flutter/material.dart";

import "../../models/schedule_models.dart";

class CancellationBanner extends StatelessWidget {
  final ScheduleCancellation cancellation;

  const CancellationBanner({super.key, required this.cancellation});

  @override
  Widget build(BuildContext context) {
    final text = cancellation.pairs.isEmpty
        ? "Занятия отменены (${cancellation.scope}): ${cancellation.reason}"
        : "Отменены пары ${cancellation.pairs.join(", ")} "
              "(${cancellation.scope}): ${cancellation.reason}";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
