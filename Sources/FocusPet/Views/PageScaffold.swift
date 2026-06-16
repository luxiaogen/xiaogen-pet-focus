import SwiftUI

enum FocusPetLayout {
    static let pagePadding: CGFloat = 32
    static let sectionSpacing: CGFloat = 24
    static let cardSpacing: CGFloat = 18
    static let cardPadding: CGFloat = 22
    static let cardRadius: CGFloat = 22
    static let controlRadius: CGFloat = 14
}

struct PageHeader: View {
    let title: String
    let subtitle: String
    let accent: Color

    init(title: String, subtitle: String, accent: Color) {
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.14))
                Circle()
                    .strokeBorder(accent.opacity(0.32), lineWidth: 1)
                Circle()
                    .fill(accent.gradient)
                    .frame(width: 12, height: 12)
            }
            .frame(width: 34, height: 34)
            .shadow(color: accent.opacity(0.18), radius: 12, y: 5)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
            .padding(FocusPetLayout.cardPadding)
            .appleGlassSurface(cornerRadius: FocusPetLayout.cardRadius, tint: tint, material: .regularMaterial)
            .overlay(alignment: .topLeading) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.8), .white.opacity(0.34)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 40, height: 4)
                    .padding(20)
            }
            .contentShape(RoundedRectangle(cornerRadius: FocusPetLayout.cardRadius, style: .continuous))
    }
}

struct AdaptivePair<Leading: View, Trailing: View>: View {
    let spacing: CGFloat
    let leading: Leading
    let trailing: Trailing

    init(spacing: CGFloat = FocusPetLayout.cardSpacing, @ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.spacing = spacing
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: spacing) {
                leading.frame(maxWidth: .infinity)
                trailing.frame(maxWidth: .infinity)
            }

            VStack(spacing: spacing) {
                leading.frame(maxWidth: .infinity)
                trailing.frame(maxWidth: .infinity)
            }
        }
    }
}

struct AdaptiveTriplet<First: View, Second: View, Third: View>: View {
    let spacing: CGFloat
    let first: First
    let second: Second
    let third: Third

    init(spacing: CGFloat = FocusPetLayout.cardSpacing, @ViewBuilder first: () -> First, @ViewBuilder second: () -> Second, @ViewBuilder third: () -> Third) {
        self.spacing = spacing
        self.first = first()
        self.second = second()
        self.third = third()
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: spacing) {
                first.frame(maxWidth: .infinity)
                second.frame(maxWidth: .infinity)
                third.frame(maxWidth: .infinity)
            }

            VStack(spacing: spacing) {
                first.frame(maxWidth: .infinity)
                second.frame(maxWidth: .infinity)
                third.frame(maxWidth: .infinity)
            }
        }
    }
}

struct FocusPetSectionTitle: View {
    let title: String
    let symbol: String
    let accent: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 24, height: 24)
                .background(accent.opacity(0.12), in: Circle())

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))

            Spacer()
        }
    }
}

struct FocusPetMetricTile: View {
    let title: String
    let value: String
    let symbol: String
    let accent: Color

    var body: some View {
        GlassCard(tint: accent) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.13), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

struct FocusPetInfoRow: View {
    let title: String
    let value: String
    let symbol: String?
    let accent: Color

    init(title: String, value: String, symbol: String? = nil, accent: Color = .glassNeutralTint) {
        self.title = title
        self.value = value
        self.symbol = symbol
        self.accent = accent
    }

    var body: some View {
        HStack(spacing: 10) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 22)
            }

            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 10)

            Text(value)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .font(.system(size: 13, weight: .medium))
    }
}

struct FocusPetProgressRow: View {
    let title: String
    let value: Double
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value * 100))%")
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)

            ProgressView(value: value)
                .tint(accent)
        }
    }
}

struct FocusPetSoftPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: FocusPetLayout.controlRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: FocusPetLayout.controlRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
            }
    }
}

struct FocusPetScrollPage<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(FocusPetLayout.pagePadding)
                    .frame(width: proxy.size.width, alignment: .leading)
            }
        }
    }
}

extension View {
    func focusPetPagePadding() -> some View {
        padding(FocusPetLayout.pagePadding)
    }
}
