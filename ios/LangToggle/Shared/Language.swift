import Foundation

struct Language: Identifiable, Hashable {
    let code: String
    let name: String
    let nativeName: String
    let flag: String

    var id: String { code }

    static let all: [Language] = [
        Language(code: "en", name: "English", nativeName: "English", flag: "🇺🇸"),
        Language(code: "es", name: "Spanish", nativeName: "Español", flag: "🇪🇸"),
        Language(code: "fr", name: "French", nativeName: "Français", flag: "🇫🇷"),
        Language(code: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪"),
        Language(code: "it", name: "Italian", nativeName: "Italiano", flag: "🇮🇹"),
        Language(code: "pt", name: "Portuguese", nativeName: "Português", flag: "🇧🇷"),
        Language(code: "ru", name: "Russian", nativeName: "Русский", flag: "🇷🇺"),
        Language(code: "ja", name: "Japanese", nativeName: "日本語", flag: "🇯🇵"),
        Language(code: "ko", name: "Korean", nativeName: "한국어", flag: "🇰🇷"),
        Language(code: "zh", name: "Chinese", nativeName: "中文", flag: "🇨🇳"),
        Language(code: "ar", name: "Arabic", nativeName: "العربية", flag: "🇸🇦"),
        Language(code: "hi", name: "Hindi", nativeName: "हिन्दी", flag: "🇮🇳"),
        Language(code: "nl", name: "Dutch", nativeName: "Nederlands", flag: "🇳🇱"),
        Language(code: "pl", name: "Polish", nativeName: "Polski", flag: "🇵🇱"),
        Language(code: "sv", name: "Swedish", nativeName: "Svenska", flag: "🇸🇪"),
        Language(code: "tr", name: "Turkish", nativeName: "Türkçe", flag: "🇹🇷"),
        Language(code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt", flag: "🇻🇳"),
        Language(code: "th", name: "Thai", nativeName: "ภาษาไทย", flag: "🇹🇭"),
        Language(code: "id", name: "Indonesian", nativeName: "Bahasa Indonesia", flag: "🇮🇩"),
        Language(code: "uk", name: "Ukrainian", nativeName: "Українська", flag: "🇺🇦"),
    ]

    static func fromCode(_ code: String) -> Language? {
        all.first { $0.code == code }
    }
}
