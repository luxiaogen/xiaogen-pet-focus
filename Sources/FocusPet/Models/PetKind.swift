import Foundation

enum PetKind: String, CaseIterable, Identifiable {
    case panda
    case cat
    case doro
    case feibi
    case clawd
    case gugugaga
    case ikunchick

    var id: String { rawValue }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .panda:
            language == .chinese ? "熊猫" : "Panda"
        case .cat:
            language == .chinese ? "猫咪" : "Cat"
        case .doro:
            language == .chinese ? "Doro 小兽" : "Doro"
        case .feibi:
            language == .chinese ? "菲比" : "Feibi"
        case .clawd:
            language == .chinese ? "Clawd 小蟹" : "Clawd"
        case .gugugaga:
            language == .chinese ? "企鹅咕咕" : "Gugugaga"
        case .ikunchick:
            language == .chinese ? "篮球小鸡" : "IkunChick"
        }
    }

    var symbolName: String {
        switch self {
        case .panda:
            "pawprint.fill"
        case .cat:
            "cat.fill"
        case .doro:
            "rosette"
        case .feibi:
            "sparkles"
        case .clawd:
            "square.fill"
        case .gugugaga:
            "bird.fill"
        case .ikunchick:
            "basketball.fill"
        }
    }

    var spriteAssetPrefix: String {
        switch self {
        case .panda, .cat:
            ""
        case .doro:
            "doro"
        case .feibi:
            "feibi"
        case .clawd:
            "clawd"
        case .gugugaga:
            "gugugaga"
        case .ikunchick:
            "ikunchick"
        }
    }

    var spriteFrameCount: Int {
        switch self {
        case .panda, .cat:
            0
        case .doro, .feibi, .clawd, .gugugaga, .ikunchick:
            6
        }
    }
}
