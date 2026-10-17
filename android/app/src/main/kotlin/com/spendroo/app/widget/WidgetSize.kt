package com.spendroo.app.widget

/**
 * The layouts the widget switches between as it is resized, from Android's widget size guide
 * (2x1 at least 110x56 dp, 4x1 at least 245 wide, 2x2 at least 115 tall). The chart needs about
 * 260dp of height: launchers make a 4x2 anything from 115 to 276dp tall, so a tall 4x2 can show it too.
 */
enum class WidgetSize(val minWidth: Float, val minHeight: Float) {
    /** 2x1: today and one add button. */
    COMPACT(110f, 56f),

    /** 4x1: today, the month, and the add buttons in a strip. */
    STRIP(245f, 56f),

    /** 2x2: today large, the month under it, add buttons at the foot. */
    SQUARE(110f, 115f),

    /** 4x2: adds the pace chip, three figures, a compact chart and labelled buttons. */
    WIDE(245f, 115f),

    /** 4x3 and up (or a tall 4x2): adds the month's daily chart. */
    LARGE(245f, 260f);

    /** Whether the plan decides what this size shows (the free ones are 2x1, 4x1 and 2x2). */
    val paid: Boolean get() = this == WIDE || this == LARGE

    companion object {
        /** A 2x2 wide enough for a labelled add button. */
        const val ROOMY_SQUARE_WIDTH = 140f

        /** A 4x2 tall enough for a compact chart. */
        const val TALL_WIDE_HEIGHT = 140f

        /** A 4x2 tall enough for the three figures as well as the chart. */
        const val FULL_WIDE_HEIGHT = 200f

        /** A 4x3 wide enough to say when the figures were updated. */
        const val WIDE_LARGE_WIDTH = 300f

        /**
         * Every size the widget is drawn at. Glance hands a layout the breakpoint it matched, not
         * the real size (LocalSize), so each threshold a layout checks must be a breakpoint of its
         * own; the taller LARGE steps keep the chart bitmap close to the size it is shown at.
         */
        val breakpoints: List<Pair<Float, Float>> = listOf(
            COMPACT.minWidth to COMPACT.minHeight,
            STRIP.minWidth to STRIP.minHeight,
            SQUARE.minWidth to SQUARE.minHeight,
            ROOMY_SQUARE_WIDTH to SQUARE.minHeight,
            WIDE.minWidth to WIDE.minHeight,
            WIDE.minWidth to TALL_WIDE_HEIGHT,
            WIDE.minWidth to FULL_WIDE_HEIGHT,
            WIDE_LARGE_WIDTH to FULL_WIDE_HEIGHT,
            WIDE_LARGE_WIDTH to 230f,
            LARGE.minWidth to LARGE.minHeight,
            WIDE_LARGE_WIDTH to LARGE.minHeight,
            LARGE.minWidth to 330f,
            WIDE_LARGE_WIDTH to 330f,
            WIDE_LARGE_WIDTH to 420f,
        )

        /** The layout for a widget [width] by [height] dp. */
        fun from(width: Float, height: Float): WidgetSize = when {
            width >= LARGE.minWidth && height >= LARGE.minHeight -> LARGE
            width >= WIDE.minWidth && height >= WIDE.minHeight -> WIDE
            height >= SQUARE.minHeight -> SQUARE
            width >= STRIP.minWidth -> STRIP
            else -> COMPACT
        }
    }
}
