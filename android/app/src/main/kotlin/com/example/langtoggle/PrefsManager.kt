package com.example.langtoggle

import android.content.Context
import android.content.SharedPreferences

class PrefsManager(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences("langtoggle_prefs", Context.MODE_PRIVATE)

    var isEnabled: Boolean
        get() = prefs.getBoolean(KEY_ENABLED, false)
        set(value) { prefs.edit().putBoolean(KEY_ENABLED, value).apply() }

    var primaryLanguageCode: String
        get() = prefs.getString(KEY_PRIMARY, "en") ?: "en"
        set(value) { prefs.edit().putString(KEY_PRIMARY, value).apply() }

    var targetLanguageCodes: Set<String>
        get() = prefs.getStringSet(KEY_TARGETS, emptySet()) ?: emptySet()
        set(value) { prefs.edit().putStringSet(KEY_TARGETS, value).apply() }

    var intervalName: String
        get() = prefs.getString(KEY_INTERVAL, ChangeInterval.EVERY_DAY.name) ?: ChangeInterval.EVERY_DAY.name
        set(value) { prefs.edit().putString(KEY_INTERVAL, value).apply() }

    var currentLanguageCode: String
        get() = prefs.getString(KEY_CURRENT, primaryLanguageCode) ?: primaryLanguageCode
        set(value) { prefs.edit().putString(KEY_CURRENT, value).apply() }

    val primaryLanguage: Language
        get() = Language.fromCode(primaryLanguageCode) ?: Language.ALL.first()

    val currentLanguage: Language
        get() = Language.fromCode(currentLanguageCode) ?: primaryLanguage

    val targetLanguages: List<Language>
        get() = targetLanguageCodes.mapNotNull(Language::fromCode)

    val interval: ChangeInterval
        get() = ChangeInterval.fromName(intervalName)

    companion object {
        private const val KEY_ENABLED = "is_enabled"
        private const val KEY_PRIMARY = "primary_language"
        private const val KEY_TARGETS = "target_languages"
        private const val KEY_INTERVAL = "change_interval"
        private const val KEY_CURRENT = "current_language"
    }
}
