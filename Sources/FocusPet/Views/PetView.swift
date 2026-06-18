import AppKit
import SwiftUI

struct PetView: View {
    let pet: PetProfile
    let mode: PomodoroMode
    let progress: Double
    let compact: Bool
    /// When false, all continuous animations (bob, sprite cycling) are paused.
    /// Pass false for static previews (e.g. pet-house state cards) so they
    /// don't each spin up a CADisplayLink.
    var isLiveAnimating: Bool = true
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    @State private var bob = false
    @State private var isHovering = false
    @State private var isPressed = false
    @State private var showBurst = false
    @State private var burstSeed = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.15))
                .overlay {
                    Circle()
                        .fill(mode.ringColor(in: theme).opacity(0.08))
                        .padding(compact ? 14 : 20)
                }
                .overlay {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.8),
                                    mode.ringColor(in: theme).opacity(0.56),
                                    .white.opacity(0.22),
                                    .black.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: compact ? 1 : 1.4
                        )
                }
                .overlay(alignment: .topLeading) {
                    Circle()
                        .fill(Color.white.opacity(0.16))
                        .frame(width: compact ? 24 : 36, height: compact ? 24 : 36)
                        .offset(x: compact ? 22 : 34, y: compact ? 20 : 32)
                }
                .shadow(color: mode.ringColor(in: theme).opacity(0.14), radius: compact ? 6 : 12, y: compact ? 3 : 8)

            CircularProgressRing(progress: progress, color: mode.ringColor(in: theme))
                .padding(compact ? 8 : 10)

            if isHovering {
                InteractionHintRing(color: mode.ringColor(in: theme))
                    .padding(compact ? 13 : 19)
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }

            if mode == .celebration {
                ConfettiView()
                    .padding(compact ? 2 : 0)
            }

            Group {
                if let importedPet = pet.importedPet {
                    CodexSpriteSheetPetImage(
                        spritesheetURL: importedPet.spritesheetURL,
                        mode: mode,
                        isInteracting: isHovering || isPressed,
                        isAnimating: isLiveAnimating
                    )
                } else if let kind = pet.builtInKind {
                    switch kind {
                case .panda:
                    PandaSticker(mode: mode)
                case .cat:
                    CatSticker(mode: mode)
                case .doro, .feibi, .clawd, .gugugaga, .ikunchick:
                    SpritePetImage(
                        assetPrefix: kind.spriteAssetPrefix,
                        frameCount: kind.spriteFrameCount,
                        mode: mode,
                        isInteracting: isHovering || isPressed,
                        isAnimating: isLiveAnimating
                    )
                    }
                }
            }
            .padding(compact ? 16 : 22)
            .offset(y: isLiveAnimating ? (bob ? -5 : 3) : 0)
            .scaleEffect(petScale)
            .rotationEffect(.degrees(isPressed ? -4 : 0))
            .animation(isLiveAnimating ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : nil, value: bob)
            .animation(.spring(response: 0.22, dampingFraction: 0.68), value: isHovering)
            .animation(.spring(response: 0.2, dampingFraction: 0.55), value: isPressed)

            if showBurst {
                InteractionBurstView(seed: burstSeed)
                    .padding(compact ? 4 : 8)
                    .allowsHitTesting(false)
                    .transition(.opacity.combined(with: .scale(scale: 0.72)))
            }
        }
        .contentShape(Circle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.24, dampingFraction: 0.78)) {
                isHovering = hovering
            }
        }
        .onTapGesture {
            burstSeed += 1
            withAnimation(.spring(response: 0.2, dampingFraction: 0.55)) {
                isPressed = true
                showBurst = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.62)) {
                    isPressed = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {
                withAnimation(.easeOut(duration: 0.18)) {
                    showBurst = false
                }
            }
        }
        .onAppear {
            if isLiveAnimating {
                bob = true
            }
        }
    }

    private var petScale: CGFloat {
        if isPressed {
            return compact ? 1.12 : 1.08
        }
        return isHovering ? 1.05 : 1
    }
}

private struct SpritePetImage: View {
    let assetPrefix: String
    let frameCount: Int
    let mode: PomodoroMode
    let isInteracting: Bool
    let isAnimating: Bool

    var body: some View {
        Group {
            if isAnimating {
                TimelineView(.periodic(from: .now, by: frameDuration)) { timeline in
                    GeometryReader { proxy in
                        let size = min(proxy.size.width, proxy.size.height)
                        let frame = frameIndex(at: timeline.date)
                        spriteContent(image: petImage(frame: frame), size: size, frame: frame, proxy: proxy)
                    }
                }
            } else {
                GeometryReader { proxy in
                    let size = min(proxy.size.width, proxy.size.height)
                    spriteContent(image: petImage(frame: 0), size: size, frame: 0, proxy: proxy)
                }
            }
        }
    }

    @ViewBuilder
    private func spriteContent(image: NSImage?, size: CGFloat, frame: Int, proxy: GeometryProxy) -> some View {
        if let image {
            Image(nsImage: image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: size * spriteScale, height: size * spriteScale)
                .rotationEffect(.degrees(mode == .celebration ? Double((frame % 3) - 1) * 4 : 0))
                .scaleEffect(mode == .celebration && frame % 2 == 0 ? 1.04 : 1)
                .shadow(color: .black.opacity(0.18), radius: size * 0.025, y: size * 0.018)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var spriteScale: CGFloat {
        mode == .celebration ? 0.98 : 0.92
    }

    private var frameDuration: TimeInterval {
        isInteracting ? 0.1 : 0.18
    }

    private func frameIndex(at date: Date) -> Int {
        guard frameCount > 0 else { return 0 }
        return Int(date.timeIntervalSinceReferenceDate / frameDuration) % frameCount
    }

    private func petImage(frame: Int) -> NSImage? {
        PetSpriteCache.shared.cachedFrame(prefix: assetPrefix, frame: frame)
    }
}

private struct CodexSpriteSheetPetImage: View {
    let spritesheetURL: URL
    let mode: PomodoroMode
    let isInteracting: Bool
    let isAnimating: Bool

    var body: some View {
        Group {
            if isAnimating {
                TimelineView(.periodic(from: .now, by: frameDuration)) { timeline in
                    GeometryReader { proxy in
                        let size = min(proxy.size.width, proxy.size.height)
                        let state = spriteState
                        let frame = frameIndex(at: timeline.date, frameCount: state.frames)
                        spriteContent(image: frameImage(row: state.row, frame: frame), size: size, frame: frame, proxy: proxy)
                    }
                }
            } else {
                GeometryReader { proxy in
                    let size = min(proxy.size.width, proxy.size.height)
                    let state = spriteState
                    spriteContent(image: frameImage(row: state.row, frame: 0), size: size, frame: 0, proxy: proxy)
                }
            }
        }
    }

    @ViewBuilder
    private func spriteContent(image: NSImage?, size: CGFloat, frame: Int, proxy: GeometryProxy) -> some View {
        if let image {
            Image(nsImage: image)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: size * spriteScale, height: size * spriteScale)
                .rotationEffect(.degrees(mode == .celebration ? Double((frame % 3) - 1) * 3 : 0))
                .scaleEffect(mode == .celebration && frame % 2 == 0 ? 1.05 : 1)
                .shadow(color: .black.opacity(0.18), radius: size * 0.025, y: size * 0.018)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var spriteState: CodexSpriteState {
        if isInteracting && mode != .celebration {
            return CodexSpriteState(row: 3, frames: 4)
        }

        switch mode {
        case .focus:
            return CodexSpriteState(row: 0, frames: 6)
        case .breakTime:
            return CodexSpriteState(row: 3, frames: 4)
        case .celebration:
            return CodexSpriteState(row: 4, frames: 5)
        }
    }

    private var frameDuration: TimeInterval {
        isInteracting ? 0.1 : 0.18
    }

    private var spriteScale: CGFloat {
        mode == .celebration ? 1.0 : 0.94
    }

    private func frameIndex(at date: Date, frameCount: Int) -> Int {
        guard frameCount > 0 else { return 0 }
        return Int(date.timeIntervalSinceReferenceDate / frameDuration) % frameCount
    }

    private func frameImage(row: Int, frame: Int) -> NSImage? {
        guard let cell = PetSpriteCache.shared.cachedSpritesheetCell(url: spritesheetURL, row: row, column: frame) else {
            return nil
        }
        let cellWidth = cell.width
        let cellHeight = cell.height
        return NSImage(cgImage: cell, size: NSSize(width: cellWidth, height: cellHeight))
    }
}

private struct CodexSpriteState {
    let row: Int
    let frames: Int
}

private struct InteractionHintRing: View {
    let color: Color

    var body: some View {
        TimelineView(.animation) { timeline in
            let angle = timeline.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 4) / 4 * 360

            Circle()
                .stroke(
                    color.opacity(0.42),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [7, 9])
                )
                .rotationEffect(.degrees(angle))
                .shadow(color: color.opacity(0.35), radius: 8)
        }
    }
}

private struct InteractionBurstView: View {
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    let seed: Int
    private let symbols = ["sparkle", "heart.fill", "pawprint.fill", "sparkles"]
    private var colors: [Color] { [theme.accentColor, theme.breakColor, .celebrationGold, .pink] }

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: symbols[(index + seed) % symbols.count])
                    .font(.system(size: max(CGFloat(11), proxy.size.width * 0.07), weight: .bold))
                    .foregroundStyle(colors[(index + seed) % colors.count])
                    .shadow(color: colors[(index + seed) % colors.count].opacity(0.36), radius: 6)
                    .position(position(index: index, in: proxy.size))
                    .scaleEffect(index.isMultiple(of: 2) ? 1.1 : 0.9)
                    .rotationEffect(.degrees(Double(index * 19 + seed * 7)))
            }
        }
    }

    private func position(index: Int, in size: CGSize) -> CGPoint {
        let radius = min(size.width, size.height) * 0.38
        let angle = Double(index) / 8 * .pi * 2 + Double(seed).truncatingRemainder(dividingBy: 5) * 0.18
        return CGPoint(
            x: size.width / 2 + cos(angle) * radius,
            y: size.height / 2 + sin(angle) * radius
        )
    }
}

private struct PandaSticker: View {
    let mode: PomodoroMode

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            ZStack {
                Ellipse()
                    .fill(Color.black.opacity(0.16))
                    .frame(width: size * 0.72, height: size * 0.13)
                    .offset(y: size * 0.41)
                    .blur(radius: size * 0.012)

                Circle()
                    .fill(Color.black.opacity(0.9))
                    .frame(width: size * 0.27, height: size * 0.27)
                    .offset(x: -size * 0.29, y: -size * 0.25)
                Circle()
                    .fill(Color.black.opacity(0.9))
                    .frame(width: size * 0.27, height: size * 0.27)
                    .offset(x: size * 0.29, y: -size * 0.25)

                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .fill(Color(red: 1.0, green: 0.97, blue: 0.88))
                    .frame(width: size * 0.7, height: size * 0.76)
                    .overlay {
                        RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                            .stroke(Color.black.opacity(0.82), lineWidth: size * 0.035)
                    }

                eyePatch(size: size, x: -0.16)
                eyePatch(size: size, x: 0.16)
                glossyEye(size: size, x: -0.16)
                glossyEye(size: size, x: 0.16)

                Capsule()
                    .fill(Color.black.opacity(0.88))
                    .frame(width: size * 0.1, height: size * 0.07)
                    .offset(y: size * 0.06)

                PetMouth(mode: mode)
                    .stroke(Color.black.opacity(0.82), lineWidth: size * 0.022)
                    .frame(width: size * 0.22, height: size * 0.12)
                    .offset(y: size * 0.16)

                paw(size: size, x: -0.32, y: 0.16, rotation: -18, color: .black.opacity(0.88))
                paw(size: size, x: 0.32, y: 0.16, rotation: 18, color: .black.opacity(0.88))
                StateProp(mode: mode, size: size)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

private struct CatSticker: View {
    let mode: PomodoroMode

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let fur = Color(red: 1.0, green: 0.67, blue: 0.36)
            let furDark = Color(red: 0.83, green: 0.38, blue: 0.16)

            ZStack {
                Ellipse()
                    .fill(Color.black.opacity(0.16))
                    .frame(width: size * 0.72, height: size * 0.13)
                    .offset(y: size * 0.41)
                    .blur(radius: size * 0.012)

                Triangle()
                    .fill(fur)
                    .frame(width: size * 0.26, height: size * 0.28)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -size * 0.28, y: -size * 0.28)
                Triangle()
                    .fill(fur)
                    .frame(width: size * 0.26, height: size * 0.28)
                    .rotationEffect(.degrees(18))
                    .offset(x: size * 0.28, y: -size * 0.28)

                RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
                    .fill(fur)
                    .frame(width: size * 0.72, height: size * 0.74)
                    .overlay {
                        RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
                            .stroke(Color.black.opacity(0.78), lineWidth: size * 0.035)
                    }

                ForEach([-0.13, 0, 0.13], id: \.self) { x in
                    Capsule()
                        .fill(furDark)
                        .frame(width: size * 0.045, height: size * 0.16)
                        .rotationEffect(.degrees(x * 120))
                        .offset(x: size * x, y: -size * 0.23)
                }

                glossyCatEye(size: size, x: -0.14)
                glossyCatEye(size: size, x: 0.14)

                Circle()
                    .fill(Color(red: 0.96, green: 0.23, blue: 0.34))
                    .frame(width: size * 0.075, height: size * 0.06)
                    .offset(y: size * 0.07)

                PetMouth(mode: mode)
                    .stroke(Color.black.opacity(0.78), lineWidth: size * 0.022)
                    .frame(width: size * 0.22, height: size * 0.12)
                    .offset(y: size * 0.16)

                paw(size: size, x: -0.33, y: 0.17, rotation: -18, color: furDark)
                paw(size: size, x: 0.33, y: 0.17, rotation: 18, color: furDark)
                StateProp(mode: mode, size: size)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

private struct StateProp: View {
    let mode: PomodoroMode
    let size: CGFloat

    var body: some View {
        switch mode {
        case .focus:
            ZStack {
                FocusGlasses(size: size)
                    .offset(y: -size * 0.07)
                TinyLaptop(size: size)
                    .offset(y: size * 0.35)
            }
        case .breakTime:
            BreakBubble(size: size)
                .offset(x: size * 0.3, y: size * 0.24)
        case .celebration:
            PartyHat(size: size)
                .offset(y: -size * 0.5)
        }
    }
}

private func eyePatch(size: CGFloat, x: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: size * 0.09, style: .continuous)
        .fill(Color.black.opacity(0.88))
        .frame(width: size * 0.2, height: size * 0.24)
        .rotationEffect(.degrees(x < 0 ? -14 : 14))
        .offset(x: size * x, y: -size * 0.06)
}

private func glossyEye(size: CGFloat, x: CGFloat) -> some View {
    ZStack(alignment: .topLeading) {
        Circle()
            .fill(Color(red: 0.24, green: 0.18, blue: 0.32))
        Circle()
            .fill(Color.white)
            .frame(width: size * 0.035, height: size * 0.035)
            .offset(x: size * 0.035, y: size * 0.028)
    }
    .frame(width: size * 0.09, height: size * 0.09)
    .offset(x: size * x, y: -size * 0.08)
}

private func glossyCatEye(size: CGFloat, x: CGFloat) -> some View {
    ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: size * 0.035, style: .continuous)
            .fill(Color(red: 0.34, green: 0.24, blue: 0.5))
        Circle()
            .fill(Color.white)
            .frame(width: size * 0.032, height: size * 0.032)
            .offset(x: size * 0.028, y: size * 0.022)
    }
    .frame(width: size * 0.08, height: size * 0.12)
    .offset(x: size * x, y: -size * 0.07)
}

private func paw(size: CGFloat, x: CGFloat, y: CGFloat, rotation: Double, color: Color) -> some View {
    Capsule()
        .fill(color)
        .frame(width: size * 0.13, height: size * 0.22)
        .rotationEffect(.degrees(rotation))
        .offset(x: size * x, y: size * y)
}

private struct FocusGlasses: View {
    let size: CGFloat

    var body: some View {
        HStack(spacing: size * 0.055) {
            lens
            lens
        }
        .overlay {
            Rectangle()
                .fill(Color.black.opacity(0.72))
                .frame(width: size * 0.08, height: size * 0.022)
        }
    }

    private var lens: some View {
        RoundedRectangle(cornerRadius: size * 0.045, style: .continuous)
            .fill(Color.black.opacity(0.15))
            .frame(width: size * 0.22, height: size * 0.15)
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.045, style: .continuous)
                    .stroke(Color.black.opacity(0.76), lineWidth: size * 0.025)
            }
    }
}

private struct TinyLaptop: View {
    let size: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.035, style: .continuous)
            .fill(Color(red: 0.32, green: 0.34, blue: 0.4))
            .frame(width: size * 0.42, height: size * 0.22)
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.035, style: .continuous)
                    .stroke(Color.black.opacity(0.65), lineWidth: size * 0.018)
            }
            .overlay {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: size * 0.075, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.8))
            }
    }
}

private struct BreakBubble: View {
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(theme.breakColor.gradient)
            .frame(width: size * 0.2, height: size * 0.2)
            .overlay {
                Image(systemName: "leaf.fill")
                    .font(.system(size: size * 0.08, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .overlay {
                Circle().stroke(Color.black.opacity(0.35), lineWidth: size * 0.012)
            }
    }
}

private struct PartyHat: View {
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    let size: CGFloat

    var body: some View {
        Triangle()
            .fill(LinearGradient(colors: [.celebrationGold, theme.accentColor], startPoint: .top, endPoint: .bottom))
            .frame(width: size * 0.24, height: size * 0.32)
            .overlay {
                Triangle()
                    .stroke(Color.black.opacity(0.55), lineWidth: size * 0.018)
            }
            .overlay(alignment: .top) {
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.055, height: size * 0.055)
                    .offset(y: -size * 0.035)
            }
            .rotationEffect(.degrees(-8))
    }
}

private struct ConfettiView: View {
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    private var colors: [Color] { [theme.accentColor, theme.breakColor, .celebrationGold, .blue, .pink] }

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<18, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(colors[index % colors.count])
                    .frame(width: 5, height: 10)
                    .rotationEffect(.degrees(Double(index * 23)))
                    .position(
                        x: proxy.size.width * CGFloat((index * 2 % 7) + 1) / 8,
                        y: proxy.size.height * CGFloat((index * 5 % 7) + 1) / 8
                    )
            }
        }
    }
}

private struct PetMouth: Shape {
    let mode: PomodoroMode

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch mode {
        case .focus:
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.midY))
        case .breakTime:
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.midY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - rect.width * 0.2, y: rect.midY),
                control: CGPoint(x: rect.midX, y: rect.maxY)
            )
        case .celebration:
            path.addEllipse(in: CGRect(x: rect.midX - rect.width * 0.18, y: rect.midY - rect.height * 0.08, width: rect.width * 0.36, height: rect.height * 0.34))
        }
        return path
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
