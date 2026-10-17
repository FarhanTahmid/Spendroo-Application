package com.spendroo.app.widget

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetSizeTest {
    @Test
    fun eachGridSizeGetsItsLayout() {
        assertEquals(WidgetSize.COMPACT, WidgetSize.from(110f, 56f))
        assertEquals(WidgetSize.COMPACT, WidgetSize.from(200f, 100f))
        assertEquals(WidgetSize.STRIP, WidgetSize.from(245f, 56f))
        assertEquals(WidgetSize.SQUARE, WidgetSize.from(110f, 115f))
        assertEquals(WidgetSize.SQUARE, WidgetSize.from(200f, 300f))
        assertEquals(WidgetSize.WIDE, WidgetSize.from(245f, 115f))
        // A Pixel launcher's 4x2 is about 234dp tall: too short for the chart
        assertEquals(WidgetSize.WIDE, WidgetSize.from(320f, 234f))
        assertEquals(WidgetSize.LARGE, WidgetSize.from(245f, 260f))
        assertEquals(WidgetSize.LARGE, WidgetSize.from(400f, 600f))
    }

    @Test
    fun justUnderABreakpointStaysSmaller() {
        assertEquals(WidgetSize.COMPACT, WidgetSize.from(244.9f, 114.9f))
        assertEquals(WidgetSize.SQUARE, WidgetSize.from(244.9f, 300f))
        assertEquals(WidgetSize.WIDE, WidgetSize.from(400f, 259.9f))
        assertEquals(WidgetSize.STRIP, WidgetSize.from(400f, 114.9f))
    }

    @Test
    fun everyThresholdALayoutChecksIsABreakpoint() {
        val points = WidgetSize.breakpoints.toSet()
        for (size in WidgetSize.entries) assertTrue(size.name, (size.minWidth to size.minHeight) in points)
        assertTrue((WidgetSize.ROOMY_SQUARE_WIDTH to WidgetSize.SQUARE.minHeight) in points)
        assertTrue((WidgetSize.WIDE.minWidth to WidgetSize.TALL_WIDE_HEIGHT) in points)
        assertTrue((WidgetSize.WIDE.minWidth to WidgetSize.FULL_WIDE_HEIGHT) in points)
        assertTrue((WidgetSize.WIDE_LARGE_WIDTH to WidgetSize.LARGE.minHeight) in points)
        // An extra step never moves a breakpoint into another layout's range by accident
        assertEquals(WidgetSize.SQUARE, WidgetSize.from(WidgetSize.ROOMY_SQUARE_WIDTH, WidgetSize.SQUARE.minHeight))
        assertEquals(WidgetSize.WIDE, WidgetSize.from(WidgetSize.WIDE.minWidth, WidgetSize.TALL_WIDE_HEIGHT))
        // A 4x2 with the chart is still a 4x2, and still a Plus size
        assertEquals(WidgetSize.WIDE, WidgetSize.from(WidgetSize.WIDE_LARGE_WIDTH, 230f))
        for ((width, height) in WidgetSize.breakpoints) {
            if (height >= WidgetSize.TALL_WIDE_HEIGHT && width >= WidgetSize.WIDE.minWidth) {
                assertTrue(WidgetSize.from(width, height).paid)
            }
        }
    }

    @Test
    fun onlyTheTwoBiggestDependOnThePlan() {
        assertFalse(WidgetSize.COMPACT.paid)
        assertFalse(WidgetSize.STRIP.paid)
        assertFalse(WidgetSize.SQUARE.paid)
        assertTrue(WidgetSize.WIDE.paid)
        assertTrue(WidgetSize.LARGE.paid)
    }

    @Test
    fun theSmallestSizeIsWhereEveryOtherCanBeReached() {
        // The provider XML allows resizing down to 110x56; nothing smaller needs a layout
        for (size in WidgetSize.entries) {
            assertEquals(size, WidgetSize.from(size.minWidth, size.minHeight))
        }
    }
}
