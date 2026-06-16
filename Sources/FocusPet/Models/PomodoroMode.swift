import SwiftUI

enum PomodoroMode: String, CaseIterable, Identifiable {
    case focus
    case breakTime
    case celebration

    var id: String { rawValue }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .focus:
            language == .chinese ? "专注" : "Focus"
        case .breakTime:
            language == .chinese ? "休息" : "Break"
        case .celebration:
            language == .chinese ? "完成" : "Done"
        }
    }

    func ringColor(in theme: AppTheme) -> Color {
        switch self {
        case .focus:
            theme.accentColor
        case .breakTime:
            theme.breakColor
        case .celebration:
            theme.celebrationColor
        }
    }

    func slogan(in language: AppLanguage) -> String {
        switch self {
        case .focus:
            language == .chinese ? "该专注啦，luxiaogen！" : "Time to focus, luxiaogen!"
        case .breakTime:
            language == .chinese ? "休息一下，慢慢回血。" : "Take a soft reset, luxiaogen."
        case .celebration:
            language == .chinese ? "本轮完成，做得不错！" : "Session complete. Nice work!"
        }
    }
}
