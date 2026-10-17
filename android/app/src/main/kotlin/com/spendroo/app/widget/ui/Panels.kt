package com.spendroo.app.widget.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import com.spendroo.app.R
import com.spendroo.app.widget.SpendChartRenderer
import com.spendroo.app.widget.WidgetColors
import com.spendroo.app.widget.WidgetLinks
import com.spendroo.app.widget.WidgetSize
import com.spendroo.app.widget.WidgetSnapshot

/**
 * Nobody signed in, or the app not opened since it was installed: the mark and an invitation.
 * Before the app has written anything the words come from Android's own resources.
 */
@Composable
fun SignedOutLayout(s: WidgetSnapshot?, size: WidgetSize) {
    val context = LocalContext.current
    val title = s?.text("signInTitle")?.ifEmpty { null } ?: context.getString(R.string.widget_fallback_title)
    val body = s?.text("signInBody")?.ifEmpty { null } ?: context.getString(R.string.widget_fallback_body)
    if (size == WidgetSize.COMPACT || size == WidgetSize.STRIP) {
        Row(modifier = GlanceModifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
            BrandMark(30.dp)
            Spacer(GlanceModifier.width(10.dp))
            Column(modifier = GlanceModifier.defaultWeight()) {
                Caption(title, size = 13.sp, color = WidgetColors.text, bold = true)
                if (size == WidgetSize.STRIP) Caption(body)
            }
        }
    } else {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            BrandMark(40.dp)
            Spacer(GlanceModifier.height(10.dp))
            Centered(title, size = 15, bold = true)
            Spacer(GlanceModifier.height(2.dp))
            Centered(body, size = 12, bold = false)
        }
    }
}

/** On a 4x2 under a plan without the widget: one line that leads to the plans. */
@Composable
fun LockStrip(s: WidgetSnapshot) {
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .height(36.dp)
            .background(ImageProvider(R.drawable.widget_panel))
            .padding(horizontal = 10.dp)
            .clickable(open(WidgetLinks.PLAN)),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        LockIcon(14)
        Spacer(GlanceModifier.width(8.dp))
        Box(modifier = GlanceModifier.defaultWeight()) { Caption(s.text("unlockTitle"), size = 12.sp, color = WidgetColors.text) }
        Caption(s.text("unlockCta"), size = 12.sp, color = WidgetColors.gold, bold = true)
    }
}

/**
 * Under a plan without the widget, in place of the figures and chart: what Plus adds here, and the
 * way to it. [compact] (a 4x2) puts the lock beside the title and keeps the description to a line.
 */
@Composable
fun LockedPanel(s: WidgetSnapshot, modifier: GlanceModifier, compact: Boolean = false) {
    Column(
        modifier = modifier
            .background(ImageProvider(R.drawable.widget_panel))
            .padding(12.dp)
            .clickable(open(WidgetLinks.PLAN)),
        verticalAlignment = Alignment.CenterVertically,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        if (compact) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                LockIcon(14)
                Spacer(GlanceModifier.width(6.dp))
                Caption(s.text("unlockTitle"), size = 13.sp, color = WidgetColors.text, bold = true)
            }
            Centered(s.text("unlockBody"), size = 11, bold = false, lines = 1)
            Spacer(GlanceModifier.height(6.dp))
        } else {
            LockIcon(20)
            Spacer(GlanceModifier.height(6.dp))
            Centered(s.text("unlockTitle"), size = 14, bold = true)
            Centered(s.text("unlockBody"), size = 11, bold = false)
            Spacer(GlanceModifier.height(8.dp))
        }
        Box(
            modifier = GlanceModifier
                .background(ImageProvider(R.drawable.widget_pill_gold))
                .padding(horizontal = 14.dp, vertical = 6.dp),
        ) {
            Caption(s.text("unlockCta"), size = 12.sp, color = WidgetColors.navy, bold = true)
        }
    }
}

/**
 * The month's daily bars, with their day labels when [withAxis]; a hint before anything is spent.
 * [reservedHeight] is what the layout puts above and below it, so the bitmap is drawn at about
 * the size it fills.
 */
@Composable
fun ChartArea(s: WidgetSnapshot, hidden: Boolean, reservedHeight: Float, withAxis: Boolean, modifier: GlanceModifier) {
    val context = LocalContext.current
    val size = LocalSize.current
    if (!s.hasSpending) {
        Box(modifier = modifier, contentAlignment = Alignment.Center) {
            Centered(s.text("emptyChart"), size = 11, bold = false)
        }
        return
    }
    Column(modifier = modifier) {
        val density = context.resources.displayMetrics.density
        val widthDp = size.width.value - 28
        val heightDp = (size.height.value - reservedHeight).coerceAtLeast(36f)
        val chart = SpendChartRenderer.render(s, (widthDp * density).toInt(), (heightDp * density).toInt(), density)
        Image(
            provider = ImageProvider(chart),
            // The bars show shape, not amounts, so they stay when amounts are hidden
            contentDescription = if (hidden) null else s.text("thisMonth"),
            contentScale = ContentScale.FillBounds,
            modifier = GlanceModifier.defaultWeight().fillMaxWidth(),
        )
        if (withAxis && s.axis.size == 3) {
            Spacer(GlanceModifier.height(3.dp))
            Row(modifier = GlanceModifier.fillMaxWidth()) {
                Caption(s.axis[0], size = 9.sp, color = WidgetColors.faint)
                Spacer(GlanceModifier.defaultWeight())
                Caption(s.axis[1], size = 9.sp, color = WidgetColors.faint)
                Spacer(GlanceModifier.defaultWeight())
                Caption(s.axis[2], size = 9.sp, color = WidgetColors.faint)
            }
        }
    }
}

@Composable
private fun LockIcon(size: Int) {
    Image(
        provider = ImageProvider(R.drawable.ic_widget_lock),
        contentDescription = null,
        colorFilter = ColorFilter.tint(WidgetColors.gold),
        modifier = GlanceModifier.size(size.dp),
    )
}

@Composable
private fun Centered(text: String, size: Int, bold: Boolean, lines: Int = 2) {
    Text(
        text = text,
        maxLines = lines,
        style = TextStyle(
            color = if (bold) WidgetColors.text else WidgetColors.muted,
            fontSize = size.sp,
            fontWeight = if (bold) FontWeight.Bold else FontWeight.Normal,
            textAlign = TextAlign.Center,
        ),
    )
}
