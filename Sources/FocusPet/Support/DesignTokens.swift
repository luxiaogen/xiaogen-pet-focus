import SwiftUI

/// Design tokens derived from DESIGN.md (FocusPet Cozy Companion Glass).
/// These are the single source of truth for spacing, shapes, and semantic styling.
/// Colors remain co-located in FocusPetColors.swift for now (AppTheme integration).
enum DesignTokens {
    // MARK: - Spacing (4/8pt scale)

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32

        // Semantic aliases used by current layout
        static let page: CGFloat = xxl
        static let cardPadding: CGFloat = 22
        static let cardGap: CGFloat = lg
        static let section: CGFloat = xl
    }

    // MARK: - Shapes / Corner Radii

    enum Rounded {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 22
        static let full: CGFloat = 9999
    }

    // MARK: - Typography helpers (system rounded)

    enum Typography {
        static func displayLarge() -> Font {
            .system(size: 76, weight: .bold, design: .rounded)
        }

        static func headlineLarge() -> Font {
            .system(size: 28, weight: .bold, design: .rounded)
        }

        static func headlineMedium() -> Font {
            .system(size: 21, weight: .bold, design: .rounded)
        }

        static func titleLarge() -> Font {
            .system(size: 18, weight: .semibold, design: .rounded)
        }

        static func bodyLarge() -> Font {
            .system(size: 15, weight: .medium, design: .rounded)
        }

        static func bodyMedium() -> Font {
            .system(size: 13, weight: .medium, design: .rounded)
        }

        static func labelMedium() -> Font {
            .system(size: 12, weight: .semibold, design: .rounded)
        }

        static func labelSmall() -> Font {
            .system(size: 11, weight: .semibold, design: .rounded)
        }
    }
}

// MARK: - Convenience View Modifiers (component-level)

extension View {
    /// Applies the standard glass card treatment using DESIGN tokens.
    func focusPetGlassCard(tint: Color = .glassNeutralTint) -> some View {
        self
            .padding(DesignTokens.Spacing.cardPadding)
            .appleGlassSurface(
                cornerRadius: DesignTokens.Rounded.xl,
                tint: tint,
                material: .regularMaterial
            )
    }

    /// Standard page outer padding.
    func focusPetPagePadding() -> some View {
        padding(DesignTokens.Spacing.page)
    }
}

// MARK: - Legacy layout constants bridged to tokens (temporary during migration)

enum FocusPetLayout {
    static let pagePadding: CGFloat = DesignTokens.Spacing.page
    static let sectionSpacing: CGFloat = DesignTokens.Spacing.section
    static let cardSpacing: CGFloat = DesignTokens.Spacing.cardGap
    static let cardPadding: CGFloat = DesignTokens.Spacing.cardPadding
    static let cardRadius: CGFloat = DesignTokens.Rounded.xl
    static let controlRadius: CGFloat = DesignTokens.Rounded.md
}
