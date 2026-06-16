import Foundation

/// Persists user-authored focus tasks as individual JSON files under
/// Application Support, mirroring the `CodexPetImportService` convention.
struct TaskStore {
    static let directory = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("FocusPet", isDirectory: true)
        .appendingPathComponent("CustomTasks", isDirectory: true)

    private let fileManager = FileManager.default

    func loadCustomTasks() -> [FocusTask] {
        guard let files = try? fileManager.contentsOfDirectory(
            at: Self.directory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? JSONDecoder().decode(FocusTask.self, from: data)
            }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func save(_ task: FocusTask) throws {
        try fileManager.createDirectory(at: Self.directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(task)
        try data.write(to: fileURL(for: task), options: .atomic)
    }

    func delete(_ task: FocusTask) {
        try? fileManager.removeItem(at: fileURL(for: task))
    }

    // MARK: - Order persistence

    private var orderFileURL: URL {
        Self.directory.appendingPathComponent("tasks-order.json")
    }

    /// Returns the persisted task id ordering, or `nil` if no manifest exists.
    func loadOrder() -> [String]? {
        guard let data = try? Data(contentsOf: orderFileURL) else { return nil }
        return try? JSONDecoder().decode([String].self, from: data)
    }

    /// Persists the full task id ordering so drag-to-reorder survives relaunches.
    func saveOrder(_ ids: [String]) {
        try? fileManager.createDirectory(at: Self.directory, withIntermediateDirectories: true)
        guard let data = try? JSONEncoder().encode(ids) else { return }
        try? data.write(to: orderFileURL, options: .atomic)
    }

    private func fileURL(for task: FocusTask) -> URL {
        // Sanitize: id is already namespaced, but keep file names filesystem-safe.
        let safeName = task.id.replacingOccurrences(of: ":", with: "_")
        return Self.directory.appendingPathComponent("task-\(safeName).json")
    }
}
