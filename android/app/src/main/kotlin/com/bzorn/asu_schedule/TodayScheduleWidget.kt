package com.bzorn.asu_schedule

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

@RequiresApi(Build.VERSION_CODES.O)
class TodayScheduleWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.widget_list)
        scheduleMidnightRefresh(context)
    }

    override fun onEnabled(context: Context) {
        scheduleMidnightRefresh(context)
    }

    override fun onDisabled(context: Context) {
        context.getSystemService(AlarmManager::class.java).cancel(midnightIntent(context))
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_MIDNIGHT) {
            val manager = AppWidgetManager.getInstance(context)
            val ids =
                manager.getAppWidgetIds(ComponentName(context, TodayScheduleWidget::class.java))
            onUpdate(context, manager, ids)
        } else {
            super.onReceive(context, intent)
        }
    }

    private fun midnightIntent(context: Context): PendingIntent {
        val intent = Intent(context, TodayScheduleWidget::class.java).setAction(ACTION_MIDNIGHT)
        return PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }


    private fun scheduleMidnightRefresh(context: Context) {
        val triggerAt = LocalDate.now().plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant()
            .toEpochMilli() + 5_000
        context.getSystemService(AlarmManager::class.java)
            .set(AlarmManager.RTC, triggerAt, midnightIntent(context))
    }

    private companion object {
        const val ACTION_MIDNIGHT = "com.bzorn.asu_schedule.ACTION_TODAY_WIDGET_MIDNIGHT"
    }
}

@RequiresApi(Build.VERSION_CODES.O)
internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val views = RemoteViews(context.packageName, R.layout.today_schedule_widget)
    val locale = Locale.getDefault()

    val title = LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, d MMMM", locale))
        .replaceFirstChar { it.titlecase(locale) }
    views.setTextViewText(R.id.widget_title, title)

    val state = TodayScheduleWidgetData.load(context)
    val viewTextId = when (state) {
        is TodayScheduleState.NoData -> R.string.today_schedule_widget_no_data
        else -> R.string.today_schedule_widget_empty
    }
    views.setTextViewText(
        R.id.widget_empty,
        context.getString(viewTextId),
    )

    val serviceIntent = Intent(context, TodayScheduleWidgetService::class.java).apply {
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
    }
    views.setRemoteAdapter(R.id.widget_list, serviceIntent)
    views.setEmptyView(R.id.widget_list, R.id.widget_empty)

    val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
    if (launch != null) {
        val rootIntent = PendingIntent.getActivity(
            context, 0, launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        views.setOnClickPendingIntent(R.id.widget_root, rootIntent)
        views.setOnClickPendingIntent(R.id.widget_empty, rootIntent)

        val itemTemplate = PendingIntent.getActivity(
            context, 1, launch,
            PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        views.setPendingIntentTemplate(R.id.widget_list, itemTemplate)
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}