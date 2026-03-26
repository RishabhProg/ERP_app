package app.bdcoe.upmark

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import kotlin.math.max

class HomeScreenWidgetProvider : HomeWidgetProvider() {

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

                Log.d("HomeScreenWidget", "percent=$percent present=$present total=$total")

                val views = RemoteViews(context.packageName, R.layout.widget_layout)

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

                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d("HomeScreenWidget", "Widget updated successfully")

            } catch (e: Exception) {
                Log.e("HomeScreenWidget", "Widget crash: ${e.message}", e)
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