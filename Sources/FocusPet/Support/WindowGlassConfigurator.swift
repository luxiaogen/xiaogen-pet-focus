import AppKit
import SwiftUI

struct WindowGlassConfigurator: View {
    let window: NSWindow?

    var body: some View {
        Color.clear
            .task(id: window?.windowNumber) {
                configure(window)
            }
    }

    private func configure(_ window: NSWindow?) {
        guard let window else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.hasShadow = true
    }
}
