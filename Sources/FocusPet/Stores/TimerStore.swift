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
    @Published private(set) var completedSessions = 0

    let tasks = [
        "Design System Update",
        "Write Focus Notes",
        "Prototype Pet Motion",
        "Inbox Cleanup"
    ]

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
        isRunning ? "Pause" : "Start Focus"
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
