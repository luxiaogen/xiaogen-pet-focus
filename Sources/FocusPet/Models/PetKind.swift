import Foundation

enum PetKind: String, CaseIterable, Identifiable {
    case panda
    case cat

    var id: String { rawValue }

    var title: String {
        switch self {
        case .panda:
            "Panda"
        case .cat:
            "Cat"
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
