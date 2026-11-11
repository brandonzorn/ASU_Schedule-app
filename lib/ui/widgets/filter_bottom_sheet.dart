import "package:material_ui/material_ui.dart";

import "../../i18n/app_localizations.dart";
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

  bool get _hasActiveFilters =>
      _course != null || _groupId != null || _teacherId != null;

  void _resetFilters() {
    setState(() {
      _course = null;
      _groupId = null;
      _teacherId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final availableGroups = widget.filters.groups
        .where((g) => _course == null || g.course == _course)
        .toList();

    final validCourse = widget.filters.courses.contains(_course)
        ? _course
        : null;
    final validGroupId = availableGroups.any((g) => g.id == _groupId)
        ? _groupId
        : null;
    final validTeacherId =
        widget.filters.teachers.any((t) => t.id == _teacherId)
        ? _teacherId
        : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(i18n.filtersTitle, style: textTheme.titleLarge),
                if (_hasActiveFilters)
                  TextButton(onPressed: _resetFilters, child: Text(i18n.reset)),
              ],
            ),

            DropdownMenu<int?>(
              key: ValueKey("course_$validCourse"),
              expandedInsets: EdgeInsets.zero,
              initialSelection: validCourse,
              label: Text(i18n.courseLabel),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: null, label: i18n.allCourses),
                for (final c in widget.filters.courses)
                  DropdownMenuEntry(value: c, label: i18n.courseNumber(c)),
              ],
              onSelected: (val) => setState(() {
                _course = val;
                _groupId = null;
              }),
            ),

            DropdownMenu<int?>(
              key: ValueKey("group_${validCourse}_$validGroupId"),
              expandedInsets: EdgeInsets.zero,
              menuHeight: 300,
              enableFilter: true,
              requestFocusOnTap: true,
              initialSelection: validGroupId,
              label: Text(i18n.groupLabel),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: null, label: i18n.allGroups),
                for (final g in availableGroups)
                  DropdownMenuEntry(value: g.id, label: g.name),
              ],
              onSelected: (val) => setState(() => _groupId = val),
            ),

            DropdownMenu<int?>(
              key: ValueKey("teacher_$validTeacherId"),
              expandedInsets: EdgeInsets.zero,
              menuHeight: 300,
              enableFilter: true,
              requestFocusOnTap: true,
              initialSelection: validTeacherId,
              label: Text(i18n.teacherLabel),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: null, label: i18n.allTeachers),
                for (final t in widget.filters.teachers)
                  DropdownMenuEntry(
                    value: t.id,
                    label: t.shortName ?? t.fullName,
                  ),
              ],
              onSelected: (val) => setState(() => _teacherId = val),
            ),

            const SizedBox(height: 4),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onApply(
                  course: validCourse,
                  groupId: validGroupId,
                  teacherId: validTeacherId,
                );
              },
              child: Text(i18n.apply),
            ),
          ],
        ),
      ),
    );
  }
}
