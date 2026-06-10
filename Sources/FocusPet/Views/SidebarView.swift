import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarDestination
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.focusTomato)
                .padding(.top, 28)

            VStack(spacing: 10) {
                ForEach(SidebarDestination.allCases) { destination in
                    Button {
                        selection = destination
                    } label: {
                        Image(systemName: destination.symbolName)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .foregroundStyle(selection == destination ? Color.white : Color.secondary)
                            .background {
                                if selection == destination {
                                    Capsule()
                                        .fill(Color.focusTomato.gradient)
                                } else {
                                    Capsule()
                                        .fill(.thinMaterial)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .help(destination.title(in: language))
                }
            }

            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 1)
        }
    }
}
