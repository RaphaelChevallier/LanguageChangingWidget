import Foundation

enum ChangeInterval: String, CaseIterable, Identifiable {
    case onUnlock = "ON_UNLOCK"
    case everyHour = "EVERY_HOUR"
    case every6Hours = "EVERY_6_HOURS"
    case everyDay = "EVERY_DAY"
    case every3Days = "EVERY_3_DAYS"
    case everyWeek = "EVERY_WEEK"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .onUnlock: return "Every unlock / wake"
        case .everyHour: return "Every hour"
        case .every6Hours: return "Every 6 hours"
        case .everyDay: return "Once a day"
        case .every3Days: return "Every 3 days"
        case .everyWeek: return "Once a week"
        }
    }

    var refreshMinutes: Int? {
        switch self {
        case .onUnlock: return nil
        case .everyHour: return 60
        case .every6Hours: return 360
        case .everyDay: return 1440
        case .every3Days: return 4320
        case .everyWeek: return 10080
        }
    }
}
