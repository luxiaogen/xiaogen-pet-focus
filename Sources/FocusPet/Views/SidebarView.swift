import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarDestination
    let language: AppLanguage
    @State private var hoveredDestination: SidebarDestination?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.focusTomato.opacity(0.72))
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.34), lineWidth: 0.8)
                }
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
                .padding(.top, 30)

            VStack(spacing: 12) {
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
                            .frame(width: 42, height: 42)
                            .foregroundStyle(isSelected ? Color.focusTomato.opacity(0.88) : Color.focusInk.opacity(isHovered ? 0.72 : 0.5))
                            .background {
                                Circle()
                                    .fill(isSelected ? Color.white.opacity(0.34) : Color.white.opacity(isHovered ? 0.22 : 0.08))
                                    .background(.ultraThinMaterial, in: Circle())
                                    .overlay {
                                        Circle()
                                            .strokeBorder(
                                                isSelected ? Color.focusTomato.opacity(0.38) : Color.white.opacity(isHovered ? 0.34 : 0.2),
                                                lineWidth: 0.8
                                            )
                                    }
                                    .shadow(color: isSelected ? Color.focusTomato.opacity(0.12) : .clear, radius: 8, y: 4)
                            }
                            .scaleEffect(isHovered && !isSelected ? 1.03 : 1)
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
                        .fill(Color.focusCream.opacity(0.1))
                }
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.focusCream.opacity(0.12),
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
                        colors: [.white.opacity(0.34), .white.opacity(0.1), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1)
        }
        .animation(.smooth(duration: 0.28), value: selection)
    }
}
