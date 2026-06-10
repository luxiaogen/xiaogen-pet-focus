import Foundation

enum PetKind: String, CaseIterable, Identifiable {
    case panda
    case cat

    var id: String { rawValue }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .panda:
            language == .chinese ? "熊猫" : "Panda"
        case .cat:
            language == .chinese ? "猫咪" : "Cat"
        }
    }

    var symbolName: String {
        switch self {
        case .panda:
            "pawprint.fill"
        case .cat:
            "cat.fill"
        }
    }
}
