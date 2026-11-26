package com.bzorn.asu_schedule

import android.content.Context
import android.content.Intent
import android.os.Build
import android.text.SpannableString
import android.text.Spanned
import android.text.style.StrikethroughSpan
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

            val title = SpannableString(row.title)
            if (row.cancelled) {
                title.setSpan(
                    StrikethroughSpan(),
                    0,
                    title.length,
                    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
                )
            }
            views.setTextViewText(R.id.item_title, title)

            val meta = if (row.cancelled) {
                listOf(row.meta, context.getString(R.string.today_schedule_widget_cancelled))
                    .filter { it.isNotBlank() }
                    .joinToString(" \u2022 ")
            } else {
                row.meta
            }
            views.setTextViewText(R.id.item_meta, meta)
            views.setViewVisibility(R.id.item_meta, if (meta.isBlank()) View.GONE else View.VISIBLE)

            views.setOnClickFillInIntent(R.id.item_root, Intent())
            return views
        }

        override fun getLoadingView(): RemoteViews? = null

        override fun getViewTypeCount(): Int = 1

        override fun getItemId(position: Int): Long = position.toLong()

        override fun hasStableIds(): Boolean = true
    }
}
