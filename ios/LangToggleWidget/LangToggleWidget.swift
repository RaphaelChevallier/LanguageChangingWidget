import WidgetKit
import SwiftUI

// MARK: - Shared data keys (must match Flutter SharedPreferences keys)
private let appGroupID = "group.com.example.languageToggleWidget"
private let suiteName = appGroupID

// MARK: - Model

struct WidgetState {
    let isEnabled: Bool
    let languageFlag: String
    let languageName: String

    static var current: WidgetState {
        let defaults = UserDefaults(suiteName: suiteName)
        return WidgetState(
            isEnabled: defaults?.bool(forKey: "flutter.is_enabled") ?? false,
            languageFlag: defaults?.string(forKey: "flutter.current_language_flag") ?? "🏠",
            languageName: defaults?.string(forKey: "flutter.current_language_name") ?? "Native"
        )
    }
}

// MARK: - Timeline provider

struct LangToggleProvider: TimelineProvider {
    func placeholder(in context: Context) -> LangToggleEntry {
        LangToggleEntry(date: Date(), state: WidgetState(isEnabled: false, languageFlag: "🏠", languageName: "Native"))
    }

    func getSnapshot(in context: Context, completion: @escaping (LangToggleEntry) -> Void) {
        completion(LangToggleEntry(date: Date(), state: .current))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LangToggleEntry>) -> Void) {
        let entry = LangToggleEntry(date: Date(), state: .current)
        // Refresh every 15 minutes so the widget stays in sync.
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Entry

struct LangToggleEntry: TimelineEntry {
    let date: Date
    let state: WidgetState
}

// MARK: - Widget view

struct LangToggleWidgetEntryView: View {
    var entry: LangToggleProvider.Entry

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(entry.state.isEnabled
                    ? Color(red: 0.42, green: 0.39, blue: 1.0)
                    : Color(white: 0.12))

            VStack(spacing: 4) {
                Text("🌐")
                    .font(.caption2)
                    .opacity(0.7)

                Text(entry.state.languageFlag)
                    .font(.system(size: 34))

                Text(entry.state.languageName)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(entry.state.isEnabled ? "ON" : "OFF")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(entry.state.isEnabled
                                ? Color.white.opacity(0.3)
                                : Color.gray.opacity(0.4))
                    )
            }
            .padding(8)
        }
        // Tapping the widget opens the main app.
        .widgetURL(URL(string: "langtoggle://toggle"))
    }
}

// MARK: - Widget configuration

@main
struct LangToggleWidget: Widget {
    let kind: String = "LangToggleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LangToggleProvider()) { entry in
            LangToggleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("LangToggle")
        .description("Toggle language learning mode on or off.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

// MARK: - Preview

struct LangToggleWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LangToggleWidgetEntryView(
                entry: LangToggleEntry(
                    date: Date(),
                    state: WidgetState(isEnabled: false, languageFlag: "🏠", languageName: "Native")
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("OFF")

            LangToggleWidgetEntryView(
                entry: LangToggleEntry(
                    date: Date(),
                    state: WidgetState(isEnabled: true, languageFlag: "🇯🇵", languageName: "Japanese")
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("ON – Japanese")
        }
    }
}
