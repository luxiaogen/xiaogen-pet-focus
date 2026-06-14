import SwiftUI

struct TimerDashboardView: View {
    @ObservedObject var store: TimerStore
    let enterFloatingMode: () -> Void
    @State private var timerInput = ""
    @FocusState private var isTimerInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            GeometryReader { proxy in
                if proxy.size.width >= 900 {
                    HStack(alignment: .top, spacing: 24) {
                        timerPanel
                            .frame(minWidth: 560, maxWidth: .infinity, maxHeight: .infinity)

                        companionPanel
                            .frame(width: min(310, max(270, proxy.size.width * 0.26)), height: proxy.size.height)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 18) {
                            timerPanel
                                .frame(maxWidth: .infinity, minHeight: 620)

                            companionPanel
                                .frame(maxWidth: .infinity, minHeight: 430)
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                }
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
            PageHeader(title: "FocusPet", subtitle: store.mode.slogan(in: store.language), accent: store.mode.ringColor)

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
        VStack(spacing: 18) {
            Picker(languageText("Task", "任务"), selection: $store.selectedTask) {
                ForEach(store.tasks, id: \.self) { task in
                    Text(store.localizedTaskTitle(for: task)).tag(task)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 250)

            sessionPlanner
            focusQueue

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
        .appleGlassSurface(cornerRadius: 24, tint: store.mode.ringColor, material: .regularMaterial)
        .overlay(alignment: .topLeading) {
            Capsule()
                .fill(store.mode.ringColor.opacity(0.62))
                .frame(width: 38, height: 4)
                .padding(20)
        }
        .clipped()
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

    private var sessionPlanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text(languageText("Session Plan", "本轮计划"))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Text(store.localizedTaskTitle(for: store.selectedTask))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ForEach([15, 25, 45], id: \.self) { minutes in
                Button {
                    store.setCurrentModeDuration(TimeInterval(minutes * 60))
                } label: {
                    Text("\(minutes)m")
                        .frame(width: 46)
                }
                .buttonStyle(QuickDurationButtonStyle(isSelected: Int(store.totalSeconds / 60) == minutes, color: store.mode.ringColor))
                .help(languageText("Set timer to \(minutes) minutes", "设置为 \(minutes) 分钟"))
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
        }
    }

    private var focusQueue: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(languageText("Focus Queue", "专注队列"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Spacer()
                Text("\(store.tasks.count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                ForEach(store.tasks.prefix(3), id: \.self) { task in
                    Button {
                        store.selectedTask = task
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: store.selectedTask == task ? "checkmark.circle.fill" : "circle")
                            Text(store.localizedTaskTitle(for: task))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(QueueTaskButtonStyle(isSelected: store.selectedTask == task, color: store.mode.ringColor))
                    .help(store.localizedTaskTitle(for: task))
                }
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.8)
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

            companionCareModule

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
        .appleGlassSurface(cornerRadius: 24, tint: store.mode.ringColor, material: .regularMaterial)
        .overlay(alignment: .topLeading) {
            Capsule()
                .fill(store.mode.ringColor.opacity(0.62))
                .frame(width: 34, height: 4)
                .padding(18)
        }
        .clipped()
    }

    private var companionCareModule: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(languageText("Care Status", "照顾状态"))
                .font(.system(size: 13, weight: .bold, design: .rounded))

            careRow(label: languageText("Energy", "能量"), value: store.isRunning ? 0.68 : 0.86, color: .breakSage)
            careRow(label: languageText("Bond", "亲密度"), value: min(1, 0.42 + Double(store.completedSessions) * 0.12), color: store.mode.ringColor)
        }
        .padding(12)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
        }
    }

    private func careRow(label: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                Spacer()
                Text("\(Int(value * 100))%")
                    .fontWeight(.bold)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)

            ProgressView(value: value)
                .tint(color)
        }
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

private struct QuickDurationButtonStyle: ButtonStyle {
    let isSelected: Bool
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.78))
            .padding(.vertical, 7)
            .background {
                Capsule()
                    .fill(isSelected ? color : Color.white.opacity(0.22))
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.white.opacity(isSelected ? 0.42 : 0.28), lineWidth: 0.8)
                    }
            }
            .shadow(color: isSelected ? color.opacity(0.22) : .clear, radius: 9, y: 5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

private struct QueueTaskButtonStyle: ButtonStyle {
    let isSelected: Bool
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.74))
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? color : Color.white.opacity(0.18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color.white.opacity(isSelected ? 0.42 : 0.18), lineWidth: 0.8)
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
