package com.example.langtoggle

data class Language(
    val code: String,
    val name: String,
    val nativeName: String,
    val flag: String,
) {
    override fun toString() = "$flag $name"

    companion object {
        val ALL = listOf(
            Language("en", "English", "English", "🇺🇸"),
            Language("es", "Spanish", "Español", "🇪🇸"),
            Language("fr", "French", "Français", "🇫🇷"),
            Language("de", "German", "Deutsch", "🇩🇪"),
            Language("it", "Italian", "Italiano", "🇮🇹"),
            Language("pt", "Portuguese", "Português", "🇧🇷"),
            Language("ru", "Russian", "Русский", "🇷🇺"),
            Language("ja", "Japanese", "日本語", "🇯🇵"),
            Language("ko", "Korean", "한국어", "🇰🇷"),
            Language("zh", "Chinese", "中文", "🇨🇳"),
            Language("ar", "Arabic", "العربية", "🇸🇦"),
            Language("hi", "Hindi", "हिन्दी", "🇮🇳"),
            Language("nl", "Dutch", "Nederlands", "🇳🇱"),
            Language("pl", "Polish", "Polski", "🇵🇱"),
            Language("sv", "Swedish", "Svenska", "🇸🇪"),
            Language("tr", "Turkish", "Türkçe", "🇹🇷"),
            Language("vi", "Vietnamese", "Tiếng Việt", "🇻🇳"),
            Language("th", "Thai", "ภาษาไทย", "🇹🇭"),
            Language("id", "Indonesian", "Bahasa Indonesia", "🇮🇩"),
            Language("uk", "Ukrainian", "Українська", "🇺🇦"),
        )

        fun fromCode(code: String): Language? = ALL.find { it.code == code }
    }
}
