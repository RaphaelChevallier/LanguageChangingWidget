import Foundation

struct Language: Identifiable, Hashable {
    let code: String
    let name: String
    let nativeName: String
    let flag: String

    var id: String { code }

    /// Convert a 2-letter ISO country code to its flag emoji.
    private static func countryToFlag(_ countryCode: String) -> String {
        guard countryCode.count == 2 else { return "🏳️" }
        let base: UInt32 = 127397 // 0x1F1A5
        let scalars = countryCode.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(base + $0.value)
        }
        return String(scalars.map { Character($0) })
    }

    /// Default country for base-language entries (flag display & fromCode fallback).
    private static let defaultCountry: [String: String] = [
        "af": "ZA", "am": "ET", "ar": "SA", "az": "AZ",
        "be": "BY", "bg": "BG", "bn": "BD", "bs": "BA",
        "ca": "ES", "cs": "CZ", "cy": "GB", "da": "DK",
        "el": "GR", "en": "US", "es": "ES", "et": "EE",
        "eu": "ES", "fa": "IR", "fi": "FI", "fil": "PH",
        "fr": "FR", "ga": "IE", "gl": "ES", "gu": "IN",
        "he": "IL", "hi": "IN", "hr": "HR", "hu": "HU",
        "hy": "AM", "id": "ID", "is": "IS", "it": "IT",
        "ja": "JP", "ka": "GE", "kk": "KZ", "km": "KH",
        "kn": "IN", "ko": "KR", "ky": "KG", "lo": "LA",
        "lt": "LT", "lv": "LV", "mk": "MK", "ml": "IN",
        "mn": "MN", "mr": "IN", "ms": "MY", "my": "MM",
        "nb": "NO", "ne": "NP", "nl": "NL", "nn": "NO",
        "or": "IN", "pa": "IN", "pl": "PL", "pt": "BR",
        "ro": "RO", "ru": "RU", "si": "LK", "sk": "SK",
        "sl": "SI", "sq": "AL", "sr": "RS", "sv": "SE",
        "sw": "KE", "ta": "IN", "te": "IN", "th": "TH",
        "tr": "TR", "uk": "UA", "ur": "PK", "uz": "UZ",
        "vi": "VN", "zh": "CN", "zu": "ZA",
    ]

    /// All languages available on this device, built dynamically from system locales.
    private(set) static var all: [Language] = buildLanguageList()

    /// Re-scan system locales (call after user returns from language settings).
    static func refresh() { all = buildLanguageList() }

    private static func buildLanguageList() -> [Language] {
        let english = Locale(identifier: "en_US")
        let identifiers = Locale.availableIdentifiers

        // Regional variants, deduplicated by language-region.
        // Prefer the longest identifier (has script info → better display names).
        var bestForPair: [String: String] = [:]
        for id in identifiers {
            let locale = Locale(identifier: id)
            guard let lang = locale.language.languageCode?.identifier,
                  lang.count >= 2,
                  let region = locale.region?.identifier else { continue }
            let key = "\(lang)-\(region)"
            if bestForPair[key] == nil || id.count > bestForPair[key]!.count {
                bestForPair[key] = id
            }
        }

        // Base-only languages that have no regional variant on the device.
        let coveredLangs = Set(bestForPair.keys.map {
            $0.components(separatedBy: "-").first!
        })
        var seenBase = Set<String>()
        let baseIds: [String] = identifiers.compactMap { id in
            let locale = Locale(identifier: id)
            guard let lang = locale.language.languageCode?.identifier,
                  lang.count >= 2,
                  locale.region == nil,
                  !coveredLangs.contains(lang),
                  seenBase.insert(lang).inserted else { return nil }
            return id
        }

        var result: [Language] = []

        // Regional entries
        for (_, id) in bestForPair {
            let locale = Locale(identifier: id)
            guard let region = locale.region?.identifier else { continue }
            let tag = id.replacingOccurrences(of: "_", with: "-")
            let name = english.localizedString(forIdentifier: id) ?? tag
            let nativeName = locale.localizedString(forIdentifier: id) ?? tag
            guard !name.isEmpty, name != id else { continue }
            result.append(Language(
                code: tag,
                name: name,
                nativeName: nativeName,
                flag: countryToFlag(region)
            ))
        }

        // Base-only entries
        for id in baseIds {
            let locale = Locale(identifier: id)
            guard let lang = locale.language.languageCode?.identifier else { continue }
            let name = english.localizedString(forIdentifier: id) ?? id
            let nativeName = locale.localizedString(forIdentifier: id) ?? id
            guard !name.isEmpty, name != id else { continue }
            result.append(Language(
                code: lang,
                name: name,
                nativeName: nativeName,
                flag: countryToFlag(defaultCountry[lang] ?? "")
            ))
        }

        return result.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    /// Look up by exact code, falling back to best base-language match.
    static func fromCode(_ code: String) -> Language? {
        if let exact = all.first(where: { $0.code == code }) { return exact }
        let baseLang = code.components(separatedBy: "-").first ?? code
        if let defaultRegion = defaultCountry[baseLang] {
            if let match = all.first(where: {
                $0.code.hasPrefix("\(baseLang)-") && $0.code.contains(defaultRegion)
            }) { return match }
        }
        return all.first { $0.code.hasPrefix("\(baseLang)-") }
    }
}
