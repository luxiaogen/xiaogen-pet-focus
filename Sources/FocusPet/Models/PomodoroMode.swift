import SwiftUI

enum PomodoroMode: String, CaseIterable, Identifiable {
    case focus
    case breakTime
    case celebration

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focus:
            "Focus"
        case .breakTime:
            "Break"
        case .celebration:
            "Done"
        }
    }

    var ringColor: Color {
        switch self {
        case .focus:
            .focusTomato
        case .breakTime:
            .breakSage
        case .celebration:
            .celebrationGold
        }
    }

    var slogan: String {
        switch self {
        case .focus:
            "Time to focus, luxiaogen!"
        case .breakTime:
            "Take a soft reset, luxiaogen."
        case .celebration:
            "Session complete. Nice work!"
        }
    }
}
