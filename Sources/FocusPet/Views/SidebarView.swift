import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarDestination
    let language: AppLanguage
    @State private var hoveredDestination: SidebarDestination?

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.focusCream, Color.focusTomato)
                .shadow(color: Color.focusTomato.opacity(0.24), radius: 10, y: 4)
                .padding(.top, 28)

            VStack(spacing: 10) {
                ForEach(SidebarDestination.allCases) { destination in
                    let isSelected = selection == destination
                    let isHovered = hoveredDestination == destination

                    Button {
                        withAnimation(.smooth(duration: 0.2)) {
                            selection = destination
                        }
                    } label: {
                        Image(systemName: destination.symbolName)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .foregroundStyle(isSelected ? Color.white : Color.focusInk.opacity(isHovered ? 0.78 : 0.58))
                            .background {
                                if isSelected {
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.focusTomato, Color.breakSage.opacity(0.9)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay {
                                            Capsule()
                                                .strokeBorder(Color.white.opacity(0.55), lineWidth: 0.8)
                                        }
                                        .shadow(color: Color.focusTomato.opacity(0.32), radius: 12, y: 7)
                                } else {
                                    Capsule()
                                        .fill(isHovered ? Color.white.opacity(0.28) : Color.white.opacity(0.14))
                                        .background(.ultraThinMaterial, in: Capsule())
                                        .overlay {
                                            Capsule()
                                                .strokeBorder(Color.white.opacity(isHovered ? 0.42 : 0.28), lineWidth: 0.8)
                                        }
                                }
                            }
                            .scaleEffect(isHovered && !isSelected ? 1.04 : 1)
                    }
                    .buttonStyle(.plain)
                    .help(destination.title(in: language))
                    .onHover { isHovering in
                        withAnimation(.smooth(duration: 0.16)) {
                            hoveredDestination = isHovering ? destination : nil
                        }
                    }
                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Rectangle()
                        .fill(Color.focusCream.opacity(0.16))
                }
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.focusCream.opacity(0.34),
                            Color.focusTomato.opacity(0.1),
                            Color.breakSage.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.52), Color.breakSage.opacity(0.16), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1)
        }
        .animation(.smooth(duration: 0.28), value: selection)
    }
}
