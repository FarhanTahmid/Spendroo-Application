package com.spendroo.app.widget.business.ui

import android.content.Intent
import android.net.Uri
import android.appwidget.AppWidgetManager
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.Action
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.spendroo.app.R
import com.spendroo.app.widget.WidgetLinks
import com.spendroo.app.widget.business.BizCatalog
import com.spendroo.app.widget.business.BizColors
import com.spendroo.app.widget.business.BizInsight
import com.spendroo.app.widget.business.BizPeriod
import com.spendroo.app.widget.business.BizPeriodKind
import com.spendroo.app.widget.business.BizRow
import com.spendroo.app.widget.business.BizSnapshot
import com.spendroo.app.widget.business.BizTone
import com.spendroo.app.widget.business.BizView
import com.spendroo.app.widget.business.CyclePeriodAction
import com.spendroo.app.widget.business.InOutChartRenderer
import com.spendroo.app.widget.business.NextInsightAction
import com.spendroo.app.widget.business.SetPeriodAction
import com.spendroo.app.widget.business.WidgetPickerActivity
import com.spendroo.app.widget.ui.EyeToggle
import com.spendroo.app.widget.ui.open

/** Where tapping the card leads: the business, or the book within its business. */
fun cardLink(s: BizSnapshot): String =
    if (s.isBusiness) WidgetLinks.business(s.workspaceId) else WidgetLinks.book(s.id, s.workspaceId)

/** Cash in or out from this widget: straight into the book, or the business's book chooser. */
fun addLink(s: BizSnapshot, type: String): String =
    if (s.isBusiness) WidgetLinks.businessAdd(s.workspaceId, type) else WidgetLinks.bookAdd(s.id, s.workspaceId, type)

/** Opens the picker for one copy of a widget. The link makes each copy's intent its own. */
@Composable
fun pickAction(appWidgetId: Int): Action {
    val context = LocalContext.current
    val intent = Intent(context, WidgetPickerActivity::class.java)
        .setData(Uri.parse("spendroo-widget://pick/$appWidgetId"))
        .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
    return actionStartActivity(intent)
}

@Composable
fun BizText(
    text: String,
    size: TextUnit,
    color: ColorProvider = BizColors.text,
    bold: Boolean = false,
    lines: Int = 1,
    center: Boolean = false,
    modifier: GlanceModifier = GlanceModifier,
) {
    Text(
        text = text,
        maxLines = lines,
        modifier = modifier,
        style = TextStyle(
            color = color,
            fontSize = size,
            fontWeight = if (bold) FontWeight.Bold else FontWeight.Medium,
            textAlign = if (center) TextAlign.Center else TextAlign.Start,
        ),
    )
}

/** The store or book glyph on a glass tile, heading the widget. */
@Composable
fun KindTile(business: Boolean, size: Dp = 24.dp) {
    Box(
        modifier = GlanceModifier.size(size).background(ImageProvider(R.drawable.widget_biz_tile)),
        contentAlignment = Alignment.Center,
    ) {
        Image(
            provider = ImageProvider(if (business) R.drawable.ic_widget_store else R.drawable.ic_widget_book),
            contentDescription = null,
            colorFilter = ColorFilter.tint(BizColors.gold),
            modifier = GlanceModifier.size(size * 0.62f),
        )
    }
}

/** The tile, the name and its subtitle, then whatever the size adds and the eye. */
@Composable
fun BizHeader(
    view: BizView,
    s: BizSnapshot,
    modifier: GlanceModifier = GlanceModifier,
    big: Boolean = false,
    trailing: @Composable () -> Unit = {},
) {
    Row(modifier = modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        KindTile(view.business, if (big) 28.dp else 22.dp)
        Spacer(GlanceModifier.width(8.dp))
        Column(modifier = GlanceModifier.defaultWeight()) {
            if (big || s.isBusiness || s.subtitle.isBlank()) {
                BizText(s.name, size = if (big) 14.sp else 12.sp, bold = true)
                if (big && s.subtitle.isNotEmpty()) BizText(s.subtitle, size = 10.sp, color = BizColors.muted)
            } else {
                // No room for a second line: the book, then its business, which gives way first
                Row(verticalAlignment = Alignment.CenterVertically) {
                    BizText(s.name, size = 12.sp, bold = true)
                    BizText(" · ${s.subtitle}", size = 11.sp, color = BizColors.muted, modifier = GlanceModifier.defaultWeight())
                }
            }
        }
        trailing()
        EyeToggle(view.hidden, view.catalog?.text(if (view.hidden) "show" else "hide").orEmpty())
    }
}

@Composable
fun Balance(view: BizView, s: BizSnapshot, size: TextUnit, withLabel: Boolean = true) {
    Column {
        if (withLabel) BizText(view.catalog?.text("balance").orEmpty(), size = 10.sp, color = BizColors.muted)
        BizText(s.balance, size = size, bold = true, color = if (s.balanceNegative) BizColors.coral else BizColors.text)
    }
}

/** A round Cash in (green) or Cash out (coral) button. */
@Composable
fun FlowCircle(s: BizSnapshot, cashIn: Boolean, description: String, size: Dp = 36.dp) {
    Box(
        modifier = GlanceModifier
            .size(size)
            .background(ImageProvider(if (cashIn) R.drawable.widget_circle_mint else R.drawable.widget_circle_coral))
            .clickable(open(addLink(s, if (cashIn) "cash_in" else "cash_out"))),
        contentAlignment = Alignment.Center,
    ) {
        Image(
            provider = ImageProvider(if (cashIn) R.drawable.ic_widget_income else R.drawable.ic_widget_expense),
            contentDescription = description,
            colorFilter = ColorFilter.tint(BizColors.ink),
            modifier = GlanceModifier.size(size / 2),
        )
    }
}

/** Both round buttons, when the user may add here. */
@Composable
fun FlowCircles(view: BizView, s: BizSnapshot, size: Dp = 36.dp) {
    if (!s.canAdd) return
    Row(verticalAlignment = Alignment.CenterVertically) {
        FlowCircle(s, cashIn = true, description = view.catalog?.text("cashIn").orEmpty(), size = size)
        Spacer(GlanceModifier.width(8.dp))
        FlowCircle(s, cashIn = false, description = view.catalog?.text("cashOut").orEmpty(), size = size)
    }
}

/** Labelled Cash in / Cash out buttons across the foot of the bigger sizes. */
@Composable
fun FlowPills(view: BizView, s: BizSnapshot) {
    if (!s.canAdd) return
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        for (cashIn in listOf(true, false)) {
            if (!cashIn) Spacer(GlanceModifier.width(8.dp))
            Row(
                modifier = GlanceModifier
                    .defaultWeight()
                    .height(36.dp)
                    .background(ImageProvider(if (cashIn) R.drawable.widget_pill_mint else R.drawable.widget_pill_coral))
                    .clickable(open(addLink(s, if (cashIn) "cash_in" else "cash_out"))),
                verticalAlignment = Alignment.CenterVertically,
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Image(
                    provider = ImageProvider(if (cashIn) R.drawable.ic_widget_income else R.drawable.ic_widget_expense),
                    contentDescription = null,
                    colorFilter = ColorFilter.tint(BizColors.ink),
                    modifier = GlanceModifier.size(16.dp),
                )
                Spacer(GlanceModifier.width(5.dp))
                BizText(view.catalog?.text(if (cashIn) "cashIn" else "cashOut").orEmpty(), size = 13.sp, color = BizColors.ink, bold = true)
            }
        }
    }
}

/** Today's money in and out on one line: "+৳8,200  -৳3,150". */
@Composable
fun TodayLine(view: BizView, s: BizSnapshot, size: TextUnit = 11.sp) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        BizText(view.catalog?.text("today").orEmpty(), size = size, color = BizColors.faint)
        Spacer(GlanceModifier.width(6.dp))
        BizText("↓ ${s.today.inText}", size = size, color = BizColors.mint, bold = true)
        Spacer(GlanceModifier.width(6.dp))
        BizText("↑ ${s.today.outText}", size = size, color = BizColors.coral, bold = true)
    }
}

/** The 4x2's period: one chip that moves on to the next period when tapped. */
@Composable
fun PeriodChip(view: BizView, period: BizPeriod) {
    Row(
        modifier = GlanceModifier
            .background(ImageProvider(R.drawable.widget_segment_track))
            .padding(start = 10.dp, end = 4.dp, top = 4.dp, bottom = 4.dp)
            .clickable(actionRunCallback<CyclePeriodAction>()),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        BizText(period.label, size = 11.sp, color = BizColors.gold, bold = true)
        Image(
            provider = ImageProvider(R.drawable.ic_widget_next),
            contentDescription = view.catalog?.text("period"),
            colorFilter = ColorFilter.tint(BizColors.gold),
            modifier = GlanceModifier.size(14.dp),
        )
    }
}

/** The bigger sizes' period switch: Today, 7 days, the month, the chosen one in gold. */
@Composable
fun PeriodSegments(view: BizView, s: BizSnapshot) {
    Row(
        modifier = GlanceModifier.fillMaxWidth().background(ImageProvider(R.drawable.widget_segment_track)).padding(3.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        for (kind in BizPeriodKind.entries) {
            val chosen = kind == view.period
            Box(
                modifier = GlanceModifier
                    .defaultWeight()
                    .height(24.dp)
                    .let { if (chosen) it.background(ImageProvider(R.drawable.widget_segment_on)) else it }
                    .clickable(actionRunCallback<SetPeriodAction>(actionParametersOf(SetPeriodAction.PERIOD to kind.name))),
                contentAlignment = Alignment.Center,
            ) {
                BizText(
                    s.period(kind).label,
                    size = 11.sp,
                    bold = chosen,
                    center = true,
                    color = if (chosen) BizColors.ink else BizColors.muted,
                )
            }
        }
    }
}

/** Cash in, cash out and net for [period]; with [changes], how in and out moved and against what. */
@Composable
fun FlowStats(view: BizView, period: BizPeriod, changes: Boolean, valueSize: TextUnit = 14.sp) {
    val catalog = view.catalog
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            Stat(catalog?.text("cashIn").orEmpty(), period.inText, BizColors.mint, if (changes) period.inChange else null, period.inGood, valueSize)
            Stat(catalog?.text("cashOut").orEmpty(), period.outText, BizColors.coral, if (changes) period.outChange else null, period.outGood, valueSize)
            Stat(
                catalog?.text("net").orEmpty(), period.net,
                if (period.netNegative) BizColors.coral else BizColors.text, null, true, valueSize,
            )
        }
        if (changes && (period.inChange != null || period.outChange != null) && period.compare.isNotEmpty()) {
            BizText(period.compare, size = 9.sp, color = BizColors.faint)
        }
    }
}

@Composable
private fun androidx.glance.layout.RowScope.Stat(
    label: String,
    value: String,
    color: ColorProvider,
    change: String?,
    good: Boolean,
    valueSize: TextUnit,
) {
    Column(modifier = GlanceModifier.defaultWeight()) {
        BizText(label, size = 10.sp, color = BizColors.muted)
        BizText(value, size = valueSize, color = color, bold = true)
        if (change != null) BizText(change, size = 9.sp, color = if (good) BizColors.mint else BizColors.coral, bold = true)
    }
}

/** One piece of advice on a tinted panel; the arrow moves on to the next when there are more. */
@Composable
fun InsightLine(view: BizView, insights: List<BizInsight>, lines: Int = 1) {
    if (insights.isEmpty()) return
    val insight = insights[Math.floorMod(view.insight, insights.size)]
    val (panel, tint) = when (insight.tone) {
        BizTone.WARN -> R.drawable.widget_insight_warn to BizColors.coral
        BizTone.GOOD -> R.drawable.widget_insight_good to BizColors.mint
        BizTone.INFO -> R.drawable.widget_insight_info to BizColors.gold
    }
    Row(
        modifier = GlanceModifier.fillMaxWidth().background(ImageProvider(panel)).padding(start = 8.dp, top = 5.dp, bottom = 5.dp, end = 2.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Image(
            provider = ImageProvider(R.drawable.ic_widget_spark),
            contentDescription = null,
            colorFilter = ColorFilter.tint(tint),
            modifier = GlanceModifier.size(14.dp),
        )
        Spacer(GlanceModifier.width(6.dp))
        BizText(insight.text, size = 11.sp, lines = lines, modifier = GlanceModifier.defaultWeight())
        if (insights.size > 1) {
            Box(
                modifier = GlanceModifier.size(28.dp).clickable(actionRunCallback<NextInsightAction>()),
                contentAlignment = Alignment.Center,
            ) {
                Image(
                    provider = ImageProvider(R.drawable.ic_widget_next),
                    contentDescription = view.catalog?.text("nextInsight"),
                    colorFilter = ColorFilter.tint(BizColors.muted),
                    modifier = GlanceModifier.size(18.dp),
                )
            }
        } else {
            Spacer(GlanceModifier.width(6.dp))
        }
    }
}

/**
 * The fortnight's money in (up) and out (down), with day labels when [withAxis]. [reservedHeight]
 * is what the layout puts around it, so the bitmap is drawn at about the size it fills.
 */
@Composable
fun FlowChart(view: BizView, s: BizSnapshot, reservedHeight: Float, withAxis: Boolean, modifier: GlanceModifier) {
    val context = LocalContext.current
    val size = LocalSize.current
    if (!s.hasActivity) {
        Box(modifier = modifier, contentAlignment = Alignment.Center) {
            // A book with no entries at all is told how to start; otherwise the fortnight was just quiet
            val key = if (s.rows.isEmpty()) "noEntries" else "quietChart"
            BizText(view.catalog?.text(key).orEmpty(), size = 11.sp, color = BizColors.muted, lines = 2, center = true)
        }
        return
    }
    Column(modifier = modifier) {
        val density = context.resources.displayMetrics.density
        val widthDp = size.width.value - 28
        val heightDp = (size.height.value - reservedHeight).coerceAtLeast(32f)
        val chart = InOutChartRenderer.render(s.dailyIn, s.dailyOut, (widthDp * density).toInt(), (heightDp * density).toInt(), density)
        Image(
            provider = ImageProvider(chart),
            // The bars show shape, not amounts, so they stay when amounts are hidden
            contentDescription = null,
            contentScale = ContentScale.FillBounds,
            modifier = GlanceModifier.defaultWeight().fillMaxWidth(),
        )
        val axis = s.axis
        if (withAxis && axis.size == 3) {
            Spacer(GlanceModifier.height(2.dp))
            Row(modifier = GlanceModifier.fillMaxWidth()) {
                BizText(axis[0], size = 9.sp, color = BizColors.faint)
                Spacer(GlanceModifier.defaultWeight())
                BizText(axis[1], size = 9.sp, color = BizColors.faint)
                Spacer(GlanceModifier.defaultWeight())
                BizText(axis[2], size = 9.sp, color = BizColors.faint)
            }
        }
    }
}

/** A business's books, or a book's latest entries: up to [max] lines under a caption. */
@Composable
fun RowsList(title: String, rows: List<BizRow>, max: Int) {
    if (rows.isEmpty()) return
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        BizText(title, size = 10.sp, color = BizColors.muted)
        for (row in rows.take(max)) {
            Row(
                modifier = GlanceModifier.fillMaxWidth().height(24.dp)
                    .let { m -> row.link?.let { m.clickable(open(it)) } ?: m },
                verticalAlignment = Alignment.CenterVertically,
            ) {
                BizText(row.title, size = 12.sp, modifier = GlanceModifier.defaultWeight())
                row.detail?.let {
                    BizText(it, size = 10.sp, color = BizColors.faint)
                    Spacer(GlanceModifier.width(8.dp))
                }
                BizText(row.amount, size = 12.sp, bold = true, color = if (row.negative) BizColors.coral else BizColors.text)
            }
        }
    }
}

/** On a 4x2 under a plan without the big sizes: one line that leads to the plans. */
@Composable
fun BizLockStrip(catalog: BizCatalog?) {
    Row(
        modifier = GlanceModifier.fillMaxWidth().height(34.dp)
            .background(ImageProvider(R.drawable.widget_panel))
            .padding(horizontal = 10.dp)
            .clickable(open(WidgetLinks.PLAN)),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        LockGlyph(13)
        Spacer(GlanceModifier.width(8.dp))
        BizText(catalog?.text("unlockTitle").orEmpty(), size = 11.sp, modifier = GlanceModifier.defaultWeight())
        BizText(catalog?.text("unlockCta").orEmpty(), size = 11.sp, color = BizColors.gold, bold = true)
    }
}

/** In place of the charts and advice under a plan without them: what they are, and the way to them. */
@Composable
fun BizLockedPanel(catalog: BizCatalog?, modifier: GlanceModifier, compact: Boolean) {
    Column(
        modifier = modifier.background(ImageProvider(R.drawable.widget_panel)).padding(10.dp).clickable(open(WidgetLinks.PLAN)),
        verticalAlignment = Alignment.CenterVertically,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        if (!compact) {
            LockGlyph(20)
            Spacer(GlanceModifier.height(6.dp))
        }
        BizText(catalog?.text("unlockTitle").orEmpty(), size = 13.sp, bold = true, center = true)
        BizText(catalog?.text("unlockBody").orEmpty(), size = 11.sp, color = BizColors.muted, lines = if (compact) 1 else 2, center = true)
        Spacer(GlanceModifier.height(6.dp))
        Box(
            modifier = GlanceModifier.background(ImageProvider(R.drawable.widget_pill_gold)).padding(horizontal = 14.dp, vertical = 5.dp),
        ) {
            BizText(catalog?.text("unlockCta").orEmpty(), size = 12.sp, color = BizColors.ink, bold = true)
        }
    }
}

@Composable
private fun LockGlyph(size: Int) {
    Image(
        provider = ImageProvider(R.drawable.ic_widget_lock),
        contentDescription = null,
        colorFilter = ColorFilter.tint(BizColors.gold),
        modifier = GlanceModifier.size(size.dp),
    )
}
