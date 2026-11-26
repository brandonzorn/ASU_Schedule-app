package com.bzorn.asu_schedule

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import org.json.JSONObject
import java.time.LocalDate

data class TodayScheduleRow(
    val pairLabel: String,
    val time: String,
    val title: String,
    val meta: String,
    val cancelled: Boolean,
    val isNote: Boolean,
)

sealed interface TodayScheduleState {
    data object NoData : TodayScheduleState
    data class Day(val rows: List<TodayScheduleRow>) : TodayScheduleState
}

@RequiresApi(Build.VERSION_CODES.O)
object TodayScheduleWidgetData {
    private const val PREFS = "HomeWidgetPreferences"
    private const val KEY = "today_schedule_widget_data"

    fun load(context: Context, today: LocalDate = LocalDate.now()): TodayScheduleState {
        val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY, null) ?: return TodayScheduleState.NoData
        return try {
            parse(context, raw, today)
        } catch (_: Exception) {
            TodayScheduleState.NoData
        }
    }

    private fun JSONObject.str(name: String): String =
        if (isNull(name)) "" else optString(name)


    private fun parse(context: Context, raw: String, today: LocalDate): TodayScheduleState {
        val root = JSONObject(raw)
        val weekStart = LocalDate.parse(root.str("weekStart").take(10))
        val weekEnd = LocalDate.parse(root.str("weekEnd").take(10))
        if (today.isBefore(weekStart) || today.isAfter(weekEnd)) {
            return TodayScheduleState.NoData
        }

        val day = root.optJSONObject("days")?.optJSONObject(today.toString())
            ?: return TodayScheduleState.Day(emptyList())

        val rows = mutableListOf<TodayScheduleRow>()

        val notes = day.optJSONArray("notes")
        for (i in 0 until (notes?.length() ?: 0)) {
            val note = notes!!.getJSONObject(i)
            val pairs = note.optJSONArray("pairs")
            val pairsText = (0 until (pairs?.length() ?: 0))
                .joinToString(", ") { pairs!!.getInt(it).toString() }
            val reason = note.str("reason")
            val text = if (pairsText.isEmpty()) {
                context.getString(R.string.today_schedule_widget_note_all, reason)
            } else {
                context.getString(R.string.today_schedule_widget_note_pairs, pairsText, reason)
            }
            rows += TodayScheduleRow("", "", "\u26A0 $text", "", cancelled = false, isNote = true)
        }

        val lessons = day.optJSONArray("lessons")
        for (i in 0 until (lessons?.length() ?: 0)) {
            val lesson = lessons!!.getJSONObject(i)
            val meta = buildList {
                kindRes(lesson.str("kind"))?.let { add(context.getString(it)) }
                lesson.str("room").takeIf { it.isNotBlank() }
                    ?.let { add(context.getString(R.string.today_schedule_widget_room, it)) }
                if (!lesson.isNull("subgroup")) {
                    add(
                        context.getString(
                            R.string.today_schedule_widget_subgroup,
                            lesson.getInt("subgroup")
                        )
                    )
                }
                lesson.str("teachers").takeIf { it.isNotBlank() }?.let { add(it) }
            }
            rows += TodayScheduleRow(
                pairLabel = context.getString(
                    R.string.today_schedule_widget_pair,
                    lesson.getInt("pair")
                ),
                time = lesson.str("time").replace(" - ", "\u2013"),
                title = lesson.str("discipline"),
                meta = meta.joinToString(" \u2022 "),
                cancelled = lesson.optBoolean("cancelled", false),
                isNote = false,
            )
        }
        return TodayScheduleState.Day(rows)
    }

    private fun kindRes(kind: String): Int? = when (kind) {
        "lecture" -> R.string.today_schedule_widget_kind_lecture
        "seminar" -> R.string.today_schedule_widget_kind_seminar
        "laboratory" -> R.string.today_schedule_widget_kind_laboratory
        "practical" -> R.string.today_schedule_widget_kind_practical
        "selfStudy" -> R.string.today_schedule_widget_kind_self_study
        else -> null
    }
}
