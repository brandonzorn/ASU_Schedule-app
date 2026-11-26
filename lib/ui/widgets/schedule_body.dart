import "dart:async";

import "package:asu_schedule/controllers/schedule_controller.dart";
import "package:asu_schedule/i18n/app_localizations.dart";
import "package:asu_schedule/models/schedule_models.dart";
import "package:asu_schedule/ui/widgets/cache_banner.dart";
import "package:asu_schedule/ui/widgets/day_schedule_card.dart";
import "package:asu_schedule/ui/widgets/error_banner.dart";
import "package:asu_schedule/ui/widgets/views/empty_week_view.dart";
import "package:asu_schedule/ui/widgets/views/schedule_error_view.dart";
import "package:asu_schedule/utils/date_format.dart";
import "package:asu_schedule/utils/localization_extensions.dart";
import "package:asu_schedule/utils/schedule_day_grouping.dart";
import "package:material_ui/material_ui.dart";

class ScheduleBody extends StatelessWidget {
  static const double _maxContentWidth = 840;

  final ScheduleController controller;

  const ScheduleBody({required this.controller, super.key});

  String _cacheMessage(AppLocalizations i18n) {
    final DateTime? savedAt = controller.cacheSavedAt;
    if (savedAt == null) {
      return i18n.cachedDataNotice;
    }
    return i18n.cachedDataNoticeWithTime(formatLocalDateTime(savedAt));
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final ScheduleWeek? schedule = controller.schedule;
    final String? error = controller.errorMessage;

    if (schedule == null) {
      if (error == null) {
        return const SizedBox.shrink();
      }
      return ScheduleErrorView(
        message: i18n.errorText(error),
        onRetry: controller.retry,
        onResetFilters: controller.hasActiveFilters
            ? () => unawaited(controller.resetFilters())
            : null,
      );
    }

    final List<DaySchedule> days = controller.days;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: RefreshIndicator(
          onRefresh: () => controller.loadSchedule(showLoading: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              if (error != null) ErrorBanner(message: i18n.errorText(error)),
              if (controller.isFromCache)
                CacheBanner(message: _cacheMessage(i18n)),
              if (days.isEmpty)
                EmptyWeekView(nextLessonDate: schedule.nextLessonDate)
              else
                for (final DaySchedule day in days)
                  DayScheduleCard(
                    weekdayName: i18n.weekdayName(day.weekdayIndex),
                    dateStr: day.dateStr,
                    lessons: day.lessons,
                    cancellations: day.cancellations,
                    pairs: controller.pairs,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
