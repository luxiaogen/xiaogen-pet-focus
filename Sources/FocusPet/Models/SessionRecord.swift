import Foundation

struct SessionRecord: Codable, Hashable, Identifiable {
    let id: String
    let completedAt: Date
    let mode: String
    let taskID: String
    let taskTitle: String
    let durationSeconds: TimeInterval

    init(id: String = UUID().uuidString, completedAt: Date = Date(), mode: PomodoroMode, taskID: String, taskTitle: String, durationSeconds: TimeInterval) {
        self.id = id
        self.completedAt = completedAt
        self.mode = mode.rawValue
        self.taskID = taskID
        self.taskTitle = taskTitle
        self.durationSeconds = durationSeconds
    }

    var pomodoroMode: PomodoroMode? {
        PomodoroMode(rawValue: mode)
    }
}
