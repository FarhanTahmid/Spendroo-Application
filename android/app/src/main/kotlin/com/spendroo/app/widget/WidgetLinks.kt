package com.spendroo.app.widget

/**
 * Where each part of the widget leads. The app maps these to its screens in
 * lib/features/home_widget/widget_launch.dart (widgetRoute).
 */
object WidgetLinks {
    const val HOME = "spendroo://home"
    const val PLAN = "spendroo://plan"

    /** The add form, opened on 'expense', 'income' or 'transfer'. */
    fun add(kind: String) = "spendroo://add?kind=$kind"
}
