import Foundation

enum CodexPetImportError: LocalizedError {
    case missingSpritesheet
    case unreadablePackage
    case unsafeArchiveEntry(String)

    var errorDescription: String? {
        switch self {
        case .missingSpritesheet:
            "No Codex spritesheet was found. Choose a .codex-pet.zip, an unzipped pet folder, pet.json, or spritesheet.webp."
        case .unreadablePackage:
            "The Codex pet package could not be read."
        case .unsafeArchiveEntry(let entry):
            "The archive contains an unsafe path: \(entry)"
        }
    }
}

struct CodexPetImportService {
    static let importedPetsDirectory = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("FocusPet", isDirectory: true)
        .appendingPathComponent("ImportedPets", isDirectory: true)

    private let fileManager = FileManager.default

    func loadImportedPets() -> [ImportedPet] {
        guard let directories = try? fileManager.contentsOfDirectory(
            at: Self.importedPetsDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        return directories.compactMap { directory in
            let manifestURL = directory.appendingPathComponent("pet.json")
            guard let data = try? Data(contentsOf: manifestURL) else { return nil }
            return try? JSONDecoder().decode(ImportedPet.self, from: data)
        }
        .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    func importPet(from sourceURL: URL) throws -> ImportedPet {
        let source = try preparedSourceURL(from: sourceURL)
        let package = try readPackage(at: source)
        let directoryName = sanitized(package.codexID.isEmpty ? package.displayName : package.codexID)
        let destinationDirectory = Self.importedPetsDirectory.appendingPathComponent(directoryName, isDirectory: true)
        let destinationSpritesheet = destinationDirectory.appendingPathComponent("spritesheet.webp")

        try fileManager.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
        if fileManager.fileExists(atPath: destinationSpritesheet.path) {
            try fileManager.removeItem(at: destinationSpritesheet)
        }
        try fileManager.copyItem(at: package.spritesheetURL, to: destinationSpritesheet)

        let importedPet = ImportedPet(
            id: "imported:\(directoryName)",
            codexID: package.codexID,
            displayName: package.displayName,
            description: package.description,
            kind: package.kind,
            directoryName: directoryName,
            spritesheetFileName: "spritesheet.webp"
        )

        let manifestURL = destinationDirectory.appendingPathComponent("pet.json")
        let data = try JSONEncoder().encode(importedPet)
        try data.write(to: manifestURL, options: .atomic)
        return importedPet
    }

    private func preparedSourceURL(from sourceURL: URL) throws -> URL {
        if sourceURL.pathExtension.lowercased() == "zip" {
            return try unzipPackage(sourceURL)
        }
        return sourceURL
    }

    private func readPackage(at sourceURL: URL) throws -> CodexPetPackage {
        let isDirectory = (try? sourceURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        let rootURL: URL

        if isDirectory {
            rootURL = sourceURL
        } else if sourceURL.lastPathComponent == "pet.json" {
            rootURL = sourceURL.deletingLastPathComponent()
        } else if sourceURL.pathExtension.lowercased() == "webp" {
            let name = sourceURL.deletingPathExtension().lastPathComponent
            return CodexPetPackage(
                codexID: sanitized(name),
                displayName: humanized(name),
                description: "",
                kind: "object",
                spritesheetURL: sourceURL
            )
        } else {
            throw CodexPetImportError.unreadablePackage
        }

        let manifestURL = try findFile(named: "pet.json", under: rootURL)
        let manifest = try decodeManifest(at: manifestURL)
        let spritesheetURL = try findSpritesheet(
            under: manifestURL.deletingLastPathComponent(),
            preferredPath: manifest.spritesheetPath
        )

        return CodexPetPackage(
            codexID: sanitized(manifest.id.isEmpty ? manifest.displayName : manifest.id),
            displayName: manifest.displayName.isEmpty ? humanized(manifest.id) : manifest.displayName,
            description: manifest.description,
            kind: manifest.kind.isEmpty ? "object" : manifest.kind,
            spritesheetURL: spritesheetURL
        )
    }

    private func decodeManifest(at url: URL) throws -> CodexPetManifest {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(CodexPetManifest.self, from: data)
    }

    private func findSpritesheet(under rootURL: URL, preferredPath: String) throws -> URL {
        if !preferredPath.isEmpty {
            let preferredURL = rootURL.appendingPathComponent(preferredPath)
            if fileManager.fileExists(atPath: preferredURL.path) {
                return preferredURL
            }
        }
        return try findFile(named: "spritesheet.webp", under: rootURL)
    }

    private func findFile(named fileName: String, under rootURL: URL) throws -> URL {
        if rootURL.lastPathComponent == fileName {
            return rootURL
        }

        guard let enumerator = fileManager.enumerator(at: rootURL, includingPropertiesForKeys: [.isRegularFileKey]) else {
            throw CodexPetImportError.unreadablePackage
        }

        for case let url as URL in enumerator where url.lastPathComponent == fileName {
            return url
        }

        throw CodexPetImportError.missingSpritesheet
    }

    private func unzipPackage(_ archiveURL: URL) throws -> URL {
        try validateArchive(archiveURL)

        let destination = fileManager.temporaryDirectory
            .appendingPathComponent("FocusPetImport-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-qq", "-o", archiveURL.path, "-d", destination.path]
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw CodexPetImportError.unreadablePackage
        }
        return destination
    }

    private func validateArchive(_ archiveURL: URL) throws {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-Z1", archiveURL.path]
        process.standardOutput = pipe
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw CodexPetImportError.unreadablePackage
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let entries = String(decoding: data, as: UTF8.self).split(separator: "\n").map(String.init)
        for entry in entries {
            let components = entry.split(separator: "/").map(String.init)
            if entry.hasPrefix("/") || components.contains("..") {
                throw CodexPetImportError.unsafeArchiveEntry(entry)
            }
        }
    }

    private func sanitized(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let scalars = value.lowercased().unicodeScalars.map { scalar in
            allowed.contains(scalar) ? Character(scalar) : "-"
        }
        let result = String(scalars).split(separator: "-").joined(separator: "-")
        return result.isEmpty ? UUID().uuidString : result
    }

    private func humanized(_ value: String) -> String {
        value
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}

private struct CodexPetManifest: Decodable {
    var id: String
    var displayName: String
    var description: String
    var spritesheetPath: String
    var kind: String

    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case description
        case spritesheetPath
        case kind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        spritesheetPath = try container.decodeIfPresent(String.self, forKey: .spritesheetPath) ?? "spritesheet.webp"
        kind = try container.decodeIfPresent(String.self, forKey: .kind) ?? "object"
    }
}

private struct CodexPetPackage {
    let codexID: String
    let displayName: String
    let description: String
    let kind: String
    let spritesheetURL: URL
}
