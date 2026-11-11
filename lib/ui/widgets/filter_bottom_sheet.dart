import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:material_ui/material_ui.dart";

class FilterBottomSheet extends StatefulWidget {
  final ScheduleFilters filters;
  final int? initialCourse;
  final int? initialGroupId;
  final int? initialTeacherId;
  final void Function({int? course, int? groupId, int? teacherId}) onApply;

  const FilterBottomSheet({
    required this.filters,
    required this.onApply,
    super.key,
    this.initialCourse,
    this.initialGroupId,
    this.initialTeacherId,
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
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final List<GroupItem> availableGroups = widget.filters.groups
        .where((GroupItem g) => _course == null || g.course == _course)
        .toList();

    final int? validCourse = widget.filters.courses.contains(_course)
        ? _course
        : null;
    final int? validGroupId =
        availableGroups.any((GroupItem g) => g.id == _groupId)
        ? _groupId
        : null;
    final int? validTeacherId =
        widget.filters.teachers.any((TeacherItem t) => t.id == _teacherId)
        ? _teacherId
        : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(i18n.filtersTitle, style: textTheme.titleLarge),
                if (_hasActiveFilters)
                  TextButton(onPressed: _resetFilters, child: Text(i18n.reset)),
              ],
            ),

            DropdownMenu<int?>(
              key: ValueKey<String>("course_$validCourse"),
              expandedInsets: EdgeInsets.zero,
              initialSelection: validCourse,
              label: Text(i18n.courseLabel),
              selectOnly: true,
              dropdownMenuEntries: <DropdownMenuEntry<int?>>[
                DropdownMenuEntry<int?>(value: null, label: i18n.allCourses),
                for (final int c in widget.filters.courses)
                  DropdownMenuEntry<int>(value: c, label: i18n.courseNumber(c)),
              ],
              onSelected: (int? val) => setState(() {
                _course = val;
                _groupId = null;
              }),
            ),

            DropdownMenu<int?>(
              key: ValueKey<String>("group_${validCourse}_$validGroupId"),
              expandedInsets: EdgeInsets.zero,
              menuHeight: 300,
              selectOnly: true,
              initialSelection: validGroupId,
              label: Text(i18n.groupLabel),
              dropdownMenuEntries: <DropdownMenuEntry<int?>>[
                DropdownMenuEntry<int?>(value: null, label: i18n.allGroups),
                for (final GroupItem g in availableGroups)
                  DropdownMenuEntry<int>(value: g.id, label: g.name),
              ],
              onSelected: (int? val) => setState(() => _groupId = val),
            ),

            DropdownMenu<int?>(
              key: ValueKey<String>("teacher_$validTeacherId"),
              expandedInsets: EdgeInsets.zero,
              menuHeight: 300,
              selectOnly: true,
              initialSelection: validTeacherId,
              label: Text(i18n.teacherLabel),
              dropdownMenuEntries: <DropdownMenuEntry<int?>>[
                DropdownMenuEntry<int?>(value: null, label: i18n.allTeachers),
                for (final TeacherItem t in widget.filters.teachers)
                  DropdownMenuEntry<int>(
                    value: t.id,
                    label: t.shortName ?? t.fullName,
                  ),
              ],
              onSelected: (int? val) => setState(() => _teacherId = val),
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
