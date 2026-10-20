package com.spendroo.app.widget.business

import android.content.Context
import android.net.Uri
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
import com.spendroo.app.widget.SpendrooWidget
import com.spendroo.app.widget.business.ui.BizContent
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver
import es.antonborri.home_widget.HomeWidgetPlugin
import java.time.LocalDate

/** Everything one copy of a business widget is drawn from. */
data class BizView(
    /** The business widget, or the cashbook one. */
    val business: Boolean,
    val appWidgetId: Int,
    /** Null until the app has been opened since it was installed. */
    val catalog: BizCatalog?,
    /** The business or book this copy shows; null until one is picked. */
    val target: String?,
    /** Null when nothing is stored for [target]. */
    val snapshot: BizSnapshot?,
    val period: BizPeriodKind,
    /** Which insight to show, before wrapping round. */
    val insight: Int,
    val hidden: Boolean,
)

/**
 * A business or cashbook widget. Each copy shows the business or book picked for it
 * (WidgetPickerActivity), from the snapshots the app stores (BizKeys), and keeps its own period
 * and insight; the eye is shared with the personal widget.
 */
abstract class BizWidget(private val business: Boolean) : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    private val sizes = BizSize.breakpoints.map { (width, height) -> DpSize(width.dp, height.dp) }.toSet()

    override val sizeMode = SizeMode.Responsive(sizes)

    override val previewSizeMode = SizeMode.Responsive(sizes)

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(id)
        provideContent {
            val preferences = currentState<HomeWidgetGlanceState>().preferences
            val catalog = BizCatalog.parse(preferences.getString(BizKeys.CATALOG, null))
            // With only one business (or book) to show, a copy shows it without being asked
            val target = preferences.getString(BizKeys.target(appWidgetId), null) ?: catalog?.onlyChoice(business)
            val snapshot = target
                ?.let { preferences.getString(if (business) BizKeys.business(it) else BizKeys.book(it), null) }
                ?.let { BizSnapshot.parse(it) }
                ?.resolveFor(LocalDate.now().toString(), catalog?.text("thisMonth").orEmpty())
            BizContent(
                BizView(
                    business = business,
                    appWidgetId = appWidgetId,
                    catalog = catalog,
                    target = target,
                    snapshot = snapshot,
                    period = BizPeriodKind.from(preferences.getString(BizKeys.period(appWidgetId), null)),
                    insight = preferences.getInt(BizKeys.insight(appWidgetId), 0),
                    hidden = preferences.getBoolean(SpendrooWidget.HIDE_AMOUNTS, false),
                ),
            )
        }
    }

    /** What the widget picker shows on Android 15 and later: the widget filled with sample figures. */
    override suspend fun providePreview(context: Context, widgetCategory: Int) {
        provideContent { BizContent(BizSamples.preview(business, LocalDate.now())) }
    }
}

class BusinessWidget : BizWidget(business = true)

class CashbookWidget : BizWidget(business = false)

/** Clears what one copy kept for itself once it is removed from the home screen. */
private fun forget(context: Context, appWidgetIds: IntArray) {
    val editor = HomeWidgetPlugin.getData(context).edit()
    for (id in appWidgetIds) {
        editor.remove(BizKeys.target(id)).remove(BizKeys.period(id)).remove(BizKeys.insight(id))
    }
    editor.apply()
    BizWidgets.targetsChanged(context)
}

class BusinessWidgetReceiver : HomeWidgetGlanceWidgetReceiver<BusinessWidget>() {
    override val glanceAppWidget = BusinessWidget()

    override fun previewFingerprint(context: Context): String = "biz-sample-v1"

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        forget(context, appWidgetIds)
    }
}

class CashbookWidgetReceiver : HomeWidgetGlanceWidgetReceiver<CashbookWidget>() {
    override val glanceAppWidget = CashbookWidget()

    override fun previewFingerprint(context: Context): String = "book-sample-v1"

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        forget(context, appWidgetIds)
    }
}

object BizWidgets {
    /**
     * A copy was given a business or book, or removed: the app, without opening (bizWidgetCallback
     * in biz_widget_background.dart), tells the server which changes this phone wants silent pushes for.
     */
    fun targetsChanged(context: Context) {
        runCatching {
            HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("spendroo-widget://targets")).send()
        }
    }

    /** Redraws one copy, whichever of the two widgets it is, from what is stored now. */
    suspend fun refresh(context: Context, id: GlanceId) {
        val manager = GlanceAppWidgetManager(context)
        val widget: BizWidget = if (id in manager.getGlanceIds(BusinessWidget::class.java)) BusinessWidget() else CashbookWidget()
        // The state is read through the definition, so it is renewed before the redraw
        updateAppWidgetState(context, widget.stateDefinition, id) { it }
        widget.update(context, id)
    }

    suspend fun refreshAll(context: Context) {
        val manager = GlanceAppWidgetManager(context)
        for (widget in listOf(BusinessWidget(), CashbookWidget())) {
            for (id in manager.getGlanceIds(widget.javaClass)) {
                updateAppWidgetState(context, widget.stateDefinition, id) { it }
                widget.update(context, id)
            }
        }
    }

    /** Redraws the copy with [appWidgetId], after the picker chose what it shows. */
    suspend fun refresh(context: Context, appWidgetId: Int) {
        refresh(context, GlanceAppWidgetManager(context).getGlanceIdBy(appWidgetId))
    }

    /** A per-copy setting, written before the redraw. */
    internal suspend fun edit(context: Context, id: GlanceId, change: (Int, android.content.SharedPreferences.Editor) -> Unit) {
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(id)
        val editor = HomeWidgetPlugin.getData(context).edit()
        change(appWidgetId, editor)
        editor.commit()
        refresh(context, id)
    }
}

/** A tap on one of the period switch's segments: shows that period on this copy only. */
class SetPeriodAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val period = BizPeriodKind.from(parameters[PERIOD])
        BizWidgets.edit(context, glanceId) { id, editor -> editor.putString(BizKeys.period(id), period.name) }
    }

    companion object {
        val PERIOD = ActionParameters.Key<String>("period")
    }
}

/** The 4x2's period chip: Today, then 7 days, then the month, then round again. */
class CyclePeriodAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        BizWidgets.edit(context, glanceId) { id, editor ->
            val current = BizPeriodKind.from(HomeWidgetPlugin.getData(context).getString(BizKeys.period(id), null))
            editor.putString(BizKeys.period(id), current.next().name)
        }
    }
}

/** The arrow beside an insight: the next piece of advice, round again after the last. */
class NextInsightAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        BizWidgets.edit(context, glanceId) { id, editor ->
            val current = HomeWidgetPlugin.getData(context).getInt(BizKeys.insight(id), 0)
            // Kept small: the layout wraps it round however many insights there are
            editor.putInt(BizKeys.insight(id), (current + 1) % 1000)
        }
    }
}
