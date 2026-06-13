import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct CodexPetImportButton: View {
    @ObservedObject var store: TimerStore
    let compact: Bool
    @State private var status: String?

    var body: some View {
        VStack(alignment: compact ? .trailing : .leading, spacing: 6) {
            Button {
                importPet()
            } label: {
                Label(text("Import Codex Pet", "导入 Codex 宠物"), systemImage: "square.and.arrow.down")
                    .font(.system(size: compact ? 12 : 13, weight: .bold))
                    .padding(.horizontal, compact ? 12 : 14)
                    .padding(.vertical, compact ? 8 : 10)
            }
            .buttonStyle(GlassCapsuleButtonStyle())

            if let status {
                Text(status)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func importPet() {
        let panel = NSOpenPanel()
        panel.title = text("Import Codex Pet", "导入 Codex 宠物")
        panel.prompt = text("Import", "导入")
        panel.message = text(
            "Choose a .codex-pet.zip, unzipped pet folder, pet.json, or spritesheet.webp.",
            "选择 .codex-pet.zip、解压后的宠物文件夹、pet.json 或 spritesheet.webp。"
        )
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [
            .folder,
            .json,
            .zip,
            UTType(filenameExtension: "webp") ?? .image
        ]

        guard panel.runModal() == .OK, let url = panel.url else { return }
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let pet = try store.importCodexPet(from: url)
            status = text("Imported \(pet.displayName).", "已导入 \(pet.displayName)。")
        } catch {
            status = error.localizedDescription
        }
    }

    private func text(_ english: String, _ chinese: String) -> String {
        store.language == .chinese ? chinese : english
    }
}
