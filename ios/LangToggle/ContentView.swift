import SwiftUI
import WidgetKit

struct ContentView: View {
    private let accent = Color(red: 0.42, green: 0.39, blue: 1.0)
    @Environment(\.scenePhase) private var scenePhase

    @State private var prefs = PreferencesManager.shared
    @State private var isEnabled: Bool = PreferencesManager.shared.isEnabled
    @State private var primaryCode: String = PreferencesManager.shared.primaryLanguageCode
    @State private var targetCodes: Set<String> = Set(PreferencesManager.shared.targetLanguageCodes)
    @State private var intervalName: String = PreferencesManager.shared.intervalName
    @State private var languages: [Language] = Language.all

    var body: some View {
        NavigationView {
            List {
                // Status card
                Section {
                    VStack(spacing: 8) {
                        let lang = prefs.currentLanguage
                        Text(lang.flag).font(.system(size: 52))
                        Text(lang.name)
                            .font(.title2.bold())
                        Text(isEnabled ? "Learning Mode" : "Primary Mode")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Toggle("", isOn: $isEnabled)
                            .labelsHidden()
                            .tint(accent)
                            .onChange(of: isEnabled) { _ in
                                prefs.toggle()
                                isEnabled = prefs.isEnabled
                            }
                            .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }

                // Primary Language
                Section {
                    ForEach(languages) { lang in
                        Button {
                            primaryCode = lang.code
                            prefs.primaryLanguageCode = lang.code
                            targetCodes.remove(lang.code)
                            prefs.targetLanguageCodes = Array(targetCodes)
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            HStack {
                                Text(lang.flag).font(.title3)
                                Text(lang.name).foregroundStyle(.primary)
                                Spacer()
                                if lang.code == primaryCode {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(accent)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                } header: {
                    Label("Primary Language", systemImage: "house")
                }

                // Target Languages
                Section {
                    ForEach(languages.filter { $0.code != primaryCode }) { lang in
                        Button {
                            if targetCodes.contains(lang.code) {
                                targetCodes.remove(lang.code)
                            } else {
                                targetCodes.insert(lang.code)
                            }
                            prefs.targetLanguageCodes = Array(targetCodes)
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            HStack {
                                Text(lang.flag).font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lang.name).foregroundStyle(.primary)
                                    Text(lang.nativeName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if targetCodes.contains(lang.code) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(accent)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Label("Languages to Learn", systemImage: "book")
                }

                // Interval
                Section {
                    ForEach(ChangeInterval.allCases) { interval in
                        Button {
                            intervalName = interval.rawValue
                            prefs.intervalName = interval.rawValue
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            HStack {
                                Text(interval.label).foregroundStyle(.primary)
                                Spacer()
                                if interval.rawValue == intervalName {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(accent)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                } header: {
                    Label("Change Interval", systemImage: "timer")
                }

                // Add Language
                Section {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(accent)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add Language").foregroundStyle(.primary)
                                Text("Open device language settings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                } header: {
                    Label("More Languages", systemImage: "globe")
                } footer: {
                    Text("Add a new language to your device, then return here to select it.")
                }
            }
            .navigationTitle("LangToggle")
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    Language.refresh()
                    languages = Language.all
                }
            }
        }
    }
}
