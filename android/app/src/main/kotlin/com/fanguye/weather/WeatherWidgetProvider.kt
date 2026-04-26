package com.fanguye.weather

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * AppWidgetProvider for the weather home widget.
 *
 * Displays current temperature, location, weather condition and
 * daily max/min temperatures. Data is synced from Flutter via
 * [HomeWidgetPlugin.saveWidgetData].
 */
class WeatherWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFIX = "weather_widget_"

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.weather_widget)

            // Read data shared by Flutter via HomeWidget
            val prefs = HomeWidgetPlugin.getData(context)

            val location = prefs.getString("${PREFIX}location", "--") ?: "--"
            val tempStr = prefs.getString("${PREFIX}temp", "--") ?: "--"
            val codeStr = prefs.getString("${PREFIX}code", "0") ?: "0"
            val isDayStr = prefs.getString("${PREFIX}isDay", "1") ?: "1"
            val description = prefs.getString("${PREFIX}desc", "") ?: ""
            val maxStr = prefs.getString("${PREFIX}max", "") ?: ""
            val minStr = prefs.getString("${PREFIX}min", "") ?: ""

            views.setTextViewText(R.id.widget_location, location)
            views.setTextViewText(R.id.widget_temperature, "${tempStr}°")
            views.setTextViewText(R.id.widget_description, description)

            val maxMin = when {
                maxStr.isNotEmpty() && minStr.isNotEmpty() -> "↑${maxStr}°  ↓${minStr}°"
                else -> ""
            }
            views.setTextViewText(R.id.widget_max_min, maxMin)

            // Map weather code to drawable icon
            val weatherCode = codeStr.toIntOrNull() ?: 0
            val isDay = isDayStr == "1"
            val iconRes = resolveWeatherIcon(weatherCode, isDay)
            views.setImageViewResource(R.id.widget_icon, iconRes)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun resolveWeatherIcon(code: Int, isDay: Boolean): Int {
            return when (code) {
                0 -> if (isDay) R.drawable.wi_day_sunny else R.drawable.wi_night_clear
                1, 2, 3 -> if (isDay) R.drawable.wi_day_cloudy else R.drawable.wi_night_cloudy
                45, 48 -> R.drawable.wi_fog
                51, 53, 55, 56, 57 -> R.drawable.wi_showers
                61, 63, 65, 80, 81, 82 -> R.drawable.wi_rain
                71, 73, 75, 77, 85, 86 -> R.drawable.wi_snow
                95, 96, 99 -> R.drawable.wi_thunderstorm
                else -> if (isDay) R.drawable.wi_day_sunny else R.drawable.wi_night_clear
            }
        }
    }
}
