import SwiftUI

struct TimerDashboardView: View {
    @ObservedObject var store: TimerStore
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    let enterFloatingMode: () -> Void
    @State private var timerInput = ""
    @FocusState private var isTimerInputFocused: Bool

    @State private var newTaskTitle = ""
    @FocusState private var isNewTaskFieldFocused: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: FocusPetLayout.sectionSpacing) {
            header

            GeometryReader { proxy in
                if proxy.size.width >= 900 {
                    HStack(alignment: .top, spacing: FocusPetLayout.sectionSpacing) {
                        timerPanel
                            .frame(minWidth: 560, maxWidth: .infinity, maxHeight: .infinity)

                        companionPanel
                            .frame(width: min(310, max(270, proxy.size.width * 0.26)), height: proxy.size.height)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: FocusPetLayout.cardSpacing) {
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
        .padding(FocusPetLayout.pagePadding)
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
            PageHeader(title: "FocusPet", subtitle: store.mode.slogan(in: store.language), accent: store.mode.ringColor(in: theme))

            Spacer()

            Picker(languageText("Pet", "宠物"), selection: $store.selectedPetID) {
                ForEach(store.availablePets) { pet in
                    Label(pet.title(in: store.language), systemImage: pet.symbolName).tag(pet.id)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 170)
        }
    }

    private func commitNewTask() {
        guard store.addTask(title: newTaskTitle) != nil else {
            newTaskTitle = ""
            return
        }
        newTaskTitle = ""
    }

    private var timerPanel: some View {
        VStack(spacing: 18) {
            HStack {
                FocusPetSectionTitle(title: languageText("Timer", "计时器"), symbol: "timer", accent: store.mode.ringColor(in: theme))

                Picker(languageText("Task", "任务"), selection: $store.selectedTaskID) {
                    ForEach(store.tasks) { task in
                        Text(store.localizedTaskTitle(for: task.id)).tag(task.id)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 240)
            }

            sessionPlanner
            focusQueue

            ZStack {
                CircularProgressRing(progress: store.progress, color: store.mode.ringColor(in: theme))
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
                .buttonStyle(CapsuleGradientButtonStyle(color: store.mode.ringColor(in: theme)))

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
        .appleGlassSurface(cornerRadius: FocusPetLayout.cardRadius + 2, tint: store.mode.ringColor(in: theme), material: .regularMaterial)
    }

    private var modeControls: some View {
        HStack(spacing: 10) {
            Button(store.mode == .focus ? store.mode.title(in: store.language) : languageText("Focus", "专注")) {
                store.startFocus()
            }
            .buttonStyle(SmallModeButtonStyle(isSelected: store.mode == .focus, color: theme.accentColor))

            Button(store.mode == .breakTime ? store.mode.title(in: store.language) : languageText("Break", "休息")) {
                store.startBreak()
            }
            .buttonStyle(SmallModeButtonStyle(isSelected: store.mode == .breakTime, color: theme.breakColor))

            Button(languageText("Reset", "重置")) {
                store.resetCurrentMode()
            }
            .buttonStyle(SmallModeButtonStyle(isSelected: false, color: .secondary))
        }
    }

    private var sessionPlanner: some View {
        FocusPetSoftPanel {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(languageText("Session Plan", "本轮计划"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text(store.localizedTaskTitle(for: store.selectedTaskID))
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
                    .buttonStyle(QuickDurationButtonStyle(isSelected: Int(store.totalSeconds / 60) == minutes, color: store.mode.ringColor(in: theme)))
                    .help(languageText("Set timer to \(minutes) minutes", "设置为 \(minutes) 分钟"))
                }
            }
        }
    }

    private var focusQueue: some View {
        FocusPetSoftPanel {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(languageText("Focus Queue", "专注队列"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Spacer()
                    Text("\(store.tasks.count)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }

                VStack(spacing: 6) {
                    ForEach(Array(store.tasks.enumerated()), id: \.element.id) { index, task in
                        QueueTaskRow(
                            task: task,
                            isSelected: task.id == store.selectedTaskID,
                            color: store.mode.ringColor(in: theme),
                            title: store.localizedTaskTitle(for: task.id),
                            canDelete: !task.isBuiltIn,
                            onSelect: { store.selectedTaskID = task.id },
                            onDelete: { store.deleteTask(id: task.id) },
                            onDropped: { draggedID in
                                guard let from = store.tasks.firstIndex(where: { $0.id == draggedID }) else { return }
                                store.moveTask(from: from, to: index)
                            }
                        )
                    }
                }

                Divider()
                    .opacity(0.5)

                queueInputRow
            }
        }
    }

    private var queueInputRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "plus.circle")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)

            TextField(languageText("Add a task, press Enter", "输入任务后按回车添加"), text: $newTaskTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .focused($isNewTaskFieldFocused)
                .onSubmit(commitNewTask)

            if !newTaskTitle.isEmpty {
                Button {
                    commitNewTask()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(store.mode.ringColor(in: theme))
                }
                .buttonStyle(.plain)
                .help(languageText("Add", "添加"))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(
                    isNewTaskFieldFocused ? store.mode.ringColor(in: theme).opacity(0.5) : Color.white.opacity(0.2),
                    lineWidth: 0.8
                )
        }
    }

    private var companionPanel: some View {
        VStack(spacing: 20) {
            HStack {
                FocusPetSectionTitle(title: languageText("Companion", "专注伙伴"), symbol: "sparkles", accent: store.mode.ringColor(in: theme))
            }

            PetView(pet: store.selectedPet, mode: store.mode, progress: store.progress, compact: false, isLiveAnimating: store.isRunning)
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
                    .tint(store.mode.ringColor(in: theme))
            }
        }
        .padding(22)
        .appleGlassSurface(cornerRadius: FocusPetLayout.cardRadius + 2, tint: store.mode.ringColor(in: theme), material: .regularMaterial)
    }

    private var companionCareModule: some View {
        FocusPetSoftPanel {
            VStack(alignment: .leading, spacing: 10) {
                Text(languageText("Care Status", "照顾状态"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))

                FocusPetProgressRow(title: languageText("Energy", "能量"), value: store.isRunning ? 0.68 : 0.86, accent: theme.breakColor)
                FocusPetProgressRow(title: languageText("Bond", "亲密度"), value: min(1, 0.42 + Double(store.completedSessions) * 0.12), accent: store.mode.ringColor(in: theme))
            }
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

private struct QueueTaskRow: View {
    let task: FocusTask
    let isSelected: Bool
    let color: Color
    let title: String
    let canDelete: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    let onDropped: (String) -> Void
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    @State private var isHovering = false
    @State private var isDropTarget = false

    var body: some View {
        HStack(spacing: 8) {
            dragHandle

            Button(action: onSelect) {
                HStack(spacing: 6) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 11, weight: .bold))
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.84))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? color : Color.white.opacity(isHovering || isDropTarget ? 0.26 : 0.16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(
                                    isDropTarget ? color.opacity(0.6) : Color.white.opacity(isSelected ? 0.42 : 0.2),
                                    lineWidth: isDropTarget ? 1.4 : 0.8
                                )
                        }
                }
            }
            .buttonStyle(.plain)

            if canDelete && isHovering {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(theme.accentColor.opacity(0.82))
                        .frame(width: 22, height: 22)
                        .background(Color.white.opacity(0.22), in: Circle())
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
                .help("Delete")
            }
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.smooth(duration: 0.16)) {
                isHovering = hovering
            }
        }
        .draggable(task.id) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                Text(title)
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isSelected ? color : Color.primary.opacity(0.16), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .dropDestination(for: String.self) { items, _ in
            guard let draggedID = items.first, draggedID != task.id else { return false }
            DispatchQueue.main.async {
                onDropped(draggedID)
            }
            return true
        } isTargeted: { hovering in
            withAnimation(.smooth(duration: 0.18)) {
                isDropTarget = hovering
            }
        }
    }

    private var dragHandle: some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.tertiary)
            .opacity(isHovering ? 1 : 0.4)
            .frame(width: 12)
            .help("Drag to reorder")
    }
}
