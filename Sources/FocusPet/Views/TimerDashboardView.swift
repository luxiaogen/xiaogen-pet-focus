import SwiftUI

struct TimerDashboardView: View {
    @ObservedObject var store: TimerStore
    let enterFloatingMode: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            HStack(alignment: .top, spacing: 24) {
                timerPanel
                    .frame(maxWidth: .infinity)

                companionPanel
                    .frame(width: 250)
            }
        }
        .padding(32)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("FocusPet")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text(store.mode.slogan)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Picker("Pet", selection: $store.selectedPet) {
                ForEach(PetKind.allCases) { pet in
                    Label(pet.title, systemImage: pet.symbolName).tag(pet)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 170)
        }
    }

    private var timerPanel: some View {
        VStack(spacing: 26) {
            Picker("Task", selection: $store.selectedTask) {
                ForEach(store.tasks, id: \.self) { task in
                    Text(task).tag(task)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 250)

            ZStack {
                CircularProgressRing(progress: store.progress, color: store.mode.ringColor)
                    .frame(width: 300, height: 300)

                VStack(spacing: 8) {
                    Text(store.formattedRemaining)
                        .font(.system(size: 76, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)

                    Text("\(store.mode.title) Session")
                        .font(.system(size: 13, weight: .semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxHeight: .infinity)

            HStack(spacing: 12) {
                Button {
                    store.toggleRunning()
                } label: {
                    Label(store.primaryActionTitle, systemImage: store.primaryActionSymbol)
                        .font(.system(size: 15, weight: .bold))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 13)
                        .frame(minWidth: 164)
                }
                .buttonStyle(CapsuleGradientButtonStyle(color: store.mode.ringColor))

                Button {
                    enterFloatingMode()
                } label: {
                    Label("Switch to Pet Floating Mode", systemImage: "pip.enter")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                }
                .buttonStyle(GlassCapsuleButtonStyle())
            }

            modeControls
        }
        .padding(30)
        .frame(maxHeight: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.glassStroke, lineWidth: 1)
        }
    }

    private var modeControls: some View {
        HStack(spacing: 10) {
            Button("Focus") {
                store.startFocus()
            }
            .buttonStyle(SmallModeButtonStyle(isSelected: store.mode == .focus, color: .focusTomato))

            Button("Break") {
                store.startBreak()
            }
            .buttonStyle(SmallModeButtonStyle(isSelected: store.mode == .breakTime, color: .breakSage))

            Button("Reset") {
                store.resetCurrentMode()
            }
            .buttonStyle(SmallModeButtonStyle(isSelected: false, color: .secondary))
        }
    }

    private var companionPanel: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Companion")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundStyle(store.mode.ringColor)
            }

            PetView(kind: store.selectedPet, mode: store.mode, progress: store.progress, compact: false)
                .frame(width: 188, height: 188)

            VStack(spacing: 4) {
                Text(store.selectedPet.title)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                Text(statusText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Daily Goal")
                    Spacer()
                    Text("\(store.completedSessions) / 4")
                        .fontWeight(.bold)
                }
                .font(.system(size: 13, weight: .semibold))

                ProgressView(value: min(Double(store.completedSessions) / 4, 1))
                    .tint(store.mode.ringColor)
            }
        }
        .padding(22)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.glassStroke, lineWidth: 1)
        }
    }

    private var statusText: String {
        switch store.mode {
        case .focus:
            "Working quietly"
        case .breakTime:
            "Taking a snack break"
        case .celebration:
            "Celebrating with you"
        }
    }
}

struct CapsuleGradientButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background {
                Capsule()
                    .fill(LinearGradient(colors: [color, color.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .shadow(color: color.opacity(configuration.isPressed ? 0.1 : 0.26), radius: 14, y: 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct GlassCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(.thinMaterial, in: Capsule())
            .overlay {
                Capsule().stroke(Color.glassStroke, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SmallModeButtonStyle: ButtonStyle {
    let isSelected: Bool
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(isSelected ? color : Color.primary.opacity(0.08))
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
