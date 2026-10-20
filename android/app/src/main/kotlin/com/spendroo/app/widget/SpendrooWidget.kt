package com.spendroo.app.widget

import android.content.Context
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.currentState
import com.spendroo.app.widget.business.BizWidgets
import com.spendroo.app.widget.ui.SpendrooContent
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver
import es.antonborri.home_widget.HomeWidgetPlugin
import java.time.LocalDate

/**
 * The Spendroo home-screen widget: today's spending, the month, and one-tap adding. It draws
 * the snapshot the app last stored (WidgetSnapshot.KEY) and picks a layout per WidgetSize.
 */
class SpendrooWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    private val sizes = WidgetSize.breakpoints.map { (width, height) -> DpSize(width.dp, height.dp) }.toSet()

    override val sizeMode = SizeMode.Responsive(sizes)

    /** The picker's preview gets the layout for the space it shows, not the 2x1 one stretched. */
    override val previewSizeMode = SizeMode.Responsive(sizes)

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val preferences = currentState<HomeWidgetGlanceState>().preferences
            val snapshot = WidgetSnapshot.parse(preferences.getString(WidgetSnapshot.KEY, null))
                ?.resolveFor(LocalDate.now().toString())
            SpendrooContent(snapshot, hidden = preferences.getBoolean(HIDE_AMOUNTS, false))
        }
    }

    /** What the widget picker shows on Android 15 and later: the widget filled with sample figures. */
    override suspend fun providePreview(context: Context, widgetCategory: Int) {
        provideContent { SpendrooContent(WidgetSamples.preview(LocalDate.now().toString()), hidden = false) }
    }

    companion object {
        /** Whether the user hid the amounts; one choice for every copy of the widget. */
        const val HIDE_AMOUNTS = "spendroo_hide_amounts"

        /** Redraws every copy of the widget from what is stored now. */
        suspend fun refreshAll(context: Context) {
            val widget = SpendrooWidget()
            for (id in GlanceAppWidgetManager(context).getGlanceIds(SpendrooWidget::class.java)) {
                // The state is read through the definition, so it is renewed before the redraw
                updateAppWidgetState(context, widget.stateDefinition, id) { it }
                widget.update(context, id)
            }
        }
    }
}

class SpendrooWidgetReceiver : HomeWidgetGlanceWidgetReceiver<SpendrooWidget>() {
    override val glanceAppWidget = SpendrooWidget()

    /** Change it when the sample preview changes, so the picker is sent the new one. */
    override fun previewFingerprint(context: Context): String = "sample-v2"
}

/** The eye on a widget: hides or shows every amount on every Spendroo widget, without opening the app. */
class PrivacyToggleAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val preferences = HomeWidgetPlugin.getData(context)
        val hidden = preferences.getBoolean(SpendrooWidget.HIDE_AMOUNTS, false)
        preferences.edit().putBoolean(SpendrooWidget.HIDE_AMOUNTS, !hidden).commit()
        SpendrooWidget.refreshAll(context)
        // One choice for every Spendroo widget, the business ones too
        BizWidgets.refreshAll(context)
    }
}
