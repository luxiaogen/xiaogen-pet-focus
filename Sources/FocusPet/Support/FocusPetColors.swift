import SwiftUI

extension Color {
    // Legacy accent names (still used by AppTheme and mode.ringColor)
    static let focusTomato = Color(red: 1.0, green: 0.39, blue: 0.28)
    static let breakSage = Color(red: 0.53, green: 0.66, blue: 0.42)
    static let celebrationGold = Color(red: 1.0, green: 0.75, blue: 0.0)

    // Warm neutrals
    static let focusInk = Color(red: 0.18, green: 0.16, blue: 0.13)
    static let focusMist = Color(red: 0.86, green: 0.89, blue: 0.82)
    static let focusCream = Color(red: 1.0, green: 0.96, blue: 0.89)
    static let focusBlush = Color(red: 1.0, green: 0.82, blue: 0.76)

    // Glass chrome
    static let glassStroke = Color.white.opacity(0.28)
    static let glassHighlight = Color.white.opacity(0.55)
    static let glassLowlight = Color.black.opacity(0.08)
    static let glassNeutralTint = Color(red: 0.67, green: 0.60, blue: 0.50)

    // DESIGN.md semantic aliases (map to existing values for now)
    static let primary = focusTomato
    static let secondary = breakSage
    static let tertiary = celebrationGold
}
