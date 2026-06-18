import SwiftUI

struct AppleGlassSurface: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color
    let material: Material
    let shadow: Bool

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(material)
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.36),
                                tint.opacity(0.08),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.72),
                                tint.opacity(0.38),
                                Color.black.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            }
            .shadow(color: shadow ? Color.black.opacity(0.08) : .clear, radius: shadow ? 18 : 0, y: shadow ? 12 : 0)
    }
}

extension View {
    func appleGlassSurface(
        cornerRadius: CGFloat = 18,
        tint: Color = .primary,
        material: Material = .regularMaterial,
        shadow: Bool = true
    ) -> some View {
        modifier(AppleGlassSurface(cornerRadius: cornerRadius, tint: tint, material: material, shadow: shadow))
    }
}
