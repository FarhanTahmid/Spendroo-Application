package com.spendroo.app.widget.ui

import android.net.Uri
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
import androidx.glance.action.Action
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.spendroo.app.MainActivity
import com.spendroo.app.R
import com.spendroo.app.widget.PaceTone
import com.spendroo.app.widget.PrivacyToggleAction
import com.spendroo.app.widget.WidgetColors
import com.spendroo.app.widget.WidgetStat
import es.antonborri.home_widget.actionStartActivity

/** Opens the app at a widget link (WidgetLinks). */
@Composable
fun open(link: String): Action = actionStartActivity<MainActivity>(LocalContext.current, Uri.parse(link))

/** The Spendroo wallet on a small white tile, so the navy mark shows on the navy card. */
@Composable
fun BrandMark(size: Dp = 22.dp) {
    Box(
        modifier = GlanceModifier.size(size).background(ImageProvider(R.drawable.widget_mark_tile)),
        contentAlignment = Alignment.Center,
    ) {
        Image(
            provider = ImageProvider(R.drawable.splash_mark),
            contentDescription = null,
            modifier = GlanceModifier.size(size - 4.dp),
        )
    }
}

@Composable
fun Caption(text: String, size: TextUnit = 11.sp, color: ColorProvider = WidgetColors.muted, bold: Boolean = false) {
    Text(
        text = text,
        maxLines = 1,
        style = TextStyle(
            color = color,
            fontSize = size,
            fontWeight = if (bold) FontWeight.Bold else FontWeight.Medium,
        ),
    )
}

/** A figure in money: bold, white, never wrapped. */
@Composable
fun Amount(text: String, size: TextUnit, color: ColorProvider = WidgetColors.text) {
    Text(text = text, maxLines = 1, style = TextStyle(color = color, fontSize = size, fontWeight = FontWeight.Bold))
}

/** "Safe ৳600/day" in green, "Over budget" in red, an average in plain white. */
@Composable
fun PaceChip(text: String, tone: PaceTone) {
    val (background, color) = when (tone) {
        PaceTone.SAFE -> R.drawable.widget_chip_safe to WidgetColors.mint
        PaceTone.OVER -> R.drawable.widget_chip_over to WidgetColors.red
        PaceTone.AVERAGE -> R.drawable.widget_chip_neutral to WidgetColors.muted
    }
    Box(modifier = GlanceModifier.background(ImageProvider(background)).padding(horizontal = 8.dp, vertical = 3.dp)) {
        Caption(text, size = 11.sp, color = color, bold = true)
    }
}

/** A labelled button: gold for the main one, glass for the rest. At least 40dp tall. */
@Composable
fun ActionPill(
    label: String,
    icon: Int,
    link: String,
    primary: Boolean,
    modifier: GlanceModifier = GlanceModifier,
) {
    val color = if (primary) WidgetColors.navy else WidgetColors.text
    Row(
        modifier = modifier
            .height(40.dp)
            .background(ImageProvider(if (primary) R.drawable.widget_pill_gold else R.drawable.widget_pill_glass))
            .padding(horizontal = 10.dp)
            .clickable(open(link)),
        verticalAlignment = Alignment.CenterVertically,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Image(
            provider = ImageProvider(icon),
            contentDescription = null,
            colorFilter = ColorFilter.tint(color),
            modifier = GlanceModifier.size(16.dp),
        )
        Spacer(GlanceModifier.width(5.dp))
        Text(text = label, maxLines = 1, style = TextStyle(color = color, fontSize = 13.sp, fontWeight = FontWeight.Bold))
    }
}

/** A round icon button: gold adds an expense, mint adds income. */
@Composable
fun CircleAction(icon: Int, link: String, description: String, gold: Boolean, size: Dp = 40.dp) {
    Box(
        modifier = GlanceModifier
            .size(size)
            .background(ImageProvider(if (gold) R.drawable.widget_circle_gold else R.drawable.widget_circle_mint))
            .clickable(open(link)),
        contentAlignment = Alignment.Center,
    ) {
        Image(
            provider = ImageProvider(icon),
            contentDescription = description,
            colorFilter = ColorFilter.tint(WidgetColors.navy),
            modifier = GlanceModifier.size(size / 2),
        )
    }
}

/** A caption over a figure. */
@Composable
fun StatCell(stat: WidgetStat, modifier: GlanceModifier = GlanceModifier, valueColor: ColorProvider = WidgetColors.text) {
    Column(modifier = modifier) {
        Caption(stat.label, size = 10.sp)
        Spacer(GlanceModifier.height(1.dp))
        Amount(stat.value, size = 14.sp, color = valueColor)
    }
}

/** Hides or shows every amount on the widget, without opening the app. */
@Composable
fun EyeToggle(hidden: Boolean, description: String) {
    Box(
        modifier = GlanceModifier.size(32.dp).clickable(actionRunCallback<PrivacyToggleAction>()),
        contentAlignment = Alignment.Center,
    ) {
        Image(
            provider = ImageProvider(if (hidden) R.drawable.ic_widget_eye_off else R.drawable.ic_widget_eye),
            contentDescription = description,
            colorFilter = ColorFilter.tint(WidgetColors.muted),
            modifier = GlanceModifier.size(18.dp),
        )
    }
}
