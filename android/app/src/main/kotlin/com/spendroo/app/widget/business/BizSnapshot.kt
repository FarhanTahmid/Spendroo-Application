package com.spendroo.app.widget.business

import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDate
import java.time.temporal.ChronoUnit

/** Where the app stores what the business widgets draw (lib/features/home_widget/business/biz_snapshot.dart). */
object BizKeys {
    const val CATALOG = "biz_catalog"

    fun business(workspaceId: String) = "biz_$workspaceId"

    fun book(bookId: String) = "book_$bookId"

    /** What one copy of a widget shows: a workspace id or a cashbook id, chosen in the picker. */
    fun target(appWidgetId: Int) = "biz_target_$appWidgetId"

    /** The period one copy shows (BizPeriodKind.name). */
    fun period(appWidgetId: Int) = "biz_period_$appWidgetId"

    /** Which of its insights one copy shows. */
    fun insight(appWidgetId: Int) = "biz_insight_$appWidgetId"

    /** The newest shape this code reads. */
    const val VERSION = 1
}

/** Which stretch of days the figures cover; each copy of a widget keeps its own. */
enum class BizPeriodKind { TODAY, WEEK, MONTH;

    fun next(): BizPeriodKind = entries[(ordinal + 1) % entries.size]

    companion object {
        fun from(name: String?): BizPeriodKind = entries.firstOrNull { it.name == name } ?: MONTH
    }
}

enum class BizTone { GOOD, WARN, INFO }

/** Money in, out and net over a stretch of days, with changes against the stretch before. */
data class BizPeriod(
    val label: String,
    val compare: String,
    val inText: String,
    val outText: String,
    val net: String,
    val netNegative: Boolean,
    val inChange: String?,
    val inGood: Boolean,
    val outChange: String?,
    val outGood: Boolean,
) {
    /** The same stretch with nothing in it yet: a new day, or a new month. */
    fun empty(zero: String, label: String = this.label) =
        copy(label = label, inText = zero, outText = zero, net = zero, netNegative = false, inChange = null, outChange = null)

    fun masked(mask: String) = copy(inText = mask, outText = mask, net = mask)
}

data class BizInsight(val kind: String, val text: String, val masked: String, val tone: BizTone, val until: String)

data class BizRow(val title: String, val detail: String?, val amount: String, val negative: Boolean, val link: String?)

/**
 * One business's or cashbook's figures, as the app wrote them. Every amount and word arrives
 * formatted, so nothing here knows about money or languages.
 */
data class BizSnapshot(
    /** "business" or "book". */
    val kind: String,
    val id: String,
    val workspaceId: String,
    val name: String,
    val subtitle: String,
    val date: String,
    val balance: String,
    val balanceNegative: Boolean,
    val mask: String,
    val zero: String,
    val canAdd: Boolean,
    val today: BizPeriod,
    val week: BizPeriod,
    val month: BizPeriod,
    val weekRoll: List<BizPeriod>,
    /** Money in and out on the 14 days ending [date]; index 13 is that day. */
    val dailyIn: List<Long>,
    val dailyOut: List<Long>,
    /** Day labels for those 14 days and the 6 after. */
    val dayLabels: List<String>,
    val insights: List<BizInsight>,
    val rows: List<BizRow>,
    val updated: String,
) {
    val isBusiness: Boolean get() = kind == "business"

    /** One line naming what is shown: a cashbook's name is followed by its business ([subtitle]). */
    val title: String get() = if (isBusiness) name else withBusiness(name, subtitle)

    fun period(kind: BizPeriodKind): BizPeriod = when (kind) {
        BizPeriodKind.TODAY -> today
        BizPeriodKind.WEEK -> week
        BizPeriodKind.MONTH -> month
    }

    val hasActivity: Boolean get() = dailyIn.any { it > 0 } || dailyOut.any { it > 0 }

    /** The chart's three labels: the first day, the middle and today. */
    val axis: List<String>
        get() = if (dayLabels.size >= 14) listOf(dayLabels[0], dayLabels[7], dayLabels[13]) else emptyList()

    /**
     * The figures as they stand on [todayIso]. The app only writes while it is open, so after
     * midnight the stored day is an old one: today has nothing yet, "7 days" moves on by what the
     * app worked out ahead (weekRoll), and in a new month so does the month. The chart slides
     * left, and advice that only held for the old day is dropped.
     */
    fun resolveFor(todayIso: String, thisMonth: String): BizSnapshot {
        val stored = runCatching { LocalDate.parse(date) }.getOrNull() ?: return this
        val now = runCatching { LocalDate.parse(todayIso) }.getOrNull() ?: return this
        val days = ChronoUnit.DAYS.between(stored, now).toInt()
        if (days <= 0) return this
        val sameMonth = stored.year == now.year && stored.month == now.month
        fun slide(values: List<Long>) =
            if (days >= values.size) List(values.size) { 0L } else values.drop(days) + List(days) { 0L }
        return copy(
            date = todayIso,
            today = today.empty(zero),
            week = weekRoll.getOrNull(days - 1) ?: week.empty(zero),
            // The month so far still holds, but not how it compares on a later day
            month = if (sameMonth) month.copy(inChange = null, outChange = null) else month.empty(zero, thisMonth),
            dailyIn = slide(dailyIn),
            dailyOut = slide(dailyOut),
            dayLabels = if (days + 14 <= dayLabels.size) dayLabels.drop(days).take(14) else emptyList(),
            insights = insights.filter { it.until >= todayIso },
        )
    }

    /** Amounts hidden, for a home screen others can see; percentages and advice without amounts stay. */
    fun masked(): BizSnapshot = copy(
        balance = mask,
        today = today.masked(mask),
        week = week.masked(mask),
        month = month.masked(mask),
        insights = insights.map { it.copy(text = it.masked) },
        rows = rows.map { it.copy(amount = mask) },
    )

    companion object {
        /** "Till · Rahim Traders": the business comes last, so it is what a short line cuts. */
        fun withBusiness(book: String, business: String): String =
            if (business.isBlank()) book else "$book · $business"

        /** Null for nothing stored, a broken value, or a shape from a newer app than this widget. */
        fun parse(json: String?): BizSnapshot? {
            if (json.isNullOrBlank()) return null
            return try {
                val o = JSONObject(json)
                if (o.optInt("v", 0) > BizKeys.VERSION) return null
                BizSnapshot(
                    kind = o.optString("kind"),
                    id = o.optString("id"),
                    workspaceId = o.optString("workspaceId"),
                    name = o.optString("name"),
                    subtitle = o.optString("subtitle"),
                    date = o.optString("date"),
                    balance = o.optString("balance"),
                    balanceNegative = o.optBoolean("balanceNegative", false),
                    mask = o.optString("mask", "••••"),
                    zero = o.optString("zero"),
                    canAdd = o.optBoolean("canAdd", false),
                    today = o.optJSONObject("today").toPeriod(),
                    week = o.optJSONObject("week").toPeriod(),
                    month = o.optJSONObject("month").toPeriod(),
                    weekRoll = o.optJSONArray("weekRoll").objects().map { it.toPeriod() },
                    dailyIn = o.optJSONArray("dailyIn").toLongs(),
                    dailyOut = o.optJSONArray("dailyOut").toLongs(),
                    dayLabels = o.optJSONArray("dayLabels").toStrings(),
                    insights = o.optJSONArray("insights").objects().map {
                        BizInsight(
                            kind = it.optString("kind"),
                            text = it.optString("text"),
                            masked = it.optString("masked"),
                            tone = when (it.optString("tone")) {
                                "good" -> BizTone.GOOD
                                "warn" -> BizTone.WARN
                                else -> BizTone.INFO
                            },
                            until = it.optString("until", "9999-12-31"),
                        )
                    },
                    rows = o.optJSONArray("rows").objects().map {
                        BizRow(
                            title = it.optString("title"),
                            detail = it.optStringOrNull("detail"),
                            amount = it.optString("amount"),
                            negative = it.optBoolean("negative", false),
                            link = it.optStringOrNull("link"),
                        )
                    },
                    updated = o.optString("updated"),
                )
            } catch (e: Exception) {
                null
            }
        }
    }
}

data class CatalogBook(val id: String, val name: String, val detail: String)

data class CatalogBusiness(val id: String, val name: String, val detail: String, val books: List<CatalogBook>)

/** Who is signed in, the plan, the widgets' words, and what the picker offers. */
data class BizCatalog(
    val signedIn: Boolean,
    val unlocked: Boolean,
    val strings: Map<String, String>,
    val businesses: List<CatalogBusiness>,
) {
    fun text(key: String): String = strings[key].orEmpty()

    /** The one business ([business]) or book there is to show, if there is exactly one. */
    fun onlyChoice(business: Boolean): String? =
        if (business) businesses.singleOrNull()?.id else businesses.flatMap { it.books }.singleOrNull()?.id

    /** Whether [id] is still a business, or a book of one, that the user can see. */
    fun knows(id: String): Boolean = businesses.any { b -> b.id == id || b.books.any { it.id == id } }

    companion object {
        fun parse(json: String?): BizCatalog? {
            if (json.isNullOrBlank()) return null
            return try {
                val o = JSONObject(json)
                if (o.optInt("v", 0) > BizKeys.VERSION) return null
                BizCatalog(
                    signedIn = o.optBoolean("signedIn", false),
                    unlocked = o.optBoolean("unlocked", false),
                    strings = o.optJSONObject("strings")?.let { s -> s.keys().asSequence().associateWith { s.optString(it) } }
                        ?: emptyMap(),
                    businesses = o.optJSONArray("businesses").objects().map { b ->
                        CatalogBusiness(
                            id = b.optString("id"),
                            name = b.optString("name"),
                            detail = b.optString("detail"),
                            books = b.optJSONArray("books").objects().map {
                                CatalogBook(it.optString("id"), it.optString("name"), it.optString("detail"))
                            },
                        )
                    },
                )
            } catch (e: Exception) {
                null
            }
        }
    }
}

private val EMPTY_PERIOD = BizPeriod("", "", "", "", "", false, null, true, null, true)

private fun JSONObject?.toPeriod(): BizPeriod {
    if (this == null) return EMPTY_PERIOD
    return BizPeriod(
        label = optString("label"),
        compare = optString("compare"),
        inText = optString("in"),
        outText = optString("out"),
        net = optString("net"),
        netNegative = optBoolean("netNegative", false),
        inChange = optStringOrNull("inChange"),
        inGood = optBoolean("inGood", true),
        outChange = optStringOrNull("outChange"),
        outGood = optBoolean("outGood", true),
    )
}

private fun JSONObject.optStringOrNull(key: String): String? = if (isNull(key)) null else optString(key).ifEmpty { null }

private fun JSONArray?.objects(): List<JSONObject> =
    if (this == null) emptyList() else (0 until length()).mapNotNull { optJSONObject(it) }

private fun JSONArray?.toLongs(): List<Long> = if (this == null) emptyList() else List(length()) { optLong(it, 0) }

private fun JSONArray?.toStrings(): List<String> = if (this == null) emptyList() else List(length()) { optString(it) }
