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
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(0.3))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint.opacity(0.05))
                    }
                    .overlay {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.42),
                                Color.white.opacity(0.16),
                                Color.white.opacity(0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(tint.opacity(0.22), lineWidth: 2.2)
                    .blur(radius: 0.4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.84),
                                tint.opacity(0.72),
                                Color.white.opacity(0.28)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            }
            .shadow(color: shadow ? Color.black.opacity(0.08) : .clear, radius: shadow ? 18 : 0, y: shadow ? 12 : 0)
            .shadow(color: shadow ? tint.opacity(0.14) : .clear, radius: shadow ? 24 : 0, y: shadow ? 8 : 0)
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
