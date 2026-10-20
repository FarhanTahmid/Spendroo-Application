package com.spendroo.app.widget.business

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class BizSizeTest {
    @Test
    fun eachGridSizeGetsItsLayout() {
        assertEquals(BizSize.COMPACT, BizSize.from(110f, 56f))
        assertEquals(BizSize.STRIP, BizSize.from(245f, 56f))
        assertEquals(BizSize.SQUARE, BizSize.from(110f, 115f))
        assertEquals(BizSize.SQUARE, BizSize.from(200f, 400f))
        assertEquals(BizSize.WIDE, BizSize.from(245f, 115f))
        assertEquals(BizSize.WIDE, BizSize.from(320f, 234f))
        assertEquals(BizSize.LARGE, BizSize.from(245f, 260f))
        assertEquals(BizSize.LARGE, BizSize.from(400f, 600f))
    }

    @Test
    fun onlyTheBigSizesArePaid() {
        assertFalse(BizSize.COMPACT.paid)
        assertFalse(BizSize.STRIP.paid)
        assertFalse(BizSize.SQUARE.paid)
        assertTrue(BizSize.WIDE.paid)
        assertTrue(BizSize.LARGE.paid)
    }

    @Test
    fun everyThresholdALayoutChecksIsABreakpoint() {
        val points = BizSize.breakpoints.toSet()
        for (size in BizSize.entries) assertTrue(size.name, (size.minWidth to size.minHeight) in points)
        assertTrue((BizSize.WIDE.minWidth to BizSize.WIDE_INSIGHT_HEIGHT) in points)
        assertTrue((BizSize.WIDE.minWidth to BizSize.WIDE_CHART_HEIGHT) in points)
        assertTrue((BizSize.LARGE.minWidth to BizSize.LARGE_CHART_HEIGHT) in points)
        assertTrue((BizSize.LARGE.minWidth to BizSize.LARGE_LIST_HEIGHT) in points)
        assertTrue((BizSize.WIDE_LARGE_WIDTH to BizSize.LARGE.minHeight) in points)
        // The steps within a layout stay within it
        assertEquals(BizSize.WIDE, BizSize.from(BizSize.WIDE.minWidth, BizSize.WIDE_CHART_HEIGHT))
        assertEquals(BizSize.LARGE, BizSize.from(BizSize.LARGE.minWidth, BizSize.LARGE_LIST_HEIGHT))
    }
}
