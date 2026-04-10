package com.example.language_toggle_widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews

/**
 * Android home-screen / lock-screen widget for LangToggle.
 *
 * Tapping the widget toggle button sends a broadcast back to the app
 * which Flutter picks up via the platform channel.
 */
class LangToggleWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREFS_NAME = "FlutterSharedPreferences"
        const val ACTION_TOGGLE = "com.example.language_toggle_widget.WIDGET_TOGGLE"

        /** Refresh every widget instance on screen. */
        fun updateAllWidgets(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(
                ComponentName(context, LangToggleWidgetProvider::class.java)
            )
            if (ids.isNotEmpty()) {
                val provider = LangToggleWidgetProvider()
                provider.onUpdate(context, mgr, ids)
            }
        }

        private fun getPrefs(context: Context): SharedPreferences =
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        /** Read a string value written by Flutter's SharedPreferences. */
        private fun prefString(prefs: SharedPreferences, key: String): String? =
            prefs.getString("flutter.$key", null)

        private fun prefBool(prefs: SharedPreferences, key: String): Boolean =
            prefs.getBoolean("flutter.$key", false)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_TOGGLE) {
            // Launch the main Flutter activity which handles the toggle logic.
            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
                ?.apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                    putExtra("widget_toggle", true)
                }
            if (launchIntent != null) {
                context.startActivity(launchIntent)
            }
        }
    }

    private fun updateWidget(
        context: Context,
        mgr: AppWidgetManager,
        widgetId: Int
    ) {
        val prefs = getPrefs(context)
        val isEnabled = prefBool(prefs, "is_enabled")
        val flag = prefString(prefs, "current_language_flag") ?: "🏠"
        val name = prefString(prefs, "current_language_name")
            ?: if (isEnabled) "Learning" else "Native"

        val views = RemoteViews(context.packageName, R.layout.lang_toggle_widget)

        // Flag + language name
        views.setTextViewText(R.id.widget_language_flag, flag)
        views.setTextViewText(R.id.widget_language_name, name)

        // Toggle label & background
        if (isEnabled) {
            views.setTextViewText(R.id.widget_toggle_btn, "ON")
            views.setInt(
                R.id.widget_toggle_btn, "setBackgroundResource",
                R.drawable.toggle_bg_on
            )
        } else {
            views.setTextViewText(R.id.widget_toggle_btn, "OFF")
            views.setInt(
                R.id.widget_toggle_btn, "setBackgroundResource",
                R.drawable.toggle_bg_off
            )
        }

        // Tap on the whole widget (or toggle button) → open app to toggle
        val toggleIntent = Intent(context, LangToggleWidgetProvider::class.java).apply {
            action = ACTION_TOGGLE
        }
        val pendingToggle = PendingIntent.getBroadcast(
            context, 0, toggleIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_toggle_btn, pendingToggle)
        views.setOnClickPendingIntent(R.id.widget_language_flag, pendingToggle)

        mgr.updateAppWidget(widgetId, views)
    }
}
