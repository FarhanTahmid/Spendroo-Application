package com.spendroo.app.widget

/** Made-up figures for the widget picker's preview, so it shows the widget as it will look in use. */
object WidgetSamples {
    private val pattern = longArrayOf(42, 18, 65, 30, 0, 88, 24, 51, 36, 12, 74, 28, 46, 20, 95, 33, 40, 15, 58, 26)

    fun preview(todayIso: String): WidgetSnapshot {
        val day = todayIso.drop(8).toIntOrNull()?.coerceIn(1, 28) ?: 15
        val daily = List(30) { index -> if (index < day) pattern[index % pattern.size] * 1000 else 0L }
        return WidgetSnapshot(
            signedIn = true,
            unlocked = true,
            date = todayIso.take(8) + day.toString().padStart(2, '0'),
            today = "৳450",
            zero = "৳0",
            mask = "৳••••",
            monthName = "",
            monthLabel = "Spent this month",
            monthTotal = "৳18,420",
            middle = WidgetStat("Budget left", "62%"),
            left = WidgetStat("Left this month", "৳26,580"),
            leftNegative = false,
            pace = "Safe ৳610/day",
            paceTone = PaceTone.SAFE,
            daily = daily,
            budgetPerDay = 60_000,
            axis = listOf("1", "15", "30"),
            strings = mapOf(
                "today" to "Today",
                "thisMonth" to "This month",
                "expense" to "Expense",
                "income" to "Income",
                "transfer" to "Transfer",
                "add" to "Add",
                "hide" to "Hide amounts",
            ),
            updated = "",
        )
    }
}
