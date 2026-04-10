package com.example.langtoggle

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity

class SettingsActivity : AppCompatActivity() {

    private lateinit var prefs: PrefsManager
    private lateinit var primaryValue: TextView
    private lateinit var targetsValue: TextView
    private lateinit var intervalValue: TextView
    private lateinit var statusFlag: TextView
    private lateinit var statusName: TextView
    private lateinit var statusMode: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings)
        prefs = PrefsManager(this)

        primaryValue = findViewById(R.id.setting_primary_value)
        targetsValue = findViewById(R.id.setting_targets_value)
        intervalValue = findViewById(R.id.setting_interval_value)
        statusFlag = findViewById(R.id.status_flag)
        statusName = findViewById(R.id.status_lang_name)
        statusMode = findViewById(R.id.status_mode)

        findViewById<View>(R.id.setting_primary).setOnClickListener { pickPrimaryLanguage() }
        findViewById<View>(R.id.setting_targets).setOnClickListener { pickTargetLanguages() }
        findViewById<View>(R.id.setting_interval).setOnClickListener { pickInterval() }

        refreshUI()
    }

    private fun refreshUI() {
        val current = prefs.currentLanguage
        statusFlag.text = current.flag
        statusName.text = current.name
        statusMode.text = if (prefs.isEnabled) "Learning Mode" else "Primary Mode"
        primaryValue.text = prefs.primaryLanguage.toString()
        val targets = prefs.targetLanguages
        targetsValue.text = if (targets.isEmpty()) "None selected" else targets.joinToString("  ") { it.flag }
        intervalValue.text = prefs.interval.label
    }

    private fun pickPrimaryLanguage() {
        val languages = Language.ALL
        val names = languages.map { it.toString() }.toTypedArray()
        val current = languages.indexOfFirst { it.code == prefs.primaryLanguageCode }

        AlertDialog.Builder(this)
            .setTitle("Primary Language")
            .setSingleChoiceItems(names, current) { dialog, which ->
                prefs.primaryLanguageCode = languages[which].code
                refreshUI()
                dialog.dismiss()
            }
            .show()
    }

    private fun pickTargetLanguages() {
        val languages = Language.ALL.filter { it.code != prefs.primaryLanguageCode }
        val names = languages.map { it.toString() }.toTypedArray()
        val selected = prefs.targetLanguageCodes
        val checked = languages.map { it.code in selected }.toBooleanArray()

        AlertDialog.Builder(this)
            .setTitle("Languages to Learn")
            .setMultiChoiceItems(names, checked) { _, which, isChecked ->
                checked[which] = isChecked
            }
            .setPositiveButton("OK") { _, _ ->
                prefs.targetLanguageCodes = languages
                    .filterIndexed { i, _ -> checked[i] }
                    .map { it.code }
                    .toSet()
                refreshUI()
                LangToggleWidget.refreshAll(this)
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun pickInterval() {
        val intervals = ChangeInterval.entries
        val names = intervals.map { it.label }.toTypedArray()
        val current = intervals.indexOf(prefs.interval)

        AlertDialog.Builder(this)
            .setTitle("Change Interval")
            .setSingleChoiceItems(names, current) { dialog, which ->
                prefs.intervalName = intervals[which].name
                if (prefs.isEnabled) {
                    LangToggleWidget.scheduleRotation(this, intervals[which])
                }
                refreshUI()
                dialog.dismiss()
            }
            .show()
    }

    override fun onPause() {
        super.onPause()
        LangToggleWidget.refreshAll(this)
    }
}
