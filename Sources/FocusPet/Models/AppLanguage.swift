import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case chinese

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .english:
            "EN"
        case .chinese:
            "中文"
        }
    }
}
