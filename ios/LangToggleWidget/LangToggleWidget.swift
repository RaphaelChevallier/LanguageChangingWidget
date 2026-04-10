import WidgetKit
import SwiftUI

struct LangToggleProvider: TimelineProvider {
    func placeholder(in context: Context) -> LangToggleEntry {
        LangToggleEntry(date: Date(), isEnabled: false, flag: "🏠", name: "Primary")
    }

    func getSnapshot(in context: Context, completion: @escaping (LangToggleEntry) -> Void) {
        let prefs = PreferencesManager.shared
        completion(LangToggleEntry(
            date: Date(),
            isEnabled: prefs.isEnabled,
            flag: prefs.currentLanguage.flag,
            name: prefs.currentLanguage.name
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LangToggleEntry>) -> Void) {
        let prefs = PreferencesManager.shared

        // If enabled and interval-based, rotate on timeline refresh
        if prefs.isEnabled && prefs.interval != .onUnlock {
            prefs.pickNext()
        }

        let entry = LangToggleEntry(
            date: Date(),
            isEnabled: prefs.isEnabled,
            flag: prefs.currentLanguage.flag,
            name: prefs.currentLanguage.name
        )

        let refreshMinutes = prefs.interval.refreshMinutes ?? 15
        let next = Calendar.current.date(byAdding: .minute, value: refreshMinutes, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct LangToggleEntry: TimelineEntry {
    let date: Date
    let isEnabled: Bool
    let flag: String
    let name: String
}

struct LangToggleWidgetEntryView: View {
    var entry: LangToggleProvider.Entry
    private let accent = Color(red: 0.42, green: 0.39, blue: 1.0)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(entry.isEnabled ? accent : Color(white: 0.12))

            VStack(spacing: 4) {
                Text(entry.flag)
                    .font(.system(size: 34))

                Text(entry.name)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(entry.isEnabled ? "ON" : "OFF")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(entry.isEnabled
                                ? Color.white.opacity(0.3)
                                : Color.gray.opacity(0.4))
                    )
            }
            .padding(8)
        }
        .widgetURL(URL(string: "langtoggle://toggle"))
    }
}

@main
struct LangToggleWidget: Widget {
    let kind = "LangToggleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LangToggleProvider()) { entry in
            LangToggleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("LangToggle")
        .description("Toggle language learning mode.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
