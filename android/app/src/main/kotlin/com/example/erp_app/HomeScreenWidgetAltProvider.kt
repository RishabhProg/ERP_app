package app.bdcoe.upmark

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider
import kotlin.math.max
import android.app.PendingIntent
import android.content.Intent

class HomeScreenWidgetAltProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                val percent = widgetData.getString("percent", "0.00") ?: "0.00"
                val present = widgetData.getInt("present", 0)
                val total = widgetData.getInt("total", 0)
                val absent = total - present
                val percentDouble = percent.toDoubleOrNull() ?: 0.0

                Log.d("HomeScreenWidgetAlt", "percent=$percent present=$present total=$total")

                val views = RemoteViews(context.packageName, R.layout.widget_layout_alt)

                views.setTextViewText(R.id.widget_percent, "$percent%")
                views.setProgressBar(R.id.widget_progress_ring, 100, percentDouble.toInt(), false)
                views.setTextViewText(R.id.widget_present_count, "$present")
                views.setTextViewText(R.id.widget_absent_count, "$absent")
                views.setTextViewText(R.id.widget_total_count, "$total")
                views.setTextViewText(
                    R.id.widget_miss_need_count,
                    if (percentDouble >= 75) "${allowedMisses(present, total)}"
                    else "${requiredPresents(present, total)}"
                )
                views.setTextViewText(
                    R.id.widget_miss_need_label,
                    if (percentDouble >= 75) "MISS UP TO" else "NEED TO ATTEND"
                )


                //launch app
                val launchIntent = Intent(context, Class.forName("app.bdcoe.upmark.MainActivity")).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                val launchPendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_circle_container, launchPendingIntent)

                //widget refresh
                val refreshIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    android.net.Uri.parse("homewidget://refresh")
                )
                views.setOnClickPendingIntent(R.id.widget_refresh_btn, refreshIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d("HomeScreenWidgetAlt", "Widget updated successfully")

            } catch (e: Exception) {
                Log.e("HomeScreenWidgetAlt", "Widget crash: ${e.message}", e)
            }
        }
    }

    private fun allowedMisses(present: Int, total: Int): Int {
        val limit = (present / 0.75).toInt()
        return max(0, limit - total)
    }

    private fun requiredPresents(present: Int, total: Int): Int {
        val needed = Math.ceil((0.75 * total - present) / 0.25).toInt()
        return max(0, needed)
    }
}