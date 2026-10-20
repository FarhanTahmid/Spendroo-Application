package com.spendroo.app.widget.business

import androidx.compose.ui.graphics.Color
import androidx.glance.unit.ColorProvider

/**
 * The business widgets' colours on their ledger-green card (drawable/widget_biz_background):
 * Money Green for cash in, coral for cash out, Prosperity Gold for the chosen period and the main
 * actions. The card is green in light and dark themes alike, so text colours hold in both.
 */
object BizPalette {
    const val MINT = 0xFF5BE3A0.toInt()
    const val CORAL = 0xFFFF8A7A.toInt()
    const val GOLD = 0xFFF5B530.toInt()

    /** Past days' bars: the same colours at 55%. */
    const val MINT_SOFT = 0x8C5BE3A0.toInt()
    const val CORAL_SOFT = 0x8CFF8A7A.toInt()
    const val HAIRLINE = 0x33FFFFFF
}

object BizColors {
    val text = ColorProvider(Color(0xFFFFFFFF))
    val muted = ColorProvider(Color(0xB8FFFFFF))
    val faint = ColorProvider(Color(0x80FFFFFF))
    val mint = ColorProvider(Color(BizPalette.MINT))
    val coral = ColorProvider(Color(BizPalette.CORAL))
    val gold = ColorProvider(Color(BizPalette.GOLD))

    /** Text and icons on the bright buttons and the chosen period. */
    val ink = ColorProvider(Color(0xFF06261F))
}
