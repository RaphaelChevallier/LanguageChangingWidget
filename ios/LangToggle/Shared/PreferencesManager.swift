import Foundation
import WidgetKit

final class PreferencesManager {
    static let shared = PreferencesManager()
    private let defaults: UserDefaults

    private init() {
        defaults = UserDefaults(suiteName: "group.com.example.langtoggle") ?? .standard
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: "is_enabled") }
        set { defaults.set(newValue, forKey: "is_enabled"); sync() }
    }

    var nativeLanguageCode: String {
        get { defaults.string(forKey: "native_language") ?? "en" }
        set { defaults.set(newValue, forKey: "native_language"); sync() }
    }

    var targetLanguageCodes: [String] {
        get { defaults.stringArray(forKey: "target_languages") ?? [] }
        set { defaults.set(newValue, forKey: "target_languages"); sync() }
    }

    var intervalName: String {
        get { defaults.string(forKey: "change_interval") ?? ChangeInterval.everyDay.rawValue }
        set { defaults.set(newValue, forKey: "change_interval"); sync() }
    }

    var currentLanguageCode: String {
        get { defaults.string(forKey: "current_language") ?? nativeLanguageCode }
        set { defaults.set(newValue, forKey: "current_language"); sync() }
    }

    var nativeLanguage: Language {
        Language.fromCode(nativeLanguageCode) ?? Language.all[0]
    }

    var currentLanguage: Language {
        Language.fromCode(currentLanguageCode) ?? nativeLanguage
    }

    var targetLanguages: [Language] {
        targetLanguageCodes.compactMap(Language.fromCode)
    }

    var interval: ChangeInterval {
        ChangeInterval(rawValue: intervalName) ?? .everyDay
    }

    func toggle() {
        if isEnabled {
            isEnabled = false
            currentLanguageCode = nativeLanguageCode
        } else {
            guard !targetLanguages.isEmpty else { return }
            isEnabled = true
            pickNext()
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    func pickNext() {
        guard let next = targetLanguages.randomElement() else { return }
        currentLanguageCode = next.code
    }

    private func sync() {
        defaults.synchronize()
    }
}
