import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var store: TimerStore
    @State private var selectedDestination: SidebarDestination = .timer
    @State private var window: NSWindow?

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selection: $selectedDestination, language: store.language)
                .frame(width: 92)

            Group {
                switch selectedDestination {
                case .timer:
                    TimerDashboardView(store: store, enterFloatingMode: enterFloatingMode)
                case .petHouse:
                    PetHouseView(store: store, enterFloatingMode: enterFloatingMode)
                case .statistics:
                    StatisticsView(store: store)
                case .settings:
                    SettingsView(store: store)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background {
            ZStack {
                Rectangle().fill(.regularMaterial)
                LinearGradient(
                    colors: [
                        store.mode.ringColor.opacity(0.16),
                        Color.breakSage.opacity(0.08),
                        Color(nsColor: .windowBackgroundColor).opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .ignoresSafeArea()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.glassStroke, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.18), radius: 26, y: 18)
        .background(WindowAccessor(window: $window).frame(width: 0, height: 0))
    }

    private func enterFloatingMode() {
        guard let window else { return }
        FloatingPetWindowController.shared.show(store: store) {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        window.orderOut(nil)
    }
}
