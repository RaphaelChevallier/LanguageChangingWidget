package com.example.language_toggle_widget

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.os.LocaleList
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/**
 * Main Flutter activity.
 *
 * Registers the platform channel used by the Flutter app to:
 *  - Set / reset the per-app locale (Android 13+, API 33)
 *  - Refresh the home-screen widget after a toggle
 */
class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.language_toggle_widget/locale"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setLocale" -> {
                        val code = call.argument<String>("languageCode") ?: "en"
                        setAppLocale(code)
                        result.success(null)
                    }
                    "resetLocale" -> {
                        val code = call.argument<String>("languageCode") ?: "en"
                        setAppLocale(code)
                        result.success(null)
                    }
                    "updateWidget" -> {
                        val isEnabled = call.argument<Boolean>("isEnabled") ?: false
                        val langCode = call.argument<String>("languageCode") ?: "en"
                        val langName = call.argument<String>("languageName") ?: "English"
                        val langFlag = call.argument<String>("languageFlag") ?: "🏠"
                        persistWidgetState(isEnabled, langCode, langName, langFlag)
                        LangToggleWidgetProvider.updateAllWidgets(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** Sets the per-app locale via LocaleManager (API 33+) or AppCompatDelegate. */
    private fun setAppLocale(languageCode: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val localeManager = getSystemService(Context.LOCALE_SERVICE)
                    as android.app.LocaleManager
            localeManager.applicationLocales = LocaleList(Locale.forLanguageTag(languageCode))
        }
        // For API < 33 the Flutter locale change (via MaterialApp locale param) is sufficient.
    }

    /**
     * Writes widget display values into SharedPreferences so the
     * [LangToggleWidgetProvider] can read them without a Flutter context.
     */
    private fun persistWidgetState(
        isEnabled: Boolean,
        langCode: String,
        langName: String,
        langFlag: String
    ) {
        val prefs: SharedPreferences = getSharedPreferences(
            LangToggleWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE
        )
        prefs.edit()
            .putBoolean("flutter.is_enabled", isEnabled)
            .putString("flutter.current_language", langCode)
            .putString("flutter.current_language_name", langName)
            .putString("flutter.current_language_flag", langFlag)
            .apply()
    }
}
