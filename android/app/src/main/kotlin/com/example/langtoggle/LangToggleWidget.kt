package com.example.langtoggle

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.LocaleList
import android.widget.RemoteViews
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.Locale
import java.util.concurrent.TimeUnit

class LangToggleWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, mgr: AppWidgetManager, ids: IntArray) {
        ids.forEach { updateWidget(context, mgr, it) }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_TOGGLE -> {
                val prefs = PrefsManager(context)
                if (prefs.isEnabled) {
                    disable(context, prefs)
                } else {
                    enable(context, prefs)
                }
                refreshAll(context)
            }
            ACTION_SETTINGS -> {
                context.startActivity(
                    Intent(context, SettingsActivity::class.java)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                )
            }
        }
    }

    private fun enable(context: Context, prefs: PrefsManager) {
        if (prefs.targetLanguages.isEmpty()) return
        prefs.isEnabled = true
        pickNext(prefs)
        setAppLocale(context, prefs.currentLanguageCode)
        scheduleRotation(context, prefs.interval)
    }

    private fun disable(context: Context, prefs: PrefsManager) {
        prefs.isEnabled = false
        prefs.currentLanguageCode = prefs.primaryLanguageCode
        setAppLocale(context, prefs.primaryLanguageCode)
        WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
    }

    private fun updateWidget(context: Context, mgr: AppWidgetManager, id: Int) {
        val prefs = PrefsManager(context)
        val lang = prefs.currentLanguage
        val enabled = prefs.isEnabled

        val views = RemoteViews(context.packageName, R.layout.widget_lang_toggle)
        views.setTextViewText(R.id.widget_flag, lang.flag)
        views.setTextViewText(R.id.widget_name, lang.name)
        views.setTextViewText(R.id.widget_toggle, if (enabled) "ON" else "OFF")
        views.setInt(
            R.id.widget_toggle, "setBackgroundResource",
            if (enabled) R.drawable.toggle_bg_on else R.drawable.toggle_bg_off
        )

        views.setOnClickPendingIntent(R.id.widget_toggle, broadcast(context, ACTION_TOGGLE, 0))
        views.setOnClickPendingIntent(R.id.widget_flag, broadcast(context, ACTION_TOGGLE, 1))
        views.setOnClickPendingIntent(R.id.widget_settings, broadcast(context, ACTION_SETTINGS, 2))

        mgr.updateAppWidget(id, views)
    }

    companion object {
        const val ACTION_TOGGLE = "com.example.langtoggle.TOGGLE"
        const val ACTION_SETTINGS = "com.example.langtoggle.SETTINGS"
        const val WORK_NAME = "lang_rotate"

        fun refreshAll(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, LangToggleWidget::class.java))
            if (ids.isNotEmpty()) LangToggleWidget().onUpdate(context, mgr, ids)
        }

        fun pickNext(prefs: PrefsManager) {
            val targets = prefs.targetLanguages
            if (targets.isEmpty()) return
            prefs.currentLanguageCode = targets.random().code
        }

        fun setAppLocale(context: Context, code: String) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                try {
                    val lm = context.getSystemService(Context.LOCALE_SERVICE) as android.app.LocaleManager
                    lm.applicationLocales = LocaleList(Locale.forLanguageTag(code))
                } catch (_: Exception) { }
            }
        }

        fun scheduleRotation(context: Context, interval: ChangeInterval) {
            val minutes = interval.minutes ?: return
            val request = PeriodicWorkRequestBuilder<RotationWorker>(minutes, TimeUnit.MINUTES).build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME, ExistingPeriodicWorkPolicy.CANCEL_AND_REENQUEUE, request
            )
        }

        private fun broadcast(context: Context, action: String, code: Int): PendingIntent {
            val intent = Intent(context, LangToggleWidget::class.java).apply { this.action = action }
            return PendingIntent.getBroadcast(
                context, code, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
    }
}
