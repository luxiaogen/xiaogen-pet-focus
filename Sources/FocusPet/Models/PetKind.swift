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

struct ImportedPet: Codable, Hashable, Identifiable {
    let id: String
    let codexID: String
    let displayName: String
    let description: String
    let kind: String
    let directoryName: String
    let spritesheetFileName: String

    var spritesheetURL: URL {
        CodexPetImportService.importedPetsDirectory
            .appendingPathComponent(directoryName, isDirectory: true)
            .appendingPathComponent(spritesheetFileName, isDirectory: false)
    }
}

struct PetProfile: Identifiable, Hashable {
    let id: String
    let displayName: String
    let symbolName: String
    let builtInKind: PetKind?
    let importedPet: ImportedPet?

    init(kind: PetKind) {
        id = "builtin:\(kind.rawValue)"
        displayName = kind.rawValue
        symbolName = kind.symbolName
        builtInKind = kind
        importedPet = nil
    }

    init(importedPet: ImportedPet) {
        id = importedPet.id
        displayName = importedPet.displayName
        symbolName = Self.symbolName(for: importedPet.kind)
        builtInKind = nil
        self.importedPet = importedPet
    }

    func title(in language: AppLanguage) -> String {
        if let builtInKind {
            return builtInKind.title(in: language)
        }
        return displayName
    }

    private static func symbolName(for kind: String) -> String {
        switch kind.lowercased() {
        case "animal":
            "pawprint.fill"
        case "person":
            "person.crop.circle.fill"
        case "creature":
            "sparkles"
        default:
            "shippingbox.fill"
        }
    }
}
