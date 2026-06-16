import AppKit
import Foundation

/// Caches decoded pet sprite images so animations never re-read from disk or
/// re-decode bitmaps on each frame.
///
/// Two concerns are handled:
/// - Built-in sprite frames (doro/feibi/clawd/...): keyed by `"prefix_frame"`.
/// - Imported Codex spritesheets: decoded ONCE into a grid of pre-cropped
///   `CGImage` cells, keyed by the spritesheet file URL.
///
/// All access is on the main actor (animations render on main), so no locking
/// is needed. `NSCache` is used as the backing store so the system can evict
/// entries under memory pressure.
@MainActor
final class PetSpriteCache {
    static let shared = PetSpriteCache()

    /// Spritesheet grid layout assumed by Codex imports.
    static let sheetColumns = 8
    static let sheetRows = 9

    private let frameCache = NSCache<NSString, NSImage>()
    private let sheetCache = NSCache<NSString, SpriteGridBox>()

    private init() {
        frameCache.countLimit = 128
        sheetCache.countLimit = 16
    }

    // MARK: - Built-in sprite frames

    /// Returns a cached built-in sprite frame, decoding + caching on first miss.
    func cachedFrame(prefix: String, frame: Int) -> NSImage? {
        let key = "\(prefix)_\(frame)" as NSString
        if let cached = frameCache.object(forKey: key) {
            return cached
        }
        guard let url = Bundle.module.url(forResource: "\(prefix)_\(frame)", withExtension: "png"),
              let image = NSImage(contentsOf: url)
        else {
            return nil
        }
        frameCache.setObject(image, forKey: key)
        return image
    }

    /// Pre-decodes all frames for a built-in sprite set so the first animation
    /// cycle never pays decode cost.
    func warmup(prefix: String, frameCount: Int) {
        for frame in 0..<frameCount {
            _ = cachedFrame(prefix: prefix, frame: frame)
        }
    }

    // MARK: - Imported spritesheets

    /// Returns the pre-cropped cells for an imported spritesheet, decoding the
    /// whole sheet exactly once and slicing it into a flat `[CGImage]` grid.
    func cachedSpritesheetCells(url: URL) -> [CGImage] {
        let key = url.path as NSString
        if let cached = sheetCache.object(forKey: key) {
            return cached.cells
        }

        guard let source = NSImage(contentsOf: url),
              let fullImage = source.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            return []
        }

        let box = SpriteGridBox(image: fullImage, columns: Self.sheetColumns, rows: Self.sheetRows)
        sheetCache.setObject(box, forKey: key)
        return box.cells
    }

    /// Returns a single cropped cell, or `nil` if the sheet is unreadable or
    /// the index is out of bounds.
    func cachedSpritesheetCell(url: URL, row: Int, column: Int) -> CGImage? {
        let cells = cachedSpritesheetCells(url: url)
        guard columns(of: url) > 0 else { return nil }
        let safeRow = min(max(row, 0), Self.sheetRows - 1)
        let safeColumn = min(max(column, 0), Self.sheetColumns - 1)
        let index = safeRow * Self.sheetColumns + safeColumn
        guard cells.indices.contains(index) else { return nil }
        return cells[index]
    }

    private func columns(of url: URL) -> Int { Self.sheetColumns }
}

/// Holds a decoded spritesheet plus its lazily-sliced cell grid.
@MainActor
private final class SpriteGridBox: NSObject {
    let cells: [CGImage]

    init(image: CGImage, columns: Int, rows: Int) {
        let cellWidth = max(1, image.width / columns)
        let cellHeight = max(1, image.height / rows)
        var sliced: [CGImage] = []
        sliced.reserveCapacity(columns * rows)
        for row in 0..<rows {
            for column in 0..<columns {
                let rect = CGRect(
                    x: column * cellWidth,
                    y: row * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                if let cell = image.cropping(to: rect) {
                    sliced.append(cell)
                }
            }
        }
        self.cells = sliced
        super.init()
    }
}
