import Foundation

@MainActor
final class TimerStore: ObservableObject {
    @Published var focusDuration: TimeInterval = 25 * 60
    @Published var breakDuration: TimeInterval = 5 * 60
    @Published var remainingSeconds: TimeInterval = 25 * 60
    @Published var mode: PomodoroMode = .focus
    @Published var isRunning = false
    @Published var selectedTask = "Design System Update"
    @Published var selectedPet: PetKind = .panda
    @Published var language: AppLanguage = .english
    @Published private(set) var completedSessions = 0

    let tasks = [
        "Design System Update",
        "Write Focus Notes",
        "Prototype Pet Motion",
        "Inbox Cleanup"
    ]

    var localizedTasks: [String] {
        switch language {
        case .english:
            tasks
        case .chinese:
            ["设计系统更新", "写专注笔记", "原型桌宠动效", "清理收件箱"]
        }
    }

    private var timer: Timer?

    var totalSeconds: TimeInterval {
        switch mode {
        case .focus:
            focusDuration
        case .breakTime:
            breakDuration
        case .celebration:
            focusDuration
        }
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return max(0, min(1, 1 - remainingSeconds / totalSeconds))
    }

    var formattedRemaining: String {
        let seconds = max(0, Int(remainingSeconds.rounded(.up)))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var primaryActionTitle: String {
        switch language {
        case .english:
            isRunning ? "Pause" : "Start Focus"
        case .chinese:
            isRunning ? "暂停" : "开始专注"
        }
    }

    var primaryActionSymbol: String {
        isRunning ? "pause.fill" : "play.fill"
    }

    func toggleRunning() {
        isRunning ? pause() : start()
    }

    func start() {
        if mode == .celebration {
            startFocus()
        }
        isRunning = true
        scheduleTimer()
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func startFocus() {
        pause()
        mode = .focus
        remainingSeconds = focusDuration
    }

    func startBreak() {
        pause()
        mode = .breakTime
        remainingSeconds = breakDuration
    }

    func resetCurrentMode() {
        pause()
        remainingSeconds = totalSeconds
    }

    func setCurrentModeDuration(_ seconds: TimeInterval) {
        let clampedSeconds = max(60, min(12 * 60 * 60, seconds.rounded()))
        let shouldResume = isRunning
        pause()

        switch mode {
        case .focus:
            focusDuration = clampedSeconds
        case .breakTime:
            breakDuration = clampedSeconds
        case .celebration:
            mode = .focus
            focusDuration = clampedSeconds
        }

        remainingSeconds = clampedSeconds

        if shouldResume {
            start()
        }
    }

    func localizedTaskTitle(for task: String) -> String {
        guard let index = tasks.firstIndex(of: task) else { return task }
        return localizedTasks[index]
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard isRunning else { return }
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            completeCurrentSession()
        }
    }

    private func completeCurrentSession() {
        pause()
        remainingSeconds = 0
        if mode == .focus {
            completedSessions += 1
        }
        mode = .celebration
    }
}
