package com.spendroo.app.widget.business

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import com.spendroo.app.widget.ChartGeometry

/** One day's bar: money in rises above the middle line, money out hangs below it. */
data class FlowBar(
    val left: Float,
    val top: Float,
    val right: Float,
    val bottom: Float,
    val cashIn: Boolean,
    val today: Boolean,
)

/** Where the bars fall in a [width] by [height] box. Pure maths, tested on the JVM. */
object InOutGeometry {
    /** Space between a day's slot and the next, as a share of the slot. */
    const val GAP = 0.3f

    /** The middle line's height from the top. */
    fun middle(height: Float): Float = height / 2

    /**
     * Both directions share one scale, the personal chart's: it follows the second-biggest amount,
     * so one huge day runs off the edge instead of flattening the rest. Days with nothing that way
     * get no bar.
     */
    fun bars(dailyIn: List<Long>, dailyOut: List<Long>, width: Float, height: Float, minBar: Float = 2f): List<FlowBar> {
        val days = maxOf(dailyIn.size, dailyOut.size)
        if (days == 0 || width <= 0f || height <= 0f) return emptyList()
        val top = ChartGeometry.scale(dailyIn + dailyOut, 0)
        val half = middle(height)
        val slot = width / days
        val inset = slot * GAP / 2
        val bars = mutableListOf<FlowBar>()
        for (index in 0 until days) {
            val today = index == days - 1
            val left = index * slot + inset
            val right = (index + 1) * slot - inset
            val cashIn = dailyIn.getOrElse(index) { 0L }
            val cashOut = dailyOut.getOrElse(index) { 0L }
            if (cashIn > 0) {
                val size = (cashIn / top * half).coerceIn(minBar, half)
                bars += FlowBar(left, half - size, right, half, cashIn = true, today = today)
            }
            if (cashOut > 0) {
                val size = (cashOut / top * half).coerceIn(minBar, half)
                bars += FlowBar(left, half, right, half + size, cashIn = false, today = today)
            }
        }
        return bars
    }
}

/** Draws the last fortnight's money in and out into a bitmap the widget shows as an image. */
object InOutChartRenderer {
    fun render(dailyIn: List<Long>, dailyOut: List<Long>, widthPx: Int, heightPx: Int, density: Float): Bitmap {
        val bitmap = Bitmap.createBitmap(widthPx.coerceAtLeast(1), heightPx.coerceAtLeast(1), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val w = widthPx.toFloat()
        val h = heightPx.toFloat()
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        val middle = InOutGeometry.middle(h)
        paint.color = BizPalette.HAIRLINE
        paint.strokeWidth = density
        canvas.drawLine(0f, middle, w, middle, paint)

        paint.style = Paint.Style.FILL
        for (bar in InOutGeometry.bars(dailyIn, dailyOut, w, h, minBar = 2 * density)) {
            paint.color = when {
                bar.cashIn && bar.today -> BizPalette.MINT
                bar.cashIn -> BizPalette.MINT_SOFT
                bar.today -> BizPalette.CORAL
                else -> BizPalette.CORAL_SOFT
            }
            val radius = minOf((bar.right - bar.left) / 2, 3 * density)
            canvas.drawRoundRect(RectF(bar.left, bar.top, bar.right, bar.bottom), radius, radius, paint)
        }
        return bitmap
    }
}
