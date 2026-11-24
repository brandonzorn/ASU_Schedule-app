package com.bzorn.asu_schedule

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

class TodayWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { render(context, appWidgetManager, it) }
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
            val ids = manager.getAppWidgetIds(ComponentName(context, TodayWidgetProvider::class.java))
            onUpdate(context, manager, ids)
        } else {
            super.onReceive(context, intent)
        }
    }

    private fun render(context: Context, manager: AppWidgetManager, widgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.widget_today)
        val locale = Locale.getDefault()

        val title = LocalDate.now()
            .format(DateTimeFormatter.ofPattern("EEEE, d MMMM", locale))
            .replaceFirstChar { it.titlecase(locale) }
        views.setTextViewText(R.id.widget_title, title)

        val state = TodayWidgetData.load(context)
        views.setTextViewText(
            R.id.widget_empty,
            context.getString(
                if (state is TodayState.NoData) R.string.widget_no_data else R.string.widget_empty,
            ),
        )

        val serviceIntent = Intent(context, TodayWidgetService::class.java)
        serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        serviceIntent.data = Uri.parse(serviceIntent.toUri(Intent.URI_INTENT_SCHEME))
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

        manager.updateAppWidget(widgetId, views)
        manager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_list)
    }

    private fun midnightIntent(context: Context): PendingIntent {
        val intent = Intent(context, TodayWidgetProvider::class.java).setAction(ACTION_MIDNIGHT)
        return PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    /** Неточный будильник на ближайшую полночь: смена дня без запуска приложения. */
    private fun scheduleMidnightRefresh(context: Context) {
        val triggerAt = LocalDate.now().plusDays(1)
            .atStartOfDay(ZoneId.systemDefault())
            .toInstant()
            .toEpochMilli() + 5_000
        context.getSystemService(AlarmManager::class.java)
            .set(AlarmManager.RTC, triggerAt, midnightIntent(context))
    }

    private companion object {
        const val ACTION_MIDNIGHT = "com.bzorn.asu_schedule.ACTION_TODAY_WIDGET_MIDNIGHT"
    }
}
