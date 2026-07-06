import AppKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var store: TimerStore
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    @State private var selectedDestination: SidebarDestination = .timer
    @State private var window: NSWindow?

    var body: some View {
        VStack(spacing: 0) {
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

            BottomTabBar(selection: $selectedDestination, language: store.language, theme: theme)
                .padding(.horizontal, DesignTokens.Spacing.xl)
                .padding(.top, DesignTokens.Spacing.sm)
                .padding(.bottom, DesignTokens.Spacing.lg)
        }
        .background {
            ZStack {
                Rectangle().fill(Color(nsColor: .windowBackgroundColor).opacity(0.82))
                LinearGradient(
                    colors: [
                        theme.creamColor.opacity(0.26),
                        theme.mistColor.opacity(0.16),
                        store.mode.ringColor(in: theme).opacity(0.08),
                        theme.blushColor.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .ignoresSafeArea()
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Rounded.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Rounded.xl, style: .continuous)
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
        .shadow(color: .black.opacity(0.14), radius: 22, y: 16)
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
