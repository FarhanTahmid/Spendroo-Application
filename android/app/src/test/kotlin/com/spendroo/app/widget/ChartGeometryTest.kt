package com.spendroo.app.widget

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ChartGeometryTest {
    private val daily = listOf(100L, 300L, 0L, 200L, 0L, 0L)

    @Test
    fun oneBarPerDayAcrossTheWidth() {
        val bars = ChartGeometry.bars(daily, todayIndex = 3, budgetPerDay = 0, width = 600f, height = 100f)
        assertEquals(6, bars.size)
        // 100 wide slots, bars inset by the gap on each side
        assertEquals(16f, bars[0].left, 0.01f)
        assertEquals(84f, bars[0].right, 0.01f)
        assertEquals(516f, bars[5].left, 0.01f)
        bars.forEach { assertEquals(100f, it.bottom, 0.01f) }
    }

    @Test
    fun theBiggestDayLeavesHeadroom() {
        val bars = ChartGeometry.bars(daily, todayIndex = 3, budgetPerDay = 0, width = 600f, height = 112f)
        // 300 is the tallest; the full height stands for 300 * 1.12
        assertEquals(12f, bars[1].top, 0.01f)
        assertEquals(112f - 100f / 336f * 112f, bars[0].top, 0.01f)
    }

    @Test
    fun oneHugeDayDoesNotFlattenTheRest() {
        // Rent on the 5th: 18,440 against days of a few hundred
        val month = listOf(70L, 610L, 500L, 3800L, 18440L, 430L)
        // Scale from the second-biggest day: 3,800 * 1.5, with headroom
        assertEquals(3800f * 1.5f * 1.12f, ChartGeometry.scale(month, 0), 0.5f)
        val bars = ChartGeometry.bars(month, todayIndex = 5, budgetPerDay = 0, width = 600f, height = 100f)
        // The huge day is cut off at the top; the others keep their shape
        assertEquals(0f, bars[4].top, 0.01f)
        assertEquals(100f - 3800f / (3800f * 1.5f * 1.12f) * 100f, bars[3].top, 0.01f)
    }

    @Test
    fun aBudgetKeepsTheScaleHonest() {
        // Twice the daily budget is ordinary, so 300 is no outlier against a 200 budget
        assertEquals(300f * 1.12f, ChartGeometry.scale(listOf(100L, 300L, 0L), 200), 0.01f)
    }

    @Test
    fun aDayWithNothingStillShowsAStub() {
        val bars = ChartGeometry.bars(daily, todayIndex = 3, budgetPerDay = 0, width = 600f, height = 100f, minBar = 2f)
        assertEquals(98f, bars[2].top, 0.01f)
    }

    @Test
    fun kindsFollowTodayAndTheBudget() {
        val bars = ChartGeometry.bars(daily, todayIndex = 3, budgetPerDay = 150, width = 600f, height = 100f)
        assertEquals(
            listOf(BarKind.NORMAL, BarKind.OVER, BarKind.NORMAL, BarKind.TODAY, BarKind.FUTURE, BarKind.FUTURE),
            bars.map { it.kind },
        )
    }

    @Test
    fun withoutABudgetNoDayIsOver() {
        val bars = ChartGeometry.bars(daily, todayIndex = 5, budgetPerDay = 0, width = 600f, height = 100f)
        assertTrue(bars.none { it.kind == BarKind.OVER })
        assertTrue(bars.none { it.kind == BarKind.FUTURE })
    }

    @Test
    fun aMonthGoneByHasNoTodayAndNoFuture() {
        val bars = ChartGeometry.bars(daily, todayIndex = -1, budgetPerDay = 0, width = 600f, height = 100f)
        assertTrue(bars.all { it.kind == BarKind.NORMAL })
    }

    @Test
    fun theBudgetLineSitsAtItsShare() {
        assertNull(ChartGeometry.budgetLineY(daily, 0, 100f))
        // 150 of a 336 scale (300 * 1.12)
        assertEquals(100f - 150f / 336f * 100f, ChartGeometry.budgetLineY(daily, 150, 100f)!!, 0.01f)
        // A budget above every day sets the scale itself
        assertEquals(100f - 100f / 1.12f, ChartGeometry.budgetLineY(daily, 1000, 100f)!!, 0.01f)
    }

    @Test
    fun nothingToDrawGivesNoBars() {
        assertTrue(ChartGeometry.bars(emptyList(), 0, 0, 100f, 100f).isEmpty())
        assertTrue(ChartGeometry.bars(daily, 0, 0, 0f, 100f).isEmpty())
        // An empty month does not divide by zero
        assertEquals(3, ChartGeometry.bars(listOf(0L, 0L, 0L), 1, 0, 30f, 10f).size)
    }
}
