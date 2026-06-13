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
                Rectangle().fill(Color(nsColor: .windowBackgroundColor).opacity(0.5))
                Rectangle().fill(.ultraThinMaterial)
                LinearGradient(
                    colors: [
                        Color.focusCream.opacity(0.38),
                        Color.focusMist.opacity(0.24),
                        store.mode.ringColor.opacity(0.12),
                        Color.focusBlush.opacity(0.14)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [
                        store.mode.ringColor.opacity(0.2),
                        Color.focusCream.opacity(0.18),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 30,
                    endRadius: 640
                )
                RadialGradient(
                    colors: [
                        Color.breakSage.opacity(0.16),
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
                            store.mode.ringColor.opacity(0.88),
                            Color.breakSage.opacity(0.3),
                            .black.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.4
                )
        }
        .overlay(alignment: .top) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            store.mode.ringColor.opacity(0.95),
                            .white.opacity(0.45),
                            store.mode.ringColor.opacity(0.75)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 3)
                .padding(.horizontal, 18)
                .padding(.top, 2)
                .shadow(color: store.mode.ringColor.opacity(0.55), radius: 6, y: 1)
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
