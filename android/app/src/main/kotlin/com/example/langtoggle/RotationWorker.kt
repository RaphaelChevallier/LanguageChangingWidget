package com.example.langtoggle

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

class RotationWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        val prefs = PrefsManager(applicationContext)
        if (!prefs.isEnabled || prefs.targetLanguages.isEmpty()) return Result.success()
        LangToggleWidget.pickNext(prefs)
        LangToggleWidget.setAppLocale(applicationContext, prefs.currentLanguageCode)
        LangToggleWidget.refreshAll(applicationContext)

        // If using random interval, re-schedule the next one-shot with a new random delay
        if (prefs.interval == ChangeInterval.RANDOM) {
            LangToggleWidget.scheduleRandomOneShot(applicationContext)
        }
        return Result.success()
    }
}
