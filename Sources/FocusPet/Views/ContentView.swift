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
                Rectangle().fill(Color(nsColor: .windowBackgroundColor).opacity(0.62))
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(Color.white.opacity(0.22))
                LinearGradient(
                    colors: [
                        store.mode.ringColor.opacity(0.12),
                        Color.white.opacity(0.18),
                        Color.breakSage.opacity(0.08),
                        Color.white.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.28),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 40,
                    endRadius: 580
                )
            }
            .ignoresSafeArea()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.82),
                            store.mode.ringColor.opacity(0.88),
                            .white.opacity(0.24),
                            .black.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.4
                )
        }
        .shadow(color: .black.opacity(0.16), radius: 30, y: 20)
        .shadow(color: store.mode.ringColor.opacity(0.18), radius: 24, y: 10)
        .background {
            WindowAccessor(window: $window).frame(width: 0, height: 0)
            WindowGlassConfigurator(window: window).frame(width: 0, height: 0)
        }
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
