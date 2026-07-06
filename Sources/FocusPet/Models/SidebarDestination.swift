import Foundation

enum SidebarDestination: String, CaseIterable, Identifiable {
    case timer
    case petHouse
    case statistics
    case settings

    var id: String { rawValue }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .timer:
            language == .chinese ? "计时器" : "Timer"
        case .petHouse:
            language == .chinese ? "宠物屋" : "Pet House"
        case .statistics:
            language == .chinese ? "统计" : "Statistics"
        case .settings:
            language == .chinese ? "设置" : "Settings"
        }
    }

    func shortTitle(in language: AppLanguage) -> String {
        switch self {
        case .timer:
            language == .chinese ? "计时" : "Timer"
        case .petHouse:
            language == .chinese ? "宠物" : "Pet"
        case .statistics:
            language == .chinese ? "统计" : "Stats"
        case .settings:
            language == .chinese ? "设置" : "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .timer:
            "timer"
        case .petHouse:
            "house.fill"
        case .statistics:
            "chart.bar.xaxis"
        case .settings:
            "gearshape.fill"
        }
    }
}
