package mx.pclub.lock

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Home screen widget for Prayer Lock. Shows the current streak with a flame
 * and the day count. Reads from the home_widget app group, which the Dart
 * side updates via [HomeWidget.saveWidgetData].
 */
class LockWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val streak = prefs.getInt("streak", 0)
        val best = prefs.getInt("best", 0)
        val practiced = prefs.getBoolean("practiced", false)

        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.lock_widget).apply {
                setTextViewText(R.id.streak_number, "$streak")
                setTextViewText(
                    R.id.streak_label,
                    if (streak == 1) "1-day streak" else "$streak-day streak"
                )
                setTextViewText(R.id.best_number, "$best")
                if (practiced) {
                    setTextViewText(R.id.tap_hint, "today ✓")
                } else {
                    setTextViewText(R.id.tap_hint, "tap to pray")
                }
            }
            // Open the app when tapped.
            val intent = Intent(context, MainActivity::class.java)
            val pending = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
