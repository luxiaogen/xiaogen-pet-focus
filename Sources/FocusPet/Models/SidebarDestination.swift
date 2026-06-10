import Foundation

enum SidebarDestination: String, CaseIterable, Identifiable {
    case timer
    case petHouse
    case statistics
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .timer:
            "Timer"
        case .petHouse:
            "Pet House"
        case .statistics:
            "Statistics"
        case .settings:
            "Settings"
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
