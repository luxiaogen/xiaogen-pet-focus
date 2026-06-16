import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case warmOrange
    case forestGreen

    var id: String { rawValue }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .warmOrange:
            language == .chinese ? "暖橙" : "Warm Orange"
        case .forestGreen:
            language == .chinese ? "薄荷森林" : "Forest Green"
        }
    }

    // MARK: - Primary accent (focus mode)

    var accentColor: Color {
        switch self {
        case .warmOrange:
            .focusTomato
        case .forestGreen:
            Color(hex: 0x1B5E20)
        }
    }

    // MARK: - Secondary accent (break mode)

    var breakColor: Color {
        switch self {
        case .warmOrange:
            .breakSage
        case .forestGreen:
            Color(hex: 0x66BB6A)
        }
    }

    // MARK: - Celebration (shared)

    var celebrationColor: Color {
        .celebrationGold
    }

    // MARK: - Background palette

    var creamColor: Color {
        switch self {
        case .warmOrange:
            .focusCream
        case .forestGreen:
            Color(hex: 0xE8F5E9)
        }
    }

    var mistColor: Color {
        switch self {
        case .warmOrange:
            .focusMist
        case .forestGreen:
            Color(hex: 0xC8E6C9)
        }
    }

    var blushColor: Color {
        switch self {
        case .warmOrange:
            .focusBlush
        case .forestGreen:
            Color(hex: 0xA5D6A7)
        }
    }
}

// MARK: - Hex color convenience

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
