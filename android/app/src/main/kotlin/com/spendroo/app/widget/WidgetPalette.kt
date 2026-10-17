package com.spendroo.app.widget

import androidx.compose.ui.graphics.Color
import androidx.glance.unit.ColorProvider

/**
 * The brand colours on the widget's navy card (lib/core/design/tokens.dart): Trust Navy under
 * everything, Prosperity Gold for the main action and today, Money Green for money in and budget
 * room, the soft red of moneyOut on dark for overspending. The card is navy in light and dark
 * themes alike (only its shade changes, drawable vs drawable-night), so text colours hold in both.
 */
object WidgetPalette {
    const val NAVY = 0xFF0B2D5E.toInt()
    const val GOLD = 0xFFF5B530.toInt()
    const val MINT = 0xFF5BE3A0.toInt()
    const val RED = 0xFFFF7A84.toInt()
    const val WHITE = 0xFFFFFFFF.toInt()

    /** A day's bar: white at 55%. */
    const val BAR = 0x8CFFFFFF.toInt()
    const val BAR_FUTURE = 0x26FFFFFF
    const val HAIRLINE = 0x26FFFFFF
}

/** The same colours for Glance text and icons. */
object WidgetColors {
    val text = ColorProvider(Color(WidgetPalette.WHITE))
    val muted = ColorProvider(Color(0xB8FFFFFF))
    val faint = ColorProvider(Color(0x80FFFFFF))
    val gold = ColorProvider(Color(WidgetPalette.GOLD))
    val mint = ColorProvider(Color(WidgetPalette.MINT))
    val red = ColorProvider(Color(WidgetPalette.RED))
    val navy = ColorProvider(Color(WidgetPalette.NAVY))
}
