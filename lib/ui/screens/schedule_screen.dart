import "package:flutter/material.dart";

import "../../controllers/schedule_controller.dart";
import "../../models/enums.dart";
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

  void _showFilters(BuildContext context) {
    final filters = controller.schedule?.filters;
    if (filters == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterBottomSheet(
        filters: filters,
        initialCourse: controller.selectedCourse,
        initialGroupId: controller.selectedGroupId,
        initialTeacherId: controller.selectedTeacherId,
        onApply: controller.applyFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final currentWeek = controller.currentWeekItem;

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
                          : Colors.grey[800],
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

    if (controller.errorMessage != null) {
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

    final schedule = controller.schedule;
    if (schedule == null) return const SizedBox.shrink();

    final startDate = DateTime.parse(schedule.weekStart);
    final days = List.generate(7, (i) => startDate.add(Duration(days: i)));

    return RefreshIndicator(
      onRefresh: controller.loadSchedule,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final dateStr = days[index].toIso8601String().substring(0, 10);

          final dayLessons =
              schedule.lessons.where((l) => l.date == dateStr).toList()
                ..sort((a, b) => a.pair.compareTo(b.pair));

          final dayCancellations = schedule.cancellations.where((c) {
            return dateStr.compareTo(c.startDate) >= 0 &&
                dateStr.compareTo(c.endDate) <= 0;
          }).toList();

          if (dayLessons.isEmpty && dayCancellations.isEmpty) {
            return const SizedBox.shrink();
          }

          return DayScheduleCard(
            weekdayName: _weekdays[index],
            dateStr: dateStr,
            lessons: dayLessons,
            cancellations: dayCancellations,
            pairs: controller.pairs,
          );
        },
      ),
    );
  }
}
