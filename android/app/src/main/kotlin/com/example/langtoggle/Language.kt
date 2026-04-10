package com.example.langtoggle

import java.util.Locale

data class Language(
    val code: String,
    val name: String,
    val nativeName: String,
    val flag: String,
) {
    override fun toString() = "$flag $name"

    companion object {
        /** Convert a 2-letter ISO country code to its flag emoji. */
        private fun countryToFlag(countryCode: String): String {
            if (countryCode.length != 2) return "\uD83C\uDFF3\uFE0F"
            val first = 0x1F1E6 + (countryCode[0].uppercaseChar() - 'A')
            val second = 0x1F1E6 + (countryCode[1].uppercaseChar() - 'A')
            return String(Character.toChars(first)) + String(Character.toChars(second))
        }

        /** Default country for base-language entries (flag display & fromCode fallback). */
        private val DEFAULT_COUNTRY = mapOf(
            "af" to "ZA", "am" to "ET", "ar" to "SA", "az" to "AZ",
            "be" to "BY", "bg" to "BG", "bn" to "BD", "bs" to "BA",
            "ca" to "ES", "cs" to "CZ", "cy" to "GB", "da" to "DK",
            "el" to "GR", "en" to "US", "es" to "ES", "et" to "EE",
            "eu" to "ES", "fa" to "IR", "fi" to "FI", "fil" to "PH",
            "fr" to "FR", "ga" to "IE", "gl" to "ES", "gu" to "IN",
            "he" to "IL", "hi" to "IN", "hr" to "HR", "hu" to "HU",
            "hy" to "AM", "id" to "ID", "is" to "IS", "it" to "IT",
            "ja" to "JP", "ka" to "GE", "kk" to "KZ", "km" to "KH",
            "kn" to "IN", "ko" to "KR", "ky" to "KG", "lo" to "LA",
            "lt" to "LT", "lv" to "LV", "mk" to "MK", "ml" to "IN",
            "mn" to "MN", "mr" to "IN", "ms" to "MY", "my" to "MM",
            "nb" to "NO", "ne" to "NP", "nl" to "NL", "nn" to "NO",
            "or" to "IN", "pa" to "IN", "pl" to "PL", "pt" to "BR",
            "ro" to "RO", "ru" to "RU", "si" to "LK", "sk" to "SK",
            "sl" to "SI", "sq" to "AL", "sr" to "RS", "sv" to "SE",
            "sw" to "KE", "ta" to "IN", "te" to "IN", "th" to "TH",
            "tr" to "TR", "uk" to "UA", "ur" to "PK", "uz" to "UZ",
            "vi" to "VN", "zh" to "CN", "zu" to "ZA",
        )

        /** All languages available on this device, built dynamically from system locales. */
        var ALL: List<Language> = buildLanguageList()
            private set

        /** Re-scan system locales (call after user returns from language settings). */
        fun refresh() { ALL = buildLanguageList() }

        private fun buildLanguageList(): List<Language> {
            val locales = Locale.getAvailableLocales()
                .filter { it.language.length in 2..3 }

            // Regional variants, deduplicated by language-country.
            // Prefer entries with a script tag (they produce more descriptive display names).
            val byLangCountry = mutableMapOf<String, Locale>()
            for (locale in locales) {
                if (locale.country.isEmpty()) continue
                val key = "${locale.language}-${locale.country}"
                val existing = byLangCountry[key]
                if (existing == null ||
                    locale.toLanguageTag().length > existing.toLanguageTag().length
                ) {
                    byLangCountry[key] = locale
                }
            }

            // Base-only languages that have no regional variant on the device.
            val coveredLangs = byLangCountry.values.map { it.language }.toSet()
            val baseLocales = locales
                .filter {
                    it.country.isEmpty() && it.variant.isEmpty() &&
                        it.language !in coveredLangs
                }
                .distinctBy { it.language }

            val regional = byLangCountry.values.map { locale ->
                Language(
                    code = locale.toLanguageTag(),
                    name = locale.getDisplayName(Locale.ENGLISH).trim(),
                    nativeName = locale.getDisplayName(locale).trim(),
                    flag = countryToFlag(locale.country),
                )
            }

            val base = baseLocales.map { locale ->
                val country = DEFAULT_COUNTRY[locale.language] ?: ""
                Language(
                    code = locale.language,
                    name = locale.getDisplayLanguage(Locale.ENGLISH).trim(),
                    nativeName = locale.getDisplayLanguage(locale).trim(),
                    flag = countryToFlag(country),
                )
            }

            return (regional + base)
                .filter { it.name.isNotBlank() && !it.name.equals(it.code, ignoreCase = true) }
                .sortedBy { it.name.lowercase() }
        }

        /** Look up by exact code, falling back to best base-language match. */
        fun fromCode(code: String): Language? {
            ALL.find { it.code == code }?.let { return it }
            val baseLang = code.substringBefore("-")
            val defaultCountry = DEFAULT_COUNTRY[baseLang]
            if (defaultCountry != null) {
                ALL.find {
                    it.code.startsWith("$baseLang-") &&
                        it.code.contains(defaultCountry)
                }?.let { return it }
            }
            return ALL.find { it.code.startsWith("$baseLang-") }
        }
    }
}
