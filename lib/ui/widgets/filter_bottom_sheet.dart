import "package:flutter/material.dart";

import "../../models/schedule_models.dart";

class FilterBottomSheet extends StatefulWidget {
  final ScheduleFilters filters;
  final int? initialCourse;
  final int? initialGroupId;
  final int? initialTeacherId;
  final void Function({int? course, int? groupId, int? teacherId}) onApply;

  const FilterBottomSheet({
    super.key,
    required this.filters,
    this.initialCourse,
    this.initialGroupId,
    this.initialTeacherId,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late int? _course = widget.initialCourse;
  late int? _groupId = widget.initialGroupId;
  late int? _teacherId = widget.initialTeacherId;

  @override
  Widget build(BuildContext context) {
    final availableGroups = widget.filters.groups
        .where((g) => _course == null || g.course == _course)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Фильтры расписания",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: widget.filters.courses.contains(_course)
                ? _course
                : null,
            decoration: const InputDecoration(
              labelText: "Курс",
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text("Все курсы")),
              ...widget.filters.courses.map(
                (c) => DropdownMenuItem(value: c, child: Text("$c курс")),
              ),
            ],
            onChanged: (val) => setState(() {
              _course = val;
              _groupId = null;
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            key: ValueKey("group_$_course"),
            isExpanded: true,
            initialValue: availableGroups.any((g) => g.id == _groupId)
                ? _groupId
                : null,
            decoration: const InputDecoration(
              labelText: "Группа",
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text("Все группы")),
              ...availableGroups.map(
                (g) => DropdownMenuItem(value: g.id, child: Text(g.name)),
              ),
            ],
            onChanged: (val) => setState(() => _groupId = val),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: widget.filters.teachers.any((t) => t.id == _teacherId)
                ? _teacherId
                : null,
            decoration: const InputDecoration(
              labelText: "Преподаватель",
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text("Все преподаватели"),
              ),
              ...widget.filters.teachers.map(
                (t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(
                    t.shortName ?? t.fullName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _teacherId = val),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onApply(
                course: _course,
                groupId: _groupId,
                teacherId: _teacherId,
              );
            },
            child: const Text("Применить"),
          ),
        ],
      ),
    );
  }
}
