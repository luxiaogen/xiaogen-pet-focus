import Foundation

struct FocusTask: Codable, Hashable, Identifiable {
    let id: String
    var title: String
    /// Localized title for built-in tasks. `nil` for user-authored tasks.
    var localizedTitle: String?
    var isBuiltIn: Bool
    var createdAt: Date

    /// Stable built-in tasks. The English title doubles as the canonical key
    /// so existing references continue to resolve.
    static let builtIns: [FocusTask] = {
        let now = Date(timeIntervalSince1970: 0)
        return [
            FocusTask(id: "builtin:design-system", title: "Design System Update", localizedTitle: "设计系统更新", isBuiltIn: true, createdAt: now),
            FocusTask(id: "builtin:focus-notes", title: "Write Focus Notes", localizedTitle: "写专注笔记", isBuiltIn: true, createdAt: now),
            FocusTask(id: "builtin:pet-motion", title: "Prototype Pet Motion", localizedTitle: "原型桌宠动效", isBuiltIn: true, createdAt: now),
            FocusTask(id: "builtin:inbox", title: "Inbox Cleanup", localizedTitle: "清理收件箱", isBuiltIn: true, createdAt: now)
        ]
    }()

    /// The first built-in task id, used as a fallback selection.
    static let defaultBuiltInID: String = builtIns.first?.id ?? "builtin:design-system"

    init(id: String = "custom:\(UUID().uuidString)", title: String, localizedTitle: String? = nil, isBuiltIn: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.localizedTitle = localizedTitle
        self.isBuiltIn = isBuiltIn
        self.createdAt = createdAt
    }
}
