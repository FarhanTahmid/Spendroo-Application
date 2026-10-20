package com.spendroo.app.widget.business

import java.time.LocalDate

/** Made-up figures for the widget picker's preview, so it shows the widget as it will look in use. */
object BizSamples {
    private val cashIn = longArrayOf(820, 640, 0, 910, 1200, 760, 530, 980, 1100, 690, 0, 870, 1320, 820)
    private val cashOut = longArrayOf(310, 520, 140, 260, 880, 300, 210, 450, 390, 610, 120, 340, 500, 315)

    private val strings = mapOf(
        "balance" to "Balance",
        "cashIn" to "Cash in",
        "cashOut" to "Cash out",
        "net" to "Net",
        "today" to "Today",
        "hide" to "Hide amounts",
        "booksTitle" to "Cashbooks",
        "recentTitle" to "Recent",
    )

    private fun period(label: String, inText: String, outText: String, net: String) =
        BizPeriod(label, "vs last month", inText, outText, net, false, "▲12%", true, "▼4%", true)

    fun preview(business: Boolean, today: LocalDate): BizView {
        val snapshot = BizSnapshot(
            kind = if (business) "business" else "book",
            id = "sample",
            workspaceId = "sample",
            name = if (business) "Rahman Traders" else "Shop cash",
            subtitle = if (business) "3 cashbooks" else "Rahman Traders",
            date = today.toString(),
            balance = if (business) "৳1,24,500" else "৳38,240",
            balanceNegative = false,
            mask = "৳••••",
            zero = "৳0",
            canAdd = true,
            today = period("Today", "৳8,200", "৳3,150", "+৳5,050"),
            week = period("7 days", "৳61,400", "৳28,900", "+৳32,500"),
            month = period("This month", "৳1,92,000", "৳96,300", "+৳95,700"),
            weekRoll = emptyList(),
            dailyIn = cashIn.map { it * 1000 },
            dailyOut = cashOut.map { it * 1000 },
            dayLabels = (-13..6).map { today.plusDays(it.toLong()).dayOfMonth.toString() },
            insights = listOf(
                BizInsight("inChange", "Cash in is up 18% on last month", "Cash in is up 18% on last month", BizTone.GOOD, "9999-12-31"),
            ),
            rows = if (business) {
                listOf(
                    BizRow("Shop cash", "112 entries", "৳38,240", false, null),
                    BizRow("Bank", "64 entries", "৳79,860", false, null),
                    BizRow("Delivery", "23 entries", "৳6,400", false, null),
                )
            } else {
                listOf(
                    BizRow("Sales", "20 Oct", "+৳4,800", false, null),
                    BizRow("Supplier", "20 Oct", "-৳2,100", true, null),
                    BizRow("Sales", "19 Oct", "+৳3,400", false, null),
                )
            },
            updated = "",
        )
        return BizView(
            business = business,
            appWidgetId = 0,
            catalog = BizCatalog(signedIn = true, unlocked = true, strings = strings, businesses = listOf(
                CatalogBusiness("sample", snapshot.name, "", listOf(CatalogBook("sample", snapshot.name, ""))),
            )),
            target = "sample",
            snapshot = snapshot,
            period = BizPeriodKind.TODAY,
            insight = 0,
            hidden = false,
        )
    }
}
