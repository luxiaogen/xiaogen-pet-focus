import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarDestination
    let language: AppLanguage
    @State private var hoveredDestination: SidebarDestination?

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.focusTomato.opacity(0.62))
                .frame(width: 34, height: 34)
                .padding(.top, 34)

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
                            .font(.system(size: 17, weight: .semibold))
                            .frame(width: 38, height: 38)
                            .foregroundStyle(isSelected ? Color.focusTomato.opacity(0.74) : Color.focusInk.opacity(isHovered ? 0.62 : 0.44))
                            .background {
                                Circle()
                                    .fill(isSelected ? Color.white.opacity(0.22) : Color.white.opacity(isHovered ? 0.16 : 0.001))
                                    .overlay {
                                        Circle()
                                            .strokeBorder(
                                                isSelected ? Color.focusTomato.opacity(0.22) : Color.white.opacity(isHovered ? 0.24 : 0),
                                                lineWidth: 0.8
                                            )
                                    }
                                    .shadow(color: isSelected ? Color.focusTomato.opacity(0.06) : .clear, radius: 7, y: 3)
                            }
                            .scaleEffect(isHovered && !isSelected ? 1.025 : 1)
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
        .animation(.smooth(duration: 0.28), value: selection)
    }
}
