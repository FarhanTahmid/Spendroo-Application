package com.spendroo.app.widget.business

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowInsets
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import com.spendroo.app.MainActivity
import com.spendroo.app.R
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Asks which business (business widget) or cashbook (cashbook widget) one copy shows: when it is
 * placed, when the user picks Reconfigure, and when the widget's "Choose" or "No longer available"
 * card is tapped. It lists what the app last stored (BizKeys.CATALOG), so it opens at once without
 * starting Flutter. A business widget with only one business to show takes it without asking.
 */
class WidgetPickerActivity : Activity() {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        appWidgetId = intent?.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            ?: AppWidgetManager.INVALID_APPWIDGET_ID
        // Backing out of the first placement leaves no empty widget behind
        setResult(RESULT_CANCELED, result())
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return finish()

        val provider = AppWidgetManager.getInstance(this).getAppWidgetInfo(appWidgetId)?.provider?.className
        val business = provider != CashbookWidgetReceiver::class.java.name
        val preferences = HomeWidgetPlugin.getData(this)
        val catalog = BizCatalog.parse(preferences.getString(BizKeys.CATALOG, null))
        val current = preferences.getString(BizKeys.target(appWidgetId), null)

        if (catalog == null || !catalog.signedIn) return showOpenApp(catalog)
        if (business && current == null && catalog.businesses.size == 1) return choose(catalog.businesses.single().id)
        show(catalog, business, current)
    }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }

    private fun result() = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)

    private fun choose(id: String) {
        HomeWidgetPlugin.getData(this).edit()
            .putString(BizKeys.target(appWidgetId), id)
            .remove(BizKeys.insight(appWidgetId))
            .commit()
        setResult(RESULT_OK, result())
        BizWidgets.targetsChanged(applicationContext)
        scope.launch {
            runCatching { BizWidgets.refresh(applicationContext, appWidgetId) }
            finish()
        }
    }

    /** Nothing to list yet: the widget is placed anyway, and the app fills it once opened. */
    private fun showOpenApp(catalog: BizCatalog?) {
        val page = page()
        page.addView(title(getString(R.string.widget_fallback_title)))
        page.addView(body(catalog?.text("signInBody")?.ifEmpty { null } ?: getString(R.string.widget_biz_open_first)))
        page.addView(row(getString(R.string.widget_biz_open), null, primary = true) {
            setResult(RESULT_OK, result())
            startActivity(Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            finish()
        })
    }

    private fun show(catalog: BizCatalog, business: Boolean, current: String?) {
        val page = page()
        page.addView(title(catalog.text(if (business) "chooseBusiness" else "chooseBook")))
        if (catalog.businesses.isEmpty()) {
            page.addView(body(catalog.text("pickerEmpty")))
            return
        }
        for (each in catalog.businesses) {
            if (business) {
                page.addView(row(each.name, each.detail, primary = each.id == current) { choose(each.id) })
                continue
            }
            page.addView(section(each.name))
            if (each.books.isEmpty()) page.addView(body(catalog.text("pickerBooksEmpty")))
            for (book in each.books) {
                page.addView(row(book.name, book.detail, primary = book.id == current) { choose(book.id) })
            }
        }
    }

    // ---------------------------------------------------------------- views

    private fun dp(value: Int): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value.toFloat(), resources.displayMetrics).toInt()

    /** The ledger-green page the rows go on. */
    private fun page(): LinearLayout {
        window.statusBarColor = INK
        window.navigationBarColor = INK
        val list = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(28), dp(20), dp(28))
        }
        setContentView(ScrollView(this).apply {
            setBackgroundColor(INK)
            isFillViewport = true
            addView(list, LinearLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT))
            // Android 15 draws the page under the status and navigation bars: keep the rows clear of them
            setOnApplyWindowInsetsListener { view, insets ->
                val (top, bottom) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    insets.getInsets(WindowInsets.Type.systemBars()).let { it.top to it.bottom }
                } else {
                    @Suppress("DEPRECATION")
                    insets.systemWindowInsetTop to insets.systemWindowInsetBottom
                }
                view.setPadding(0, top, 0, bottom)
                insets
            }
        })
        return list
    }

    private fun title(text: String) = TextView(this).apply {
        this.text = text
        setTextColor(Color.WHITE)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f)
        typeface = Typeface.DEFAULT_BOLD
        setPadding(0, 0, 0, dp(16))
    }

    private fun section(text: String) = TextView(this).apply {
        this.text = text
        setTextColor(GOLD)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
        typeface = Typeface.DEFAULT_BOLD
        setPadding(dp(4), dp(14), 0, dp(6))
    }

    private fun body(text: String) = TextView(this).apply {
        this.text = text
        setTextColor(MUTED)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
        setPadding(dp(4), 0, 0, dp(12))
    }

    /** A tappable card: gold when it is the current choice (or the only action). */
    private fun row(name: String, detail: String?, primary: Boolean, onTap: () -> Unit): View =
        LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_VERTICAL
            minimumHeight = dp(56)
            setPadding(dp(16), dp(12), dp(16), dp(12))
            background = GradientDrawable().apply {
                cornerRadius = dp(14).toFloat()
                setColor(if (primary) GOLD else CARD)
            }
            isClickable = true
            isFocusable = true
            setOnClickListener { onTap() }
            addView(TextView(context).apply {
                text = name
                setTextColor(if (primary) INK else Color.WHITE)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
                typeface = Typeface.DEFAULT_BOLD
            })
            if (!detail.isNullOrEmpty()) {
                addView(TextView(context).apply {
                    text = detail
                    setTextColor(if (primary) INK_SOFT else MUTED)
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                })
            }
            layoutParams = LinearLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT).apply { bottomMargin = dp(10) }
        }

    private companion object {
        const val INK = 0xFF0A3730.toInt()
        const val CARD = 0x1FFFFFFF
        const val GOLD = 0xFFF5B530.toInt()
        const val MUTED = 0xB8FFFFFF.toInt()
        const val INK_SOFT = 0xB306261F.toInt()
    }
}
