package app.bdcoe.upmark

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.bdcoe.upmark/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showWidgetPicker" -> {
                        val widgetName = call.argument<String>("widget")
                        val supported = showWidgetPicker(widgetName)
                        result.success(supported)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun showWidgetPicker(widgetName: String?): Boolean {
        val appWidgetManager = AppWidgetManager.getInstance(this)

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val supported = appWidgetManager.isRequestPinAppWidgetSupported
            if (supported) {
                val provider = when (widgetName) {
                    "widget1" -> ComponentName(this, HomeScreenWidgetProvider::class.java)
                    "widget2" -> ComponentName(this, HomeScreenWidgetAltProvider::class.java)
                    else -> null
                }
                provider?.let {
                    appWidgetManager.requestPinAppWidget(it, null, null)
                }
            }
            supported
        } else {
            val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_PICK)
            startActivity(intent)
            true
        }
    }
}