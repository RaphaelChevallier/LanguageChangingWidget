import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var prefs = PreferencesManager.shared
    @State private var isEnabled: Bool = PreferencesManager.shared.isEnabled
    @State private var nativeCode: String = PreferencesManager.shared.nativeLanguageCode
    @State private var targetCodes: Set<String> = Set(PreferencesManager.shared.targetLanguageCodes)
    @State private var intervalName: String = PreferencesManager.shared.intervalName

    var body: some View {
        NavigationView {
            List {
                // Toggle
                Section {
                    HStack {
                        let lang = prefs.currentLanguage
                        Text(lang.flag).font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(lang.name).font(.headline).foregroundColor(.white)
                            Text(isEnabled ? "Learning Mode" : "Native Mode")
                                .font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        Toggle("", isOn: $isEnabled)
                            .labelsHidden()
                            .tint(Color(red: 0.42, green: 0.39, blue: 1.0))
                            .onChange(of: isEnabled) { _ in
                                prefs.toggle()
                                isEnabled = prefs.isEnabled
                            }
                    }
                }

                // Native Language
                Section("Native Language") {
                    ForEach(Language.all) { lang in
                        Button {
                            nativeCode = lang.code
                            prefs.nativeLanguageCode = lang.code
                            targetCodes.remove(lang.code)
                            prefs.targetLanguageCodes = Array(targetCodes)
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            HStack {
                                Text("\(lang.flag)  \(lang.name)")
                                    .foregroundColor(.white)
                                Spacer()
                                if lang.code == nativeCode {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(red: 0.42, green: 0.39, blue: 1.0))
                                }
                            }
                        }
                    }
                }

                // Target Languages
                Section("Languages to Learn") {
                    ForEach(Language.all.filter { $0.code != nativeCode }) { lang in
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
                                Text("\(lang.flag)  \(lang.name)")
                                    .foregroundColor(.white)
                                Spacer()
                                if targetCodes.contains(lang.code) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.42, green: 0.39, blue: 1.0))
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }

                // Interval
                Section("Change Interval") {
                    ForEach(ChangeInterval.allCases) { interval in
                        Button {
                            intervalName = interval.rawValue
                            prefs.intervalName = interval.rawValue
                            WidgetCenter.shared.reloadAllTimelines()
                        } label: {
                            HStack {
                                Text(interval.label).foregroundColor(.white)
                                Spacer()
                                if interval.rawValue == intervalName {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(red: 0.42, green: 0.39, blue: 1.0))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("LangToggle")
            .preferredColorScheme(.dark)
        }
    }
}
