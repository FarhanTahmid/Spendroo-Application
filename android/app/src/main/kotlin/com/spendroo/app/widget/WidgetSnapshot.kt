package com.spendroo.app.widget

import org.json.JSONArray
import org.json.JSONObject

/** A small figure with its caption. */
data class WidgetStat(val label: String, val value: String)

/** How the pace chip reads: budget left, budget gone, or a plain average. */
enum class PaceTone { SAFE, OVER, AVERAGE }

/**
 * What the widget draws, as the app wrote it (lib/features/home_widget/widget_snapshot.dart).
 * Every amount and word arrives formatted, so nothing here knows about money or languages.
 */
data class WidgetSnapshot(
    val signedIn: Boolean,
    val unlocked: Boolean,
    /** The day the figures are for, yyyy-MM-dd. */
    val date: String,
    /** Spent today: a small figure beside the month's. */
    val today: String,
    val zero: String,
    val mask: String,
    val monthName: String,
    /** "Spent in October": the caption of the main figure. */
    val monthLabel: String,
    /** Spent this month: the widget's main figure. */
    val monthTotal: String,
    val middle: WidgetStat?,
    /** This month's income less its spending. */
    val left: WidgetStat,
    val leftNegative: Boolean,
    val pace: String?,
    val paceTone: PaceTone,
    /** Spent per day of the month in minor units; index 0 is the 1st. */
    val daily: List<Long>,
    val budgetPerDay: Long,
    val axis: List<String>,
    val strings: Map<String, String>,
    val updated: String,
) {
    val month: String get() = date.take(7)

    /** Today's position in [daily]; -1 when the figures are not for this month. */
    val todayIndex: Int get() = date.drop(8).toIntOrNull()?.minus(1) ?: -1

    val hasSpending: Boolean get() = daily.any { it > 0 }

    fun text(key: String): String = strings[key].orEmpty()

    /**
     * The figures as they stand on [todayIso]. The app only writes while it is open, so after
     * midnight the stored day is yesterday's: today has nothing spent yet, and in a new month
     * neither has the month.
     */
    fun resolveFor(todayIso: String): WidgetSnapshot {
        if (!signedIn || todayIso == date) return this
        val sameMonth = todayIso.take(7) == month
        return copy(
            date = todayIso,
            today = zero,
            pace = null,
            monthTotal = if (sameMonth) monthTotal else zero,
            monthName = if (sameMonth) monthName else "",
            monthLabel = if (sameMonth) monthLabel else text("spentThisMonth"),
            middle = if (sameMonth) middle else null,
            left = if (sameMonth) left else left.copy(value = zero),
            leftNegative = sameMonth && leftNegative,
            daily = if (sameMonth) daily else emptyList(),
        )
    }

    /** Amounts hidden, for a home screen others can see; a share such as "39%" is no amount. */
    fun masked(): WidgetSnapshot = copy(
        today = mask,
        monthTotal = mask,
        middle = middle?.let { if (isMoney(it.value)) it.copy(value = mask) else it },
        left = left.copy(value = mask),
        pace = pace?.let { if (paceTone == PaceTone.OVER) it else null },
    )

    /** Whether [text] is an amount: it carries the currency symbol the mask starts with. */
    private fun isMoney(text: String): Boolean {
        val symbol = mask.substringBefore('•').trim()
        return symbol.isEmpty() || text.contains(symbol)
    }

    companion object {
        /** The preference home_widget stores the snapshot under (PluginHomeWidgetBridge.dataKey). */
        const val KEY = "snapshot"

        /** The newest shape this code reads. */
        const val VERSION = 1

        /** Null for nothing stored, a broken value, or a shape from a newer app than this widget. */
        fun parse(json: String?): WidgetSnapshot? {
            if (json.isNullOrBlank()) return null
            return try {
                val o = JSONObject(json)
                if (o.optInt("v", 0) > VERSION) return null
                WidgetSnapshot(
                    signedIn = o.optBoolean("signedIn", false),
                    unlocked = o.optBoolean("unlocked", false),
                    date = o.optString("date"),
                    today = o.optString("today"),
                    zero = o.optString("zero"),
                    mask = o.optString("mask", "••••"),
                    monthName = o.optString("monthName"),
                    monthLabel = o.optString("monthLabel"),
                    monthTotal = o.optString("monthTotal"),
                    middle = o.optJSONObject("middle")?.toStat(),
                    left = o.optJSONObject("left")?.toStat() ?: WidgetStat("", ""),
                    leftNegative = o.optBoolean("leftNegative", false),
                    pace = if (o.isNull("pace")) null else o.optString("pace").ifEmpty { null },
                    paceTone = when (o.optString("paceTone")) {
                        "safe" -> PaceTone.SAFE
                        "over" -> PaceTone.OVER
                        else -> PaceTone.AVERAGE
                    },
                    daily = o.optJSONArray("daily").toLongs(),
                    budgetPerDay = o.optLong("budgetPerDay", 0),
                    axis = o.optJSONArray("axis").toStrings(),
                    strings = o.optJSONObject("strings")?.let { s -> s.keys().asSequence().associateWith { s.optString(it) } }
                        ?: emptyMap(),
                    updated = o.optString("updated"),
                )
            } catch (e: Exception) {
                null
            }
        }

        private fun JSONObject.toStat() = WidgetStat(optString("label"), optString("value"))

        private fun JSONArray?.toLongs(): List<Long> =
            if (this == null) emptyList() else List(length()) { optLong(it, 0) }

        private fun JSONArray?.toStrings(): List<String> =
            if (this == null) emptyList() else List(length()) { optString(it) }
    }
}
