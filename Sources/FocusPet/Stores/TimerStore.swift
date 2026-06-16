import Foundation

@MainActor
final class TimerStore: ObservableObject {
    @Published var focusDuration: TimeInterval = 25 * 60
    @Published var breakDuration: TimeInterval = 5 * 60
    @Published var remainingSeconds: TimeInterval = 25 * 60
    @Published var mode: PomodoroMode = .focus
    @Published var isRunning = false
    @Published var selectedTaskID = FocusTask.defaultBuiltInID
    @Published private(set) var tasks: [FocusTask]
    @Published private(set) var importedPets: [ImportedPet]
    @Published var language: AppLanguage = .english
    @Published private(set) var completedSessions = 0
    @Published private(set) var sessionRecords: [SessionRecord] {
        didSet { invalidateStatsCache() }
    }

    private let petImportService = CodexPetImportService()
    private let taskStore = TaskStore()
    private let sessionLog = SessionLogService()

    // MARK: - Derived-state caches

    /// Lazily-computed aggregate statistics, invalidated only when
    /// `sessionRecords` changes (i.e. once per completed session). Avoids
    /// re-running O(N) filters/reduces on every per-second view refresh.
    private var _statsCache: SessionStats?
    private var _availablePetsCache: [PetProfile]?

    /// Memoized pet list, rebuilt only when imported pets change.
    private var cachedAvailablePets: [PetProfile] {
        if let cached = _availablePetsCache { return cached }
        let built = cachedAvailablePetsValue
        _availablePetsCache = built
        return built
    }

    private var cachedAvailablePetsValue: [PetProfile] {
        PetKind.allCases.map(PetProfile.init(kind:)) + importedPets.map(PetProfile.init(importedPet:))
    }

    private func invalidateStatsCache() {
        _statsCache = nil
    }

    private func invalidatePetCache() {
        _availablePetsCache = nil
    }

    /// Daily goal used across the dashboard and statistics views.
    static let dailyGoal = 4

    init() {
        let taskStore = TaskStore()
        let custom = taskStore.loadCustomTasks()
        let combined = FocusTask.builtIns + custom
        let orderedIDs = taskStore.loadOrder()
        tasks = Self.applyingOrder(orderedIDs, to: combined)
        importedPets = petImportService.loadImportedPets()
        sessionRecords = sessionLog.loadRecords()
    }

    /// Reorders `tasks` to match the saved manifest, appending any unknown
    /// ids at the end (preserves discovery of new tasks).
    private static func applyingOrder(_ orderedIDs: [String]?, to tasks: [FocusTask]) -> [FocusTask] {
        guard let orderedIDs, !orderedIDs.isEmpty else { return tasks }
        let byID = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
        var seen = Set<String>()
        var result: [FocusTask] = []
        for id in orderedIDs {
            if let task = byID[id] {
                result.append(task)
                seen.insert(id)
            }
        }
        for task in tasks where !seen.contains(task.id) {
            result.append(task)
        }
        return result
    }

    var selectedTask: FocusTask? {
        tasks.first { $0.id == selectedTaskID }
    }

    var availablePets: [PetProfile] {
        cachedAvailablePets
    }

    var selectedPet: PetProfile {
        availablePets.first { $0.id == selectedPetID } ?? PetProfile(kind: .panda)
    }

    @Published var selectedPetID = PetProfile(kind: .panda).id

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

    // MARK: - Task management

    func localizedTaskTitle(for id: String) -> String {
        guard let task = tasks.first(where: { $0.id == id }) else {
            return id
        }
        if language == .chinese, let localized = task.localizedTitle {
            return localized
        }
        return task.title
    }

    @discardableResult
    func addTask(title rawTitle: String) -> FocusTask? {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return nil }

        // De-duplicate against existing titles (case-insensitive).
        if tasks.contains(where: { $0.title.lowercased() == title.lowercased() }) {
            return nil
        }

        let task = FocusTask(title: title)
        tasks.append(task)
        do {
            try taskStore.save(task)
            persistTaskOrder()
        } catch {
            tasks.removeAll { $0.id == task.id }
            return nil
        }
        selectedTaskID = task.id
        return task
    }

    func deleteTask(id: String) {
        guard let task = tasks.first(where: { $0.id == id }), !task.isBuiltIn else { return }
        tasks.removeAll { $0.id == id }
        taskStore.delete(task)
        persistTaskOrder()
        if selectedTaskID == id, let first = tasks.first {
            selectedTaskID = first.id
        }
    }

    /// Moves a task from one index to another and persists the new ordering.
    func moveTask(from source: Int, to destination: Int) {
        guard source != destination,
              tasks.indices.contains(source)
        else { return }

        // .movePiece semantics: destination is the target index the item
        // should occupy after removal.
        var copy = tasks
        let task = copy.remove(at: source)
        let clampedDestination = min(max(destination, 0), copy.count)
        copy.insert(task, at: clampedDestination)
        tasks = copy
        persistTaskOrder()
    }

    private func persistTaskOrder() {
        taskStore.saveOrder(tasks.map(\.id))
    }

    // MARK: - Timer control

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

    @discardableResult
    func importCodexPet(from url: URL) throws -> ImportedPet {
        let importedPet = try petImportService.importPet(from: url)
        importedPets.removeAll { $0.id == importedPet.id }
        importedPets.append(importedPet)
        importedPets.sort { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        invalidatePetCache()
        selectedPetID = importedPet.id
        return importedPet
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

        let record = SessionRecord(
            mode: mode,
            taskID: selectedTaskID,
            taskTitle: selectedTask?.title ?? localizedTaskTitle(for: selectedTaskID),
            durationSeconds: totalSeconds
        )
        sessionRecords.append(record)
        try? sessionLog.append(record)

        mode = .celebration
    }

    // MARK: - Derived statistics

    private static let calendar: Calendar = .current

    /// Aggregate snapshot computed from `sessionRecords`. Cached and only
    /// rebuilt when the records array changes.
    private var stats: SessionStats {
        if let cached = _statsCache { return cached }
        let computed = SessionStats(records: sessionRecords, calendar: Self.calendar)
        _statsCache = computed
        return computed
    }

    var totalFocusSeconds: TimeInterval { stats.totalFocus }
    var breakTotalSeconds: TimeInterval { stats.breakTotal }
    var todayFocusSeconds: TimeInterval { stats.todayFocus }
    var weekFocusSeconds: TimeInterval { stats.weekFocus }
    var last7DaysFocusSeconds: [DayFocus] { stats.last7Days }
    var perTaskFocusSeconds: [(task: String, seconds: TimeInterval)] { stats.perTask }

    struct DayFocus: Identifiable, Hashable {
        let day: Date
        let seconds: TimeInterval
        var id: TimeInterval { day.timeIntervalSince1970 }
    }
}

/// Memoizable aggregate of `sessionRecords`. All fields are computed once,
/// then cached on `TimerStore`.
private struct SessionStats {
    let totalFocus: TimeInterval
    let breakTotal: TimeInterval
    let todayFocus: TimeInterval
    let weekFocus: TimeInterval
    let last7Days: [TimerStore.DayFocus]
    let perTask: [(task: String, seconds: TimeInterval)]

    init(records: [SessionRecord], calendar: Calendar) {
        let focusRecords = records.filter { $0.pomodoroMode == .focus }
        let breakRecords = records.filter { $0.pomodoroMode == .breakTime }

        totalFocus = focusRecords.reduce(0) { $0 + $1.durationSeconds }
        breakTotal = breakRecords.reduce(0) { $0 + $1.durationSeconds }

        todayFocus = focusRecords
            .filter { calendar.isDateInToday($0.completedAt) }
            .reduce(0) { $0 + $1.durationSeconds }

        let today = calendar.startOfDay(for: Date())
        if let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) {
            weekFocus = focusRecords
                .filter { $0.completedAt >= weekAgo }
                .reduce(0) { $0 + $1.durationSeconds }
        } else {
            weekFocus = todayFocus
        }

        last7Days = (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let seconds = focusRecords
                .filter { calendar.isDate($0.completedAt, inSameDayAs: day) }
                .reduce(0) { $0 + $1.durationSeconds }
            return TimerStore.DayFocus(day: day, seconds: seconds)
        }

        let grouped = Dictionary(grouping: focusRecords, by: { $0.taskTitle })
        perTask = grouped
            .map { (task: $0.key, seconds: $0.value.reduce(0) { $0 + $1.durationSeconds }) }
            .sorted { $0.seconds > $1.seconds }
    }
}
