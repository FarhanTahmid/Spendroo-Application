package com.spendroo.app.widget.business

import org.json.JSONArray
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class BizSnapshotTest {
    private fun period(label: String, value: String) = JSONObject()
        .put("label", label).put("compare", "vs last month")
        .put("in", value).put("out", value).put("net", "+$value").put("netNegative", false)
        .put("inChange", "▲10%").put("inGood", true).put("outChange", JSONObject.NULL).put("outGood", true)

    private fun insight(kind: String, text: String, masked: String, tone: String, until: String) = JSONObject()
        .put("kind", kind).put("text", text).put("masked", masked).put("tone", tone).put("until", until)

    private fun json(): String = JSONObject()
        .put("v", 1).put("kind", "book").put("id", "b1").put("workspaceId", "w1")
        .put("name", "Till").put("subtitle", "Shop").put("date", "2026-10-20")
        .put("balance", "৳5,000").put("balanceNegative", false).put("mask", "৳••••").put("zero", "৳0")
        .put("canAdd", true)
        .put("today", period("Today", "৳100"))
        .put("week", period("7 days", "৳700"))
        .put("month", period("October", "৳2,000"))
        .put("weekRoll", JSONArray((1..6).map { day -> period("7 days", "৳${700 - day * 100}") }))
        .put("dailyIn", JSONArray((1..14).map { day -> day * 10L }))
        .put("dailyOut", JSONArray((1..14).map { day -> day * 5L }))
        .put("dayLabels", JSONArray((7..26).map { day -> day.toString() }))
        .put(
            "insights",
            JSONArray(
                listOf(
                    insight("idle", "No entries since 12 Oct", "No entries since 12 Oct", "warn", "9999-12-31"),
                    insight("biggestOut", "Biggest: Rent, ৳900", "Biggest: Rent", "info", "2026-10-20"),
                ),
            ),
        )
        .put(
            "rows",
            JSONArray(
                listOf(
                    JSONObject().put("title", "Sales").put("detail", "20 Oct").put("amount", "+৳100")
                        .put("negative", false).put("link", "spendroo://book?id=b1&ws=w1"),
                ),
            ),
        )
        .put("updated", "Updated 10:42")
        .toString()

    @Test
    fun readsWhatTheAppWrites() {
        val s = BizSnapshot.parse(json())!!
        assertEquals("Till", s.name)
        assertEquals("৳700", s.week.inText)
        assertEquals("▲10%", s.month.inChange)
        assertNull(s.month.outChange)
        assertEquals(14, s.dailyIn.size)
        assertEquals(listOf("7", "14", "20"), s.axis)
        assertEquals(BizTone.WARN, s.insights[0].tone)
        assertEquals("spendroo://book?id=b1&ws=w1", s.rows[0].link)
    }

    @Test
    fun brokenOrNewerShapesAreIgnored() {
        assertNull(BizSnapshot.parse(null))
        assertNull(BizSnapshot.parse("{oops"))
        assertNull(BizSnapshot.parse(JSONObject(json()).put("v", 99).toString()))
    }

    @Test
    fun theSameDayIsLeftAlone() {
        val s = BizSnapshot.parse(json())!!
        assertEquals(s, s.resolveFor("2026-10-20", "This month"))
    }

    @Test
    fun aNewDayStartsAtNothingAndRollsTheWeekOn() {
        val s = BizSnapshot.parse(json())!!.resolveFor("2026-10-22", "This month")
        assertEquals("৳0", s.today.inText)
        assertNull(s.today.inChange)
        // Two days on: the seven days ending the 22nd, as the app worked them out
        assertEquals("৳500", s.week.inText)
        // Same month: the month so far holds, without a comparison it can no longer make
        assertEquals("৳2,000", s.month.inText)
        assertNull(s.month.inChange)
        assertEquals(listOf(0L, 0L), s.dailyIn.takeLast(2))
        assertEquals(30L, s.dailyIn.first())
        assertEquals(listOf("9", "16", "22"), s.axis)
        // Advice that only held on the 20th is gone
        assertEquals(listOf("idle"), s.insights.map { it.kind })
    }

    @Test
    fun aNewMonthStartsTheMonthAtNothing() {
        val s = BizSnapshot.parse(json())!!.resolveFor("2026-11-02", "This month")
        assertEquals("৳0", s.month.inText)
        assertEquals("This month", s.month.label)
        // Past the week the app worked out ahead: nothing known
        assertEquals("৳0", s.week.inText)
        // Thirteen days on, the 20th is the fortnight's first day; nothing is known after it
        assertEquals(140L, s.dailyIn.first())
        assertTrue(s.dailyIn.drop(1).all { it == 0L })
        assertTrue(s.axis.isEmpty())
    }

    @Test
    fun maskingHidesAmountsButKeepsChangesAndAdvice() {
        val s = BizSnapshot.parse(json())!!.masked()
        assertEquals("৳••••", s.balance)
        assertEquals("৳••••", s.month.inText)
        assertEquals("৳••••", s.month.net)
        assertEquals("▲10%", s.month.inChange)
        assertEquals("৳••••", s.rows[0].amount)
        assertEquals("Biggest: Rent", s.insights[1].text)
        assertFalse(s.insights[1].text.contains("৳"))
    }

    @Test
    fun catalogKnowsBusinessesAndBooks() {
        val book = JSONObject().put("id", "b1").put("name", "Till").put("detail", "৳0")
        val business = JSONObject().put("id", "w1").put("name", "Shop").put("detail", "1 cashbook")
            .put("books", JSONArray(listOf(book)))
        val catalog = BizCatalog.parse(
            JSONObject().put("v", 1).put("signedIn", true).put("unlocked", false)
                .put("strings", JSONObject().put("balance", "Balance"))
                .put("businesses", JSONArray(listOf(business)))
                .toString(),
        )!!
        assertTrue(catalog.knows("w1"))
        assertTrue(catalog.knows("b1"))
        assertFalse(catalog.knows("gone"))
        assertEquals("Balance", catalog.text("balance"))
        assertFalse(catalog.unlocked)
        // One business with one book: both widgets show them without asking
        assertEquals("w1", catalog.onlyChoice(business = true))
        assertEquals("b1", catalog.onlyChoice(business = false))
        assertNull(catalog.copy(businesses = catalog.businesses + catalog.businesses).onlyChoice(business = true))
    }

    @Test
    fun periodsCycle() {
        assertEquals(BizPeriodKind.WEEK, BizPeriodKind.TODAY.next())
        assertEquals(BizPeriodKind.TODAY, BizPeriodKind.MONTH.next())
        assertEquals(BizPeriodKind.MONTH, BizPeriodKind.from(null))
        assertEquals(BizPeriodKind.WEEK, BizPeriodKind.from("WEEK"))
    }

    @Test
    fun aCashbookIsNamedWithItsBusiness() {
        val book = BizSnapshot.parse(json())!!
        assertEquals("Till · Shop", book.title)
        // A business widget names the business alone; a book without one (an old snapshot) its own name
        assertEquals("Shop", book.copy(kind = "business", name = "Shop", subtitle = "2 books").title)
        assertEquals("Till", book.copy(subtitle = "").title)
        // Masking hides amounts, never whose book it is
        assertEquals("Till · Shop", book.masked().title)
    }
}
