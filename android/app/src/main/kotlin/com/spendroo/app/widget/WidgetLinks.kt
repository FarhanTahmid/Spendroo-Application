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

    // The business widgets'. Each names its workspace, which the app opens first.

    fun business(workspaceId: String) = "spendroo://business?ws=$workspaceId"

    fun book(bookId: String, workspaceId: String) = "spendroo://book?id=$bookId&ws=$workspaceId"

    /** A book's entry form, on 'cash_in' or 'cash_out'. */
    fun bookAdd(bookId: String, workspaceId: String, type: String) =
        "spendroo://book-add?id=$bookId&ws=$workspaceId&type=$type"

    /** Which of a business's books, then the entry form. */
    fun businessAdd(workspaceId: String, type: String) = "spendroo://business-add?ws=$workspaceId&type=$type"
}
