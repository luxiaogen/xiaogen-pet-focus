import SwiftUI

struct BottomTabBar: View {
    @Binding var selection: SidebarDestination
    let language: AppLanguage
    let theme: AppTheme
    @State private var hoveredDestination: SidebarDestination?

    var body: some View {
        HStack(spacing: 12) {
            navigationButtons
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.92))
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.14),
                            theme.accentColor.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.14), radius: 14, y: 8)
        .animation(.smooth(duration: 0.28), value: selection)
    }

    private var navigationButtons: some View {
        HStack(spacing: 8) {
            ForEach(SidebarDestination.allCases) { destination in
                let isSelected = selection == destination
                let isHovered = hoveredDestination == destination

                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        selection = destination
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: destination.symbolName)
                            .font(.system(size: 16, weight: .bold))
                            .frame(height: 18)

                        Text(destination.shortTitle(in: language))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .foregroundStyle(isSelected ? theme.accentColor : Color.primary.opacity(isHovered ? 0.76 : 0.56))
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? theme.accentColor.opacity(0.16) : Color.primary.opacity(isHovered ? 0.055 : 0.001))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(
                                            isSelected ? theme.accentColor.opacity(0.26) : Color.primary.opacity(isHovered ? 0.1 : 0),
                                            lineWidth: 1
                                        )
                                }
                        }
                        .scaleEffect(isHovered && !isSelected ? 1.015 : 1)
                }
                .buttonStyle(.plain)
                .help(destination.title(in: language))
                .frame(maxWidth: .infinity)
                .onHover { isHovering in
                    withAnimation(.smooth(duration: 0.16)) {
                        hoveredDestination = isHovering ? destination : nil
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
