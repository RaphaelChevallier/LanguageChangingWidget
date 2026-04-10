package com.example.langtoggle

enum class ChangeInterval(val label: String, val minutes: Long?) {
    ON_UNLOCK("Every unlock / wake", null),
    RANDOM("Random (1–8 hours)", null),
    EVERY_HOUR("Every hour", 60),
    EVERY_6_HOURS("Every 6 hours", 360),
    EVERY_DAY("Once a day", 1440),
    EVERY_3_DAYS("Every 3 days", 4320),
    EVERY_WEEK("Once a week", 10080);

    companion object {
        fun fromName(name: String): ChangeInterval =
            entries.find { it.name == name } ?: EVERY_DAY
    }
}
