import AppKit
import SwiftUI

@MainActor
final class FloatingPetWindowController {
    static let shared = FloatingPetWindowController()

    private var panel: NSPanel?
    private var onExpand: (() -> Void)?

    private init() { }

    func show(store: TimerStore, onExpand: @escaping () -> Void) {
        self.onExpand = onExpand

        if let panel {
            panel.orderFrontRegardless()
            return
        }

        let widget = FloatingPetWidget(store: store) { [weak self] in
            self?.onExpand?()
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 150, height: 150),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.contentView = NSHostingView(rootView: widget)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.setFrame(defaultFrame(for: panel), display: true)
        panel.orderFrontRegardless()

        self.panel = panel
    }

    func hide() {
        close()
    }

    func close() {
        panel?.close()
        panel = nil
        onExpand = nil
    }

    private func defaultFrame(for panel: NSPanel) -> NSRect {
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
        let size = panel.frame.size
        return NSRect(
            x: screenFrame.maxX - size.width - 28,
            y: screenFrame.minY + 88,
            width: size.width,
            height: size.height
        )
    }
}
