import SwiftUI

struct FloatingPetWidget: View {
    @ObservedObject var store: TimerStore
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    let onExpand: () -> Void
    @State private var isHovering = false

    var body: some View {
        ZStack {
            PetView(pet: store.selectedPet, mode: store.mode, progress: store.progress, compact: true)
                .frame(width: 142, height: 142)

            VStack {
                if isHovering {
                    timerCapsule
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()

                if isHovering {
                    controls
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(6)
        }
        .frame(width: 150, height: 150)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.16)) {
                isHovering = hovering
            }
        }
    }

    private var timerCapsule: some View {
        HStack(spacing: 5) {
            Image(systemName: "timer")
            Text(store.formattedRemaining)
                .monospacedDigit()
        }
        .font(.system(size: 11, weight: .bold))
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(.regularMaterial, in: Capsule())
        .overlay {
            Capsule().stroke(Color.glassStroke, lineWidth: 1)
        }
    }

    private var controls: some View {
        HStack(spacing: 8) {
            Button {
                store.toggleRunning()
            } label: {
                Image(systemName: store.isRunning ? "pause.fill" : "play.fill")
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(FloatingControlButtonStyle(color: store.mode.ringColor(in: theme)))
            .help(store.isRunning ? languageText("Pause", "暂停") : languageText("Play", "播放"))

            Button {
                FloatingPetWindowController.shared.hide()
                onExpand()
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(FloatingControlButtonStyle(color: .secondary))
            .help(languageText("Expand", "展开"))
        }
    }

    private func languageText(_ english: String, _ chinese: String) -> String {
        store.language == .chinese ? chinese : english
    }
}

private struct FloatingControlButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.primary)
            .background(.regularMaterial, in: Circle())
            .overlay {
                Circle().stroke(color.opacity(0.35), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
    }
}
