package com.spendroo.app.widget

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.DashPathEffect
import android.graphics.Paint
import android.graphics.RectF
import kotlin.math.max

/** How a day's bar is drawn. */
enum class BarKind {
    /** A day gone by, within the daily budget (or with no budget). */
    NORMAL,

    /** A day gone by that took more than the daily budget. */
    OVER,

    /** Today. */
    TODAY,

    /** A day still to come: a stub on the baseline so the month's length shows. */
    FUTURE,
}

data class Bar(val left: Float, val top: Float, val right: Float, val bottom: Float, val kind: BarKind)

/** Where the bars and the budget line fall in a [width] by [height] box. Pure maths, tested on the JVM. */
object ChartGeometry {
    /** Space between bars as a share of each day's slot. */
    const val GAP = 0.32f

    /** Room left above the tallest bar or the budget line, so neither touches the top. */
    const val HEADROOM = 1.12f

    /** How far one day may stand above the rest before it is cut off at the top. */
    const val OUTLIER = 1.5f

    /**
     * The value the full height stands for. One huge day (rent, a phone) would flatten every
     * other bar, so the scale follows the second-biggest day (or twice the daily budget) and the
     * outlier runs off the top.
     */
    fun scale(daily: List<Long>, budgetPerDay: Long): Float {
        val sorted = daily.sortedDescending()
        val biggest = sorted.firstOrNull() ?: 0L
        val ordinary = max(sorted.getOrElse(1) { 0L }, budgetPerDay * 2) * OUTLIER
        val top = if (ordinary > 0f && biggest > ordinary) ordinary else biggest.toFloat()
        return max(max(top, budgetPerDay.toFloat()), 1f) * HEADROOM
    }

    fun bars(
        daily: List<Long>,
        todayIndex: Int,
        budgetPerDay: Long,
        width: Float,
        height: Float,
        minBar: Float = 2f,
    ): List<Bar> {
        if (daily.isEmpty() || width <= 0f || height <= 0f) return emptyList()
        val slot = width / daily.size
        val inset = slot * GAP / 2
        val top = scale(daily, budgetPerDay)
        return daily.mapIndexed { index, value ->
            val kind = when {
                todayIndex in 0 until index -> BarKind.FUTURE
                index == todayIndex -> BarKind.TODAY
                budgetPerDay > 0 && value > budgetPerDay -> BarKind.OVER
                else -> BarKind.NORMAL
            }
            val barHeight = if (kind == BarKind.FUTURE) minBar else (value / top * height).coerceIn(minBar, height)
            Bar(index * slot + inset, height - barHeight, (index + 1) * slot - inset, height, kind)
        }
    }

    /** Height of the dashed budget line from the top; null without a budget. */
    fun budgetLineY(daily: List<Long>, budgetPerDay: Long, height: Float): Float? =
        if (budgetPerDay <= 0) null else height - budgetPerDay / scale(daily, budgetPerDay) * height
}

/** Draws the month's daily spending into a bitmap the widget shows as an image. */
object SpendChartRenderer {
    fun render(snapshot: WidgetSnapshot, widthPx: Int, heightPx: Int, density: Float): Bitmap {
        val bitmap = Bitmap.createBitmap(widthPx.coerceAtLeast(1), heightPx.coerceAtLeast(1), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val w = widthPx.toFloat()
        val h = heightPx.toFloat()
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        // Baseline
        paint.color = WidgetPalette.HAIRLINE
        paint.strokeWidth = density
        canvas.drawLine(0f, h - density / 2, w, h - density / 2, paint)

        val bars = ChartGeometry.bars(
            snapshot.daily, snapshot.todayIndex, snapshot.budgetPerDay, w, h - density, minBar = 2 * density,
        )
        paint.style = Paint.Style.FILL
        for (bar in bars) {
            paint.color = when (bar.kind) {
                BarKind.NORMAL -> WidgetPalette.BAR
                BarKind.OVER -> WidgetPalette.RED
                BarKind.TODAY -> WidgetPalette.GOLD
                BarKind.FUTURE -> WidgetPalette.BAR_FUTURE
            }
            val radius = (bar.right - bar.left) / 2
            canvas.drawRoundRect(RectF(bar.left, bar.top, bar.right, bar.bottom), radius, radius, paint)
        }

        ChartGeometry.budgetLineY(snapshot.daily, snapshot.budgetPerDay, h - density)?.let { y ->
            paint.style = Paint.Style.STROKE
            paint.color = WidgetPalette.MINT
            paint.strokeWidth = 1.5f * density
            paint.pathEffect = DashPathEffect(floatArrayOf(4 * density, 3 * density), 0f)
            canvas.drawLine(0f, y, w, y, paint)
            paint.pathEffect = null
        }
        return bitmap
    }
}
