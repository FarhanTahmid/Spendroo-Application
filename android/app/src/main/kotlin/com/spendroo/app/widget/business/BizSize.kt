package com.spendroo.app.widget.business

/**
 * The layouts the business and cashbook widgets switch between as they are resized; the same grid
 * steps as the personal widget (WidgetSize). 2x1, 4x1 and 2x2 are for every plan; 4x2 and larger
 * are what widget.business unlocks.
 */
enum class BizSize(val minWidth: Float, val minHeight: Float) {
    /** 2x1: the name and the balance. */
    COMPACT(110f, 56f),

    /** 4x1: the balance, today's money in and out, and the add buttons. */
    STRIP(245f, 56f),

    /** 2x2: the balance large, today under it, Cash in / Cash out at the foot. */
    SQUARE(110f, 115f),

    /** 4x2: adds the period switch, in / out / net, then advice and a compact chart as height allows. */
    WIDE(245f, 115f),

    /** 4x3 and up: the full picture, with the books or latest entries when tall enough. */
    LARGE(245f, 260f);

    val paid: Boolean get() = this == WIDE || this == LARGE

    companion object {
        /** A 4x2 tall enough for a line of advice. */
        const val WIDE_INSIGHT_HEIGHT = 150f

        /** A 4x2 tall enough for the compact chart as well. */
        const val WIDE_CHART_HEIGHT = 200f

        /** A 4x3 tall enough for the chart. */
        const val LARGE_CHART_HEIGHT = 330f

        /** A 4x4 tall enough for the list of books or entries under the chart. */
        const val LARGE_LIST_HEIGHT = 420f

        /** Wide enough to say when the figures were updated. */
        const val WIDE_LARGE_WIDTH = 300f

        /**
         * Every size the widgets are drawn at. Glance hands a layout the breakpoint it matched, not
         * the real size (LocalSize), so each threshold a layout checks must be a breakpoint of its own.
         */
        val breakpoints: List<Pair<Float, Float>> = listOf(
            COMPACT.minWidth to COMPACT.minHeight,
            STRIP.minWidth to STRIP.minHeight,
            SQUARE.minWidth to SQUARE.minHeight,
            WIDE.minWidth to WIDE.minHeight,
            WIDE.minWidth to WIDE_INSIGHT_HEIGHT,
            WIDE.minWidth to WIDE_CHART_HEIGHT,
            WIDE_LARGE_WIDTH to WIDE_CHART_HEIGHT,
            LARGE.minWidth to LARGE.minHeight,
            WIDE_LARGE_WIDTH to LARGE.minHeight,
            LARGE.minWidth to LARGE_CHART_HEIGHT,
            WIDE_LARGE_WIDTH to LARGE_CHART_HEIGHT,
            LARGE.minWidth to LARGE_LIST_HEIGHT,
            WIDE_LARGE_WIDTH to LARGE_LIST_HEIGHT,
        )

        fun from(width: Float, height: Float): BizSize = when {
            width >= LARGE.minWidth && height >= LARGE.minHeight -> LARGE
            width >= WIDE.minWidth && height >= WIDE.minHeight -> WIDE
            height >= SQUARE.minHeight -> SQUARE
            width >= STRIP.minWidth -> STRIP
            else -> COMPACT
        }
    }
}
