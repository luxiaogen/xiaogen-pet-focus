import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var store: TimerStore
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    @State private var selectedDestination: SidebarDestination = .timer
    @State private var window: NSWindow?

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selection: $selectedDestination, language: store.language, theme: theme)
                .frame(width: 72)

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
            .transition(.opacity.combined(with: .scale(scale: 0.985)))
        }
        .background {
            ZStack {
                Rectangle().fill(Color(nsColor: .windowBackgroundColor).opacity(0.5))
                Rectangle().fill(.ultraThinMaterial)
                LinearGradient(
                    colors: [
                        theme.creamColor.opacity(0.38),
                        theme.mistColor.opacity(0.24),
                        store.mode.ringColor(in: theme).opacity(0.12),
                        theme.blushColor.opacity(0.14)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [
                        store.mode.ringColor(in: theme).opacity(0.2),
                        theme.creamColor.opacity(0.18),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 30,
                    endRadius: 640
                )
                RadialGradient(
                    colors: [
                        theme.breakColor.opacity(0.16),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadius: 60,
                    endRadius: 520
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
                            .white.opacity(0.72),
                            store.mode.ringColor(in: theme).opacity(0.88),
                            theme.breakColor.opacity(0.3),
                            .black.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.4
                )
        }
        .shadow(color: .black.opacity(0.16), radius: 30, y: 20)
        .shadow(color: store.mode.ringColor(in: theme).opacity(0.18), radius: 24, y: 10)
        .animation(.smooth(duration: 0.32), value: selectedDestination)
        .animation(.smooth(duration: 0.42), value: store.mode)
        .background {
            WindowAccessor(window: $window).frame(width: 0, height: 0)
            WindowGlassConfigurator(window: window).frame(width: 0, height: 0)
        }
        .ignoresSafeArea(.container, edges: .top)
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
