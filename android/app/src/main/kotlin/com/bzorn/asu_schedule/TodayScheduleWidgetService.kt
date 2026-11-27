package com.bzorn.asu_schedule

import android.content.Context
import android.content.Intent
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.O)
class TodayScheduleWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        Factory(applicationContext)

    private class Factory(private val context: Context) : RemoteViewsFactory {
        private var rows: List<TodayScheduleRow> = emptyList()

        override fun onCreate() = Unit

        override fun onDataSetChanged() {
            rows =
                (TodayScheduleWidgetData.load(context) as? TodayScheduleState.Day)?.rows.orEmpty()
        }

        override fun onDestroy() {
            rows = emptyList()
        }

        override fun getCount(): Int = rows.size

        override fun getViewAt(position: Int): RemoteViews? {
            val row = rows.getOrNull(position) ?: return null
            val views = RemoteViews(context.packageName, R.layout.today_schedule_widget_item)

            views.setViewVisibility(
                R.id.item_pair_column,
                if (row.isNote) View.GONE else View.VISIBLE,
            )
            views.setTextViewText(R.id.item_pair, row.pairLabel)
            views.setTextViewText(R.id.item_time, row.time)
            views.setTextViewText(R.id.item_title, row.title)
            views.setTextColor(
                R.id.item_title,
                context.getColor(
                    if (row.cancelled) R.color.widget_text_secondary else R.color.widget_text_primary
                ),
            )

            views.setTextViewText(R.id.item_meta, row.meta)
            views.setViewVisibility(
                R.id.item_meta,
                if (row.meta.isBlank()) View.GONE else View.VISIBLE,
            )

            views.setTextViewText(
                R.id.item_status,
                context.getString(R.string.today_schedule_widget_cancelled),
            )
            views.setViewVisibility(
                R.id.item_status,
                if (row.cancelled) View.VISIBLE else View.GONE,
            )

            views.setOnClickFillInIntent(R.id.item_root, Intent())
            return views
        }

        override fun getLoadingView(): RemoteViews? = null

        override fun getViewTypeCount(): Int = 1

        override fun getItemId(position: Int): Long = position.toLong()

        override fun hasStableIds(): Boolean = true
    }
}
