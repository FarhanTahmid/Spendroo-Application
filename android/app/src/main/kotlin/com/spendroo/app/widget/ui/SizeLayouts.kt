package com.spendroo.app.widget.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.LocalSize
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.width
import com.spendroo.app.R
import com.spendroo.app.widget.WidgetColors
import com.spendroo.app.widget.WidgetLinks
import com.spendroo.app.widget.WidgetSize
import com.spendroo.app.widget.WidgetSnapshot
import com.spendroo.app.widget.WidgetStat

// One layout per WidgetSize. Each is drawn inside the card SpendrooContent gives it.

/** 2x1: the month's spending, and a gold + for an expense. */
@Composable
fun CompactLayout(s: WidgetSnapshot) {
    Row(modifier = GlanceModifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
        Column(modifier = GlanceModifier.defaultWeight()) {
            Caption(monthLabel(s))
            Amount(s.monthTotal, size = 20.sp)
        }
        Spacer(GlanceModifier.width(8.dp))
        CircleAction(R.drawable.ic_widget_add, WidgetLinks.add("expense"), s.text("expense"), gold = true)
    }
}

/** 4x1: the month's spending and today's side by side, then expense and income buttons. */
@Composable
fun StripLayout(s: WidgetSnapshot, hidden: Boolean) {
    Row(modifier = GlanceModifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
        Column(modifier = GlanceModifier.defaultWeight()) {
            Caption(monthLabel(s))
            Amount(s.monthTotal, size = 20.sp)
        }
        Column(modifier = GlanceModifier.defaultWeight()) {
            Caption(s.text("today"))
            Amount(s.today, size = 15.sp, color = WidgetColors.muted)
        }
        EyeToggle(hidden, s.text(if (hidden) "show" else "hide"))
        Spacer(GlanceModifier.width(4.dp))
        CircleAction(R.drawable.ic_widget_add, WidgetLinks.add("expense"), s.text("expense"), gold = true)
        Spacer(GlanceModifier.width(8.dp))
        CircleAction(R.drawable.ic_widget_income, WidgetLinks.add("income"), s.text("income"), gold = false)
    }
}

/** 2x2: the month's spending large, today under it, the add buttons at the foot. */
@Composable
fun SquareLayout(s: WidgetSnapshot, hidden: Boolean) {
    val roomy = LocalSize.current.width.value >= WidgetSize.ROOMY_SQUARE_WIDTH
    Column(modifier = GlanceModifier.fillMaxSize()) {
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            TitleRow(monthLabel(s), modifier = GlanceModifier.defaultWeight())
            EyeToggle(hidden, s.text(if (hidden) "show" else "hide"))
        }
        Amount(s.monthTotal, size = 26.sp)
        Caption("${s.text("today")} · ${s.today}", color = WidgetColors.faint)
        Spacer(GlanceModifier.defaultWeight())
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            if (roomy) {
                ActionPill(
                    s.text("add"), R.drawable.ic_widget_add, WidgetLinks.add("expense"), primary = true,
                    modifier = GlanceModifier.defaultWeight(),
                )
            } else {
                CircleAction(R.drawable.ic_widget_add, WidgetLinks.add("expense"), s.text("expense"), gold = true)
                Spacer(GlanceModifier.defaultWeight())
            }
            Spacer(GlanceModifier.width(6.dp))
            CircleAction(R.drawable.ic_widget_income, WidgetLinks.add("income"), s.text("income"), gold = false)
        }
    }
}

/**
 * 4x2: the month's spending with its pace, then (with Plus) the three figures and a compact
 * chart, labelled buttons at the foot. Kept tight so a launcher's usual 4x2 still fits the chart.
 */
@Composable
fun WideLayout(s: WidgetSnapshot, hidden: Boolean) {
    val height = LocalSize.current.height.value
    // Under about 140dp tall there is room for the month and the buttons only
    val tall = height >= WidgetSize.TALL_WIDE_HEIGHT
    val full = height >= WidgetSize.FULL_WIDE_HEIGHT
    Column(modifier = GlanceModifier.fillMaxSize()) {
        TitleRow(monthLabel(s))
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Amount(s.monthTotal, size = 26.sp)
            s.pace?.let {
                Spacer(GlanceModifier.width(8.dp))
                PaceChip(it, s.paceTone)
            }
            Spacer(GlanceModifier.defaultWeight())
            EyeToggle(hidden, s.text(if (hidden) "show" else "hide"))
        }
        when {
            !tall -> Spacer(GlanceModifier.defaultWeight())
            s.unlocked -> {
                if (full) {
                    Spacer(GlanceModifier.height(4.dp))
                    StatsRow(s)
                }
                Spacer(GlanceModifier.height(8.dp))
                // Title 18 + amount row 34 + figures 38 + buttons 40 + gaps and padding
                ChartArea(
                    s, hidden, reservedHeight = if (full) 176f else 138f, withAxis = false,
                    modifier = GlanceModifier.defaultWeight().fillMaxWidth(),
                )
            }
            full -> {
                Spacer(GlanceModifier.height(8.dp))
                LockedPanel(s, modifier = GlanceModifier.defaultWeight().fillMaxWidth(), compact = true)
            }
            else -> {
                Spacer(GlanceModifier.defaultWeight())
                LockStrip(s)
            }
        }
        Spacer(GlanceModifier.height(8.dp))
        ButtonRow(s)
    }
}

/** 4x3 and up: everything on the 4x2 with room to breathe, and day labels under the chart. */
@Composable
fun LargeLayout(s: WidgetSnapshot, hidden: Boolean) {
    val wide = LocalSize.current.width.value >= WidgetSize.WIDE_LARGE_WIDTH
    Column(modifier = GlanceModifier.fillMaxSize()) {
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            TitleRow(monthLabel(s), modifier = GlanceModifier.defaultWeight())
            if (wide && s.updated.isNotEmpty()) Caption(s.updated, size = 10.sp, color = WidgetColors.faint)
            EyeToggle(hidden, s.text(if (hidden) "show" else "hide"))
        }
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Amount(s.monthTotal, size = 30.sp)
            Spacer(GlanceModifier.defaultWeight())
            s.pace?.let { PaceChip(it, s.paceTone) }
        }
        Spacer(GlanceModifier.height(10.dp))
        if (s.unlocked) {
            StatsRow(s)
            Spacer(GlanceModifier.height(10.dp))
            ChartArea(s, hidden, reservedHeight = 222f, withAxis = true, modifier = GlanceModifier.defaultWeight().fillMaxWidth())
        } else {
            LockedPanel(s, modifier = GlanceModifier.defaultWeight().fillMaxWidth())
        }
        Spacer(GlanceModifier.height(10.dp))
        ButtonRow(s)
    }
}

/** The mark and a caption, heading the bigger sizes. */
@Composable
private fun TitleRow(title: String, modifier: GlanceModifier = GlanceModifier) {
    Row(modifier = modifier, verticalAlignment = Alignment.CenterVertically) {
        BrandMark(18.dp)
        Spacer(GlanceModifier.width(6.dp))
        Caption(title, size = 12.sp)
    }
}

/** Today, the budget left (or daily average), and what is left of the month's income. */
@Composable
private fun StatsRow(s: WidgetSnapshot) {
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        StatCell(WidgetStat(s.text("today"), s.today), modifier = GlanceModifier.defaultWeight())
        s.middle?.let { StatCell(it, modifier = GlanceModifier.defaultWeight()) }
        StatCell(
            s.left,
            modifier = GlanceModifier.defaultWeight(),
            valueColor = if (s.leftNegative) WidgetColors.red else WidgetColors.mint,
        )
    }
}

/** Expense in gold, then income and transfer. */
@Composable
private fun ButtonRow(s: WidgetSnapshot) {
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        ActionPill(
            s.text("expense"), R.drawable.ic_widget_expense, WidgetLinks.add("expense"), primary = true,
            modifier = GlanceModifier.defaultWeight(),
        )
        Spacer(GlanceModifier.width(6.dp))
        ActionPill(
            s.text("income"), R.drawable.ic_widget_income, WidgetLinks.add("income"), primary = false,
            modifier = GlanceModifier.defaultWeight(),
        )
        Spacer(GlanceModifier.width(6.dp))
        ActionPill(
            s.text("transfer"), R.drawable.ic_widget_transfer, WidgetLinks.add("transfer"), primary = false,
            modifier = GlanceModifier.defaultWeight(),
        )
    }
}

/** "Spent in October"; "Spent this month" from a snapshot older than it can know about. */
private fun monthLabel(s: WidgetSnapshot): String = s.monthLabel.ifEmpty { s.text("spentThisMonth") }
