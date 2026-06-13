import SwiftUI

struct TimerDashboardView: View {
    @ObservedObject var store: TimerStore
    let enterFloatingMode: () -> Void
    @AppStorage("timerDashboard.timerPanelX") private var timerPanelX = 0.43
    @AppStorage("timerDashboard.timerPanelY") private var timerPanelY = 0.54
    @AppStorage("timerDashboard.companionPanelX") private var companionPanelX = 0.84
    @AppStorage("timerDashboard.companionPanelY") private var companionPanelY = 0.54
    @State private var timerInput = ""
    @FocusState private var isTimerInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            GeometryReader { proxy in
                let timerSize = panelSize(for: proxy.size, preferredWidth: 640, minimumWidth: 460)
                let companionSize = CGSize(width: min(270, max(230, proxy.size.width * 0.22)), height: timerSize.height)

                ZStack {
                    DraggableDashboardPanel(
                        normalizedX: $timerPanelX,
                        normalizedY: $timerPanelY,
                        containerSize: proxy.size,
                        panelSize: timerSize,
                        dragHelp: languageText("Drag to arrange", "拖动调整布局")
                    ) {
                        timerPanel
                    }

                    DraggableDashboardPanel(
                        normalizedX: $companionPanelX,
                        normalizedY: $companionPanelY,
                        containerSize: proxy.size,
                        panelSize: companionSize,
                        dragHelp: languageText("Drag to arrange", "拖动调整布局")
                    ) {
                        companionPanel
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(32)
        .onAppear {
            timerInput = store.formattedRemaining
        }
        .onChange(of: store.formattedRemaining) { _, newValue in
            guard !isTimerInputFocused else { return }
            timerInput = newValue
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("FocusPet")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text(store.mode.slogan(in: store.language))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Picker("Language", selection: $store.language) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.shortTitle).tag(language)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 126)
            .labelsHidden()

            Picker(languageText("Pet", "宠物"), selection: $store.selectedPetID) {
                ForEach(store.availablePets) { pet in
                    Label(pet.title(in: store.language), systemImage: pet.symbolName).tag(pet.id)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 170)
        }
    }

    private var timerPanel: some View {
        VStack(spacing: 26) {
            Picker(languageText("Task", "任务"), selection: $store.selectedTask) {
                ForEach(store.tasks, id: \.self) { task in
                    Text(store.localizedTaskTitle(for: task)).tag(task)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 250)

            ZStack {
                CircularProgressRing(progress: store.progress, color: store.mode.ringColor)
                    .frame(width: 300, height: 300)

                VStack(spacing: 8) {
                    TextField("", text: $timerInput)
                        .font(.system(size: 76, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .focused($isTimerInputFocused)
                        .frame(width: 320)
                        .help(languageText("Edit time", "编辑时间"))
                        .onSubmit(commitTimerInput)
                        .onChange(of: isTimerInputFocused) { _, isFocused in
                            if isFocused {
                                timerInput = store.formattedRemaining
                            } else {
                                commitTimerInput()
                            }
                        }

                    Text(languageText("\(store.mode.title(in: store.language)) Session", "\(store.mode.title(in: store.language))模式"))
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
                    Label(languageText("Switch to Pet Floating Mode", "切换到宠物悬浮模式"), systemImage: "pip.enter")
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
        .appleGlassSurface(cornerRadius: 22, tint: store.mode.ringColor, material: .regularMaterial)
    }

    private var modeControls: some View {
        HStack(spacing: 10) {
            Button(store.mode == .focus ? store.mode.title(in: store.language) : languageText("Focus", "专注")) {
                store.startFocus()
            }
            .buttonStyle(SmallModeButtonStyle(isSelected: store.mode == .focus, color: .focusTomato))

            Button(store.mode == .breakTime ? store.mode.title(in: store.language) : languageText("Break", "休息")) {
                store.startBreak()
            }
            .buttonStyle(SmallModeButtonStyle(isSelected: store.mode == .breakTime, color: .breakSage))

            Button(languageText("Reset", "重置")) {
                store.resetCurrentMode()
            }
            .buttonStyle(SmallModeButtonStyle(isSelected: false, color: .secondary))
        }
    }

    private var companionPanel: some View {
        VStack(spacing: 20) {
            HStack {
                Text(languageText("Companion", "专注伙伴"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundStyle(store.mode.ringColor)
            }

            PetView(pet: store.selectedPet, mode: store.mode, progress: store.progress, compact: false)
                .frame(width: 188, height: 188)

            VStack(spacing: 4) {
                Text(store.selectedPet.title(in: store.language))
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                Text(statusText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(languageText("Daily Goal", "今日目标"))
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
        .appleGlassSurface(cornerRadius: 22, tint: store.mode.ringColor, material: .regularMaterial)
    }

    private var statusText: String {
        switch store.mode {
        case .focus:
            languageText("Working quietly", "安静专注中")
        case .breakTime:
            languageText("Taking a snack break", "正在补充能量")
        case .celebration:
            languageText("Celebrating with you", "和你一起庆祝")
        }
    }

    private func languageText(_ english: String, _ chinese: String) -> String {
        store.language == .chinese ? chinese : english
    }

    private func panelSize(for containerSize: CGSize, preferredWidth: CGFloat, minimumWidth: CGFloat) -> CGSize {
        let width = min(preferredWidth, max(minimumWidth, containerSize.width * 0.52))
        let height = min(max(470, containerSize.height - 4), max(360, containerSize.height))
        return CGSize(width: width, height: height)
    }

    private func commitTimerInput() {
        guard let seconds = seconds(from: timerInput) else {
            timerInput = store.formattedRemaining
            return
        }

        store.setCurrentModeDuration(seconds)
        timerInput = store.formattedRemaining
    }

    private func seconds(from input: String) -> TimeInterval? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let parts = trimmed.split(separator: ":").map(String.init)
        guard (1...3).contains(parts.count),
              parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy(\.isNumber) })
        else {
            return nil
        }

        let values = parts.compactMap(Int.init)
        guard values.count == parts.count else { return nil }

        switch values.count {
        case 1:
            return TimeInterval(values[0] * 60)
        case 2:
            guard values[1] < 60 else { return nil }
            return TimeInterval(values[0] * 60 + values[1])
        case 3:
            guard values[1] < 60, values[2] < 60 else { return nil }
            return TimeInterval(values[0] * 3600 + values[1] * 60 + values[2])
        default:
            return nil
        }
    }
}

private struct DraggableDashboardPanel<Content: View>: View {
    @Binding var normalizedX: Double
    @Binding var normalizedY: Double
    let containerSize: CGSize
    let panelSize: CGSize
    let dragHelp: String
    @ViewBuilder let content: Content
    @GestureState private var dragTranslation: CGSize = .zero

    var body: some View {
        content
            .frame(width: panelSize.width, height: panelSize.height)
            .overlay(alignment: .topLeading) {
                Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.72))
                    .frame(width: 28, height: 28)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay {
                        Circle().stroke(Color.white.opacity(0.32), lineWidth: 0.8)
                    }
                    .padding(12)
                    .contentShape(Circle())
                    .help(dragHelp)
                    .gesture(dragGesture)
            }
            .position(currentPosition)
            .animation(.spring(response: 0.28, dampingFraction: 0.86), value: dragTranslation)
    }

    private var currentPosition: CGPoint {
        clampedPosition(
            x: normalizedX * containerSize.width + dragTranslation.width,
            y: normalizedY * containerSize.height + dragTranslation.height
        )
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let newPosition = clampedPosition(
                    x: normalizedX * containerSize.width + value.translation.width,
                    y: normalizedY * containerSize.height + value.translation.height
                )
                normalizedX = normalized(newPosition.x, in: containerSize.width)
                normalizedY = normalized(newPosition.y, in: containerSize.height)
            }
    }

    private func clampedPosition(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(
            x: clamp(x, minimum: panelSize.width / 2, maximum: containerSize.width - panelSize.width / 2),
            y: clamp(y, minimum: panelSize.height / 2, maximum: containerSize.height - panelSize.height / 2)
        )
    }

    private func normalized(_ value: CGFloat, in length: CGFloat) -> Double {
        guard length > 0 else { return 0.5 }
        return Double(value / length)
    }

    private func clamp(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        guard minimum <= maximum else { return (minimum + maximum) / 2 }
        return min(max(value, minimum), maximum)
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
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.55), lineWidth: 0.9)
                    }
            }
            .shadow(color: color.opacity(configuration.isPressed ? 0.1 : 0.26), radius: 14, y: 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct GlassCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.68), .white.opacity(0.18), .black.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.06), radius: 9, y: 5)
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
                    .fill(isSelected ? color : Color.primary.opacity(0.06))
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.white.opacity(isSelected ? 0.42 : 0.22), lineWidth: 0.8)
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
