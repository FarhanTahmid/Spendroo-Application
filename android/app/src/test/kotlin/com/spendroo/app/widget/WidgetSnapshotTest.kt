package com.spendroo.app.widget

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetSnapshotTest {
    // The shape lib/features/home_widget/widget_snapshot.dart writes
    private val json = """
        {"v":1,"signedIn":true,"unlocked":true,"date":"2026-10-17","month":"2026-10",
         "today":"৳450","zero":"৳0","mask":"৳••••","monthName":"October","monthLabel":"Spent in October","monthTotal":"৳18,420",
         "middle":{"label":"Budget left","value":"62%"},
         "left":{"label":"Left this month","value":"-৳1,200"},"leftNegative":true,
         "pace":"Safe ৳610/day","paceTone":"safe",
         "daily":[100,0,250],"budgetPerDay":200,"axis":["1","16","31"],
         "strings":{"today":"Today","expense":"Expense","spentThisMonth":"Spent this month"},"updated":"Updated 10:42"}
    """.trimIndent()

    @Test
    fun readsWhatTheAppWrites() {
        val s = WidgetSnapshot.parse(json)!!
        assertTrue(s.signedIn)
        assertTrue(s.unlocked)
        assertEquals("৳450", s.today)
        assertEquals("2026-10", s.month)
        assertEquals(16, s.todayIndex)
        assertEquals(WidgetStat("Budget left", "62%"), s.middle)
        assertEquals("Spent in October", s.monthLabel)
        assertEquals(WidgetStat("Left this month", "-৳1,200"), s.left)
        assertTrue(s.leftNegative)
        assertEquals(PaceTone.SAFE, s.paceTone)
        assertEquals(listOf(100L, 0L, 250L), s.daily)
        assertEquals(200L, s.budgetPerDay)
        assertEquals("Today", s.text("today"))
        assertEquals("", s.text("missing"))
    }

    @Test
    fun nothingStoredOrBrokenOrNewerReadsAsNothing() {
        assertNull(WidgetSnapshot.parse(null))
        assertNull(WidgetSnapshot.parse(""))
        assertNull(WidgetSnapshot.parse("{not json"))
        assertNull(WidgetSnapshot.parse("""{"v":2,"signedIn":true}"""))
    }

    @Test
    fun signedOutSnapshotHasNoFigures() {
        val s = WidgetSnapshot.parse("""{"v":1,"signedIn":false,"pace":null,"strings":{"signInTitle":"Sign in"}}""")!!
        assertFalse(s.signedIn)
        assertNull(s.pace)
        assertNull(s.middle)
        assertEquals("Sign in", s.text("signInTitle"))
    }

    @Test
    fun sameDayIsUnchanged() {
        val s = WidgetSnapshot.parse(json)!!
        assertSame(s, s.resolveFor("2026-10-17"))
    }

    @Test
    fun nextDayStartsAtNothingButKeepsTheMonth() {
        val s = WidgetSnapshot.parse(json)!!.resolveFor("2026-10-18")
        assertEquals("৳0", s.today)
        assertNull(s.pace)
        assertEquals("৳18,420", s.monthTotal)
        assertEquals("October", s.monthName)
        assertEquals("Spent in October", s.monthLabel)
        assertEquals("-৳1,200", s.left.value)
        assertTrue(s.leftNegative)
        assertEquals(17, s.todayIndex)
        assertEquals(3, s.daily.size)
    }

    @Test
    fun newMonthStartsAtNothingEverywhere() {
        val s = WidgetSnapshot.parse(json)!!.resolveFor("2026-11-01")
        assertEquals("৳0", s.today)
        assertEquals("৳0", s.monthTotal)
        assertEquals("", s.monthName)
        assertEquals("Spent this month", s.monthLabel)
        assertNull(s.middle)
        assertTrue(s.daily.isEmpty())
        assertFalse(s.hasSpending)
        // Nothing has come in or gone out of the new month yet
        assertEquals("৳0", s.left.value)
        assertEquals("Left this month", s.left.label)
        assertFalse(s.leftNegative)
    }

    @Test
    fun maskedHidesEveryAmount() {
        val s = WidgetSnapshot.parse(json)!!.masked()
        assertEquals("৳••••", s.today)
        assertEquals("৳••••", s.monthTotal)
        assertEquals("৳••••", s.left.value)
        // A share of the budget is no amount: it stays
        assertEquals("62%", s.middle!!.value)
        // A safe-per-day amount is an amount too
        assertNull(s.pace)
    }

    @Test
    fun maskedHidesADailyAverageToo() {
        val average = WidgetSnapshot.parse(json.replace("\"Budget left\",\"value\":\"62%\"", "\"Daily average\",\"value\":\"৳55\""))!!
        assertEquals("৳••••", average.masked().middle!!.value)
    }

    @Test
    fun maskedKeepsTheOverBudgetWarning() {
        val over = WidgetSnapshot.parse(json.replace("\"paceTone\":\"safe\"", "\"paceTone\":\"over\""))!!
        assertEquals("Safe ৳610/day", over.masked().pace)
    }

    @Test
    fun signedOutIsNeverRolledOver() {
        val s = WidgetSnapshot.parse("""{"v":1,"signedIn":false}""")!!
        assertSame(s, s.resolveFor("2030-01-01"))
    }
}
