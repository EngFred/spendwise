package com.engineerfred.spendwise

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * SpendWise home screen widget — shows total balance, monthly income,
 * and monthly expense. Data is written from Flutter via [WidgetService]
 * using the home_widget package's shared SharedPreferences.
 *
 * Tapping anywhere on the widget opens the SpendWise app.
 */
class BalanceWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        // HomeWidgetPlugin.getData returns the SharedPreferences written by
        // the Flutter WidgetService. Keys must match exactly.
        val data = HomeWidgetPlugin.getData(context)

        val balance  = data.getString("total_balance",   "UGX 0") ?: "UGX 0"
        val income   = data.getString("monthly_income",  "UGX 0") ?: "UGX 0"
        val expense  = data.getString("monthly_expense", "UGX 0") ?: "UGX 0"
        val updated  = data.getString("last_updated",    "--")    ?: "--"

        val views = RemoteViews(context.packageName, R.layout.balance_widget_layout)

        views.setTextViewText(R.id.tv_balance, balance)
        views.setTextViewText(R.id.tv_income,  income)
        views.setTextViewText(R.id.tv_expense, expense)
        views.setTextViewText(R.id.tv_updated, updated)

        // Tapping the widget opens the app at the dashboard.
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}