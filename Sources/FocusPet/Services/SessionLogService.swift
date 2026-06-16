import Foundation

/// Append-only session log persisted as individual JSON files under
/// Application Support, mirroring the `CodexPetImportService` convention.
struct SessionLogService {
    static let directory = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("FocusPet", isDirectory: true)
        .appendingPathComponent("SessionLog", isDirectory: true)

    private let fileManager = FileManager.default

    func loadRecords() -> [SessionRecord] {
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
                return try? JSONDecoder().decode(SessionRecord.self, from: data)
            }
            .sorted { $0.completedAt < $1.completedAt }
    }

    func append(_ record: SessionRecord) throws {
        try fileManager.createDirectory(at: Self.directory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(record)
        try data.write(to: Self.directory.appendingPathComponent("\(record.id).json"), options: .atomic)
    }

    func clearAll() {
        try? fileManager.removeItem(at: Self.directory)
    }
}
