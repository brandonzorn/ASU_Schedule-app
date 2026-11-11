import "dart:async";

import "package:flutter/material.dart";

import "../../controllers/schedule_controller.dart";
import "../../models/enums.dart";
import "../../utils/date_format.dart";
import "../widgets/day_schedule_card.dart";
import "../widgets/filter_bottom_sheet.dart";
import "../widgets/week_selector_bar.dart";

class ScheduleScreen extends StatelessWidget {
  final ScheduleController controller;

  const ScheduleScreen({super.key, required this.controller});

  static const _weekdays = [
    "Понедельник",
    "Вторник",
    "Среда",
    "Четверг",
    "Пятница",
    "Суббота",
    "Воскресенье",
  ];

  static String _isoDate(DateTime d) {
    final month = d.month.toString().padLeft(2, "0");
    final day = d.day.toString().padLeft(2, "0");
    return "${d.year.toString().padLeft(4, "0")}-$month-$day";
  }

  void _showFilters(BuildContext context) {
    final filters = controller.schedule?.filters;
    if (filters == null) return;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => FilterBottomSheet(
          filters: filters,
          initialCourse: controller.selectedCourse,
          initialGroupId: controller.selectedGroupId,
          initialTeacherId: controller.selectedTeacherId,
          onApply: controller.applyFilters,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final currentWeek = controller.currentWeekItem;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Расписание"),
                if (currentWeek != null)
                  Text(
                    "${currentWeek.number} неделя • ${currentWeek.color.label}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: currentWeek.color == WeekColor.red
                          ? Colors.red[700]
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: "Фильтры",
                onPressed: controller.schedule != null
                    ? () => _showFilters(context)
                    : null,
              ),
            ],
          ),
          body: Column(
            children: [
              if (controller.weekList != null)
                WeekSelectorBar(
                  weeks: controller.weekList!.items,
                  selectedWeekStart: controller.selectedWeek,
                  onWeekSelected: controller.selectWeek,
                ),
              Expanded(child: _buildContent(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final schedule = controller.schedule;

    if (schedule == null) {
      if (controller.errorMessage == null) return const SizedBox.shrink();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: controller.initialize,
                child: const Text("Повторить"),
              ),
            ],
          ),
        ),
      );
    }

    final start = DateTime.parse(schedule.weekStart);
    final cards = <Widget>[];

    for (var i = 0; i < 7; i++) {
      final dateStr = _isoDate(
        DateTime(start.year, start.month, start.day + i),
      );

      final dayLessons =
          schedule.lessons.where((l) => l.date == dateStr).toList()
            ..sort((a, b) => a.pair.compareTo(b.pair));

      final dayCancellations = schedule.cancellations.where((c) {
        return dateStr.compareTo(c.startDate) >= 0 &&
            dateStr.compareTo(c.endDate) <= 0;
      }).toList();

      if (dayLessons.isEmpty && dayCancellations.isEmpty) continue;

      cards.add(
        DayScheduleCard(
          weekdayName: _weekdays[i],
          dateStr: dateStr,
          lessons: dayLessons,
          cancellations: dayCancellations,
          pairs: controller.pairs,
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final nextDate = schedule.nextLessonDate;

    return RefreshIndicator(
      onRefresh: () => controller.loadSchedule(showLoading: false),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.errorMessage!,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          if (cards.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 64),
              child: Column(
                children: [
                  const Text(
                    "На этой неделе занятий нет",
                    textAlign: TextAlign.center,
                  ),
                  if (nextDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Ближайшее занятие: ${formatIsoDate(nextDate)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            )
          else
            ...cards,
        ],
      ),
    );
  }
}
