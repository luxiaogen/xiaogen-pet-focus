import SwiftUI

struct PageHeader: View {
    let title: String
    let subtitle: String
    let accent: Color

    init(title: String, subtitle: String, accent: Color = .focusTomato) {
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Capsule()
                .fill(accent.gradient)
                .frame(width: 44, height: 5)
                .shadow(color: accent.opacity(0.24), radius: 8, y: 4)

            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

struct GlassCard<Content: View>: View {
    let tint: Color
    let content: Content

    init(tint: Color = .glassNeutralTint, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .padding(22)
            .appleGlassSurface(cornerRadius: 20, tint: tint, material: .regularMaterial)
            .overlay(alignment: .topLeading) {
                Capsule()
                    .fill(tint.opacity(0.62))
                    .frame(width: 34, height: 4)
                    .padding(18)
            }
    }
}

extension View {
    func focusPetPagePadding() -> some View {
        padding(32)
    }
}
