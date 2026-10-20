package com.spendroo.app.widget.business.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.Action
import androidx.glance.action.clickable
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import com.spendroo.app.R
import com.spendroo.app.widget.WidgetLinks
import com.spendroo.app.widget.business.BizColors
import com.spendroo.app.widget.business.BizSize
import com.spendroo.app.widget.business.BizSnapshot
import com.spendroo.app.widget.business.BizView
import com.spendroo.app.widget.ui.open

/**
 * The whole widget: the green card, and what it can show. Before the app has written anything,
 * while signed out, before a business or book is picked, or once it is gone, it says so and leads
 * to the fix; otherwise the layout for its size.
 */
@Composable
fun BizContent(view: BizView) {
    val size = LocalSize.current
    val bucket = BizSize.from(size.width.value, size.height.value)
    val tight = bucket == BizSize.COMPACT || bucket == BizSize.STRIP
    val catalog = view.catalog
    val snapshot = view.snapshot?.let { if (view.hidden) it.masked() else it }
    val context = LocalContext.current

    val ready = catalog != null && catalog.signedIn && view.target != null && snapshot != null
    val tap: Action = when {
        ready -> open(cardLink(snapshot!!))
        catalog == null || !catalog.signedIn -> open(WidgetLinks.HOME)
        view.target == null || !catalog.knows(view.target) -> pickAction(view.appWidgetId)
        else -> open(WidgetLinks.HOME)
    }

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .appWidgetBackground()
            .background(ImageProvider(R.drawable.widget_biz_background))
            .cornerRadius(R.dimen.widget_radius)
            .padding(horizontal = if (tight) 12.dp else 14.dp, vertical = if (tight) 8.dp else 12.dp)
            .clickable(tap),
    ) {
        when {
            catalog == null -> Message(view, bucket, context.getString(R.string.widget_fallback_title), context.getString(R.string.widget_biz_open_first))
            !catalog.signedIn -> Message(view, bucket, catalog.text("signInTitle"), catalog.text("signInBody"))
            view.target == null -> Message(
                view, bucket, catalog.text(if (view.business) "chooseBusiness" else "chooseBook"), catalog.text("chooseBody"),
            )
            !catalog.knows(view.target) -> Message(view, bucket, catalog.text("goneTitle"), catalog.text("goneBody"))
            // Known, but not stored yet: the app writes it the next time it opens
            snapshot == null -> Message(view, bucket, catalog.text("appName"), context.getString(R.string.widget_biz_open_first))
            else -> when (bucket) {
                BizSize.COMPACT -> CompactLayout(view, snapshot)
                BizSize.STRIP -> StripLayout(view, snapshot)
                BizSize.SQUARE -> SquareLayout(view, snapshot)
                BizSize.WIDE -> WideLayout(view, snapshot, catalog.unlocked)
                BizSize.LARGE -> LargeLayout(view, snapshot, catalog.unlocked)
            }
        }
    }
}

/** A title and a line under it, beside or under the business or book glyph. */
@Composable
private fun Message(view: BizView, size: BizSize, title: String, body: String) {
    if (size == BizSize.COMPACT || size == BizSize.STRIP) {
        Row(modifier = GlanceModifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
            KindTile(view.business, 30.dp)
            Spacer(GlanceModifier.width(10.dp))
            Column(modifier = GlanceModifier.defaultWeight()) {
                BizText(title, size = 13.sp, bold = true)
                if (size == BizSize.STRIP) BizText(body, size = 11.sp, color = BizColors.muted)
            }
        }
    } else {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            KindTile(view.business, 40.dp)
            Spacer(GlanceModifier.height(10.dp))
            BizText(title, size = 15.sp, bold = true, center = true, lines = 2)
            Spacer(GlanceModifier.height(2.dp))
            BizText(body, size = 12.sp, color = BizColors.muted, center = true, lines = 2)
        }
    }
}

/** 2x1: the name (a book's with its business) and the balance. */
@Composable
private fun CompactLayout(view: BizView, s: BizSnapshot) {
    Column(modifier = GlanceModifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
        BizText(s.title, size = 11.sp, color = BizColors.muted)
        BizText(s.balance, size = 20.sp, bold = true, color = if (s.balanceNegative) BizColors.coral else BizColors.text)
    }
}

/** 4x1: the balance, today's money in and out, the eye and the add buttons. */
@Composable
private fun StripLayout(view: BizView, s: BizSnapshot) {
    Row(modifier = GlanceModifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
        Column(modifier = GlanceModifier.defaultWeight()) {
            BizText(s.title, size = 11.sp, color = BizColors.muted)
            BizText(s.balance, size = 19.sp, bold = true, color = if (s.balanceNegative) BizColors.coral else BizColors.text)
            TodayLine(view, s, size = 10.sp)
        }
        com.spendroo.app.widget.ui.EyeToggle(view.hidden, view.catalog?.text(if (view.hidden) "show" else "hide").orEmpty())
        Spacer(GlanceModifier.width(2.dp))
        FlowCircles(view, s, size = 34.dp)
    }
}

/** 2x2: the balance large, today under it, Cash in / Cash out at the foot (or the month, for viewers). */
@Composable
private fun SquareLayout(view: BizView, s: BizSnapshot) {
    Column(modifier = GlanceModifier.fillMaxSize()) {
        BizHeader(view, s)
        Spacer(GlanceModifier.height(4.dp))
        Balance(view, s, size = 22.sp)
        TodayLine(view, s, size = 10.sp)
        Spacer(GlanceModifier.defaultWeight())
        if (s.canAdd) {
            Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                FlowCircle(s, cashIn = true, description = view.catalog?.text("cashIn").orEmpty(), size = 36.dp)
                Spacer(GlanceModifier.defaultWeight())
                FlowCircle(s, cashIn = false, description = view.catalog?.text("cashOut").orEmpty(), size = 36.dp)
            }
        } else {
            BizText("${s.month.label} · ${s.month.net}", size = 11.sp, color = if (s.month.netNegative) BizColors.coral else BizColors.muted)
        }
    }
}

/**
 * 4x2: the period chip and the balance with the add buttons, then (with the plan) in, out and net
 * for the period, a compact chart and a line of advice as height allows.
 */
@Composable
private fun WideLayout(view: BizView, s: BizSnapshot, unlocked: Boolean) {
    val height = LocalSize.current.height.value
    val roomForInsight = height >= BizSize.WIDE_INSIGHT_HEIGHT
    val roomForChart = height >= BizSize.WIDE_CHART_HEIGHT
    val period = s.period(view.period)
    Column(modifier = GlanceModifier.fillMaxSize()) {
        BizHeader(view, s) { if (unlocked) PeriodChip(view, period) }
        Spacer(GlanceModifier.height(2.dp))
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Box(modifier = GlanceModifier.defaultWeight()) { Balance(view, s, size = 22.sp, withLabel = false) }
            FlowCircles(view, s, size = 32.dp)
        }
        if (!unlocked) {
            TodayLine(view, s, size = 10.sp)
            when {
                roomForChart -> {
                    Spacer(GlanceModifier.height(6.dp))
                    BizLockedPanel(view.catalog, GlanceModifier.defaultWeight().fillMaxWidth(), compact = true)
                }
                roomForInsight -> {
                    Spacer(GlanceModifier.defaultWeight())
                    BizLockStrip(view.catalog)
                }
                else -> Spacer(GlanceModifier.defaultWeight())
            }
        } else {
            Spacer(GlanceModifier.height(4.dp))
            FlowStats(view, period, changes = false, valueSize = 13.sp)
            if (roomForChart) {
                Spacer(GlanceModifier.height(6.dp))
                // Padding 24 + header 24 + balance 34 + stats 32 + insight 26 + gaps
                FlowChart(view, s, reservedHeight = 156f, withAxis = false, modifier = GlanceModifier.defaultWeight().fillMaxWidth())
            } else {
                Spacer(GlanceModifier.defaultWeight())
            }
            if (roomForInsight) {
                Spacer(GlanceModifier.height(6.dp))
                InsightLine(view, s.insights)
            }
        }
    }
}

/**
 * 4x3 and up: the period switch, in / out / net with how they moved, advice, the fortnight's chart
 * once tall enough, then the books or latest entries, and labelled buttons at the foot.
 */
@Composable
private fun LargeLayout(view: BizView, s: BizSnapshot, unlocked: Boolean) {
    val size = LocalSize.current
    val wide = size.width.value >= BizSize.WIDE_LARGE_WIDTH
    val roomForChart = size.height.value >= BizSize.LARGE_CHART_HEIGHT
    val roomForList = size.height.value >= BizSize.LARGE_LIST_HEIGHT
    val catalog = view.catalog
    // Glance draws at most ten children of a Column, so the gaps are padding, not Spacers
    Column(modifier = GlanceModifier.fillMaxSize()) {
        BizHeader(view, s, big = true) {
            if (wide && s.updated.isNotEmpty()) {
                BizText(s.updated, size = 10.sp, color = BizColors.faint)
                Spacer(GlanceModifier.width(2.dp))
            }
        }
        Gap(6) { Balance(view, s, size = 26.sp) }
        if (!unlocked) {
            TodayLine(view, s)
            BizLockedPanel(catalog, GlanceModifier.padding(top = 8.dp).defaultWeight().fillMaxWidth(), compact = false)
        } else {
            Gap(6) { PeriodSegments(view, s) }
            Gap(6) { FlowStats(view, s.period(view.period), changes = true) }
            Gap(6) { InsightLine(view, s.insights, lines = 2) }
            if (roomForChart) {
                FlowChart(
                    view, s,
                    // Everything else on the card, measured: see the gaps and parts above and below
                    reservedHeight = (if (roomForList) 364f else 284f) - (if (s.canAdd) 0f else 42f),
                    withAxis = true,
                    modifier = GlanceModifier.padding(top = 8.dp).defaultWeight().fillMaxWidth(),
                )
            } else {
                Spacer(GlanceModifier.defaultWeight())
            }
            if (roomForList) {
                Gap(6) {
                    RowsList(
                        catalog?.text(if (s.isBusiness) "booksTitle" else "recentTitle").orEmpty(),
                        s.rows,
                        max = 3,
                    )
                }
            }
        }
        if (s.canAdd) Gap(6) { FlowPills(view, s) }
    }
}

/** [content] the full width, [top] dp below what comes before it. */
@Composable
private fun Gap(top: Int, content: @Composable () -> Unit) {
    Box(modifier = GlanceModifier.fillMaxWidth().padding(top = top.dp)) { content() }
}
