package com.spendroo.app.widget.business

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class InOutGeometryTest {
    @Test
    fun moneyInRisesAndMoneyOutHangs() {
        val bars = InOutGeometry.bars(listOf(0L, 100L), listOf(50L, 0L), width = 100f, height = 100f)
        assertEquals(2, bars.size)
        val out = bars.single { !it.cashIn }
        val cashIn = bars.single { it.cashIn }
        assertEquals(50f, out.top)
        assertTrue(out.bottom > 50f)
        assertEquals(50f, cashIn.bottom)
        assertTrue(cashIn.top < 50f)
        // The last day is today
        assertTrue(cashIn.today)
        assertFalse(out.today)
        // Each day keeps its slot
        assertTrue(out.right <= 50f && cashIn.left >= 50f)
    }

    @Test
    fun barsStayInsideTheBox() {
        val bars = InOutGeometry.bars(listOf(1_000_000L, 10L, 10L), listOf(10L, 10L, 2_000_000L), 90f, 60f)
        for (bar in bars) {
            assertTrue(bar.top >= 0f)
            assertTrue(bar.bottom <= 60f)
        }
    }

    @Test
    fun nothingToDraw() {
        assertTrue(InOutGeometry.bars(emptyList(), emptyList(), 100f, 100f).isEmpty())
        assertTrue(InOutGeometry.bars(listOf(0L, 0L), listOf(0L, 0L), 100f, 100f).isEmpty())
    }
}
