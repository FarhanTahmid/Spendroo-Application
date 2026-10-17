package com.spendroo.app.widget.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceModifier
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import com.spendroo.app.R
import com.spendroo.app.widget.WidgetLinks
import com.spendroo.app.widget.WidgetSize
import com.spendroo.app.widget.WidgetSnapshot

/**
 * The whole widget: the navy card, and the layout for the size it has been given.
 * Without a snapshot (the app not opened since install) or signed out, it invites the user in.
 */
@Composable
fun SpendrooContent(snapshot: WidgetSnapshot?, hidden: Boolean) {
    val size = LocalSize.current
    val bucket = WidgetSize.from(size.width.value, size.height.value)
    val shown = if (hidden) snapshot?.masked() else snapshot
    val tight = bucket == WidgetSize.COMPACT || bucket == WidgetSize.STRIP

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .appWidgetBackground()
            .background(ImageProvider(R.drawable.widget_background))
            .cornerRadius(R.dimen.widget_radius)
            .padding(horizontal = if (tight) 12.dp else 14.dp, vertical = if (tight) 8.dp else 14.dp)
            .clickable(open(WidgetLinks.HOME)),
    ) {
        if (shown == null || !shown.signedIn) {
            SignedOutLayout(shown, bucket)
        } else {
            when (bucket) {
                WidgetSize.COMPACT -> CompactLayout(shown)
                WidgetSize.STRIP -> StripLayout(shown, hidden)
                WidgetSize.SQUARE -> SquareLayout(shown, hidden)
                WidgetSize.WIDE -> WideLayout(shown, hidden)
                WidgetSize.LARGE -> LargeLayout(shown, hidden)
            }
        }
    }
}
