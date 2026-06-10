import SwiftUI

struct PetView: View {
    let kind: PetKind
    let mode: PomodoroMode
    let progress: Double
    let compact: Bool
    @State private var bob = false

    var body: some View {
        ZStack {
            Circle()
                .fill(.thinMaterial)
                .shadow(color: mode.ringColor.opacity(0.18), radius: compact ? 8 : 16)

            CircularProgressRing(progress: progress, color: mode.ringColor)
                .padding(compact ? 8 : 10)

            if mode == .celebration {
                ConfettiView()
                    .padding(compact ? 6 : 0)
            }

            Group {
                switch kind {
                case .panda:
                    PandaPetDrawing(mode: mode)
                case .cat:
                    CatPetDrawing(mode: mode)
                }
            }
            .padding(compact ? 24 : 32)
            .offset(y: bob ? -4 : 3)
            .animation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true), value: bob)
        }
        .onAppear {
            bob = true
        }
    }
}

private struct PandaPetDrawing: View {
    let mode: PomodoroMode

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            ZStack {
                Ellipse()
                    .fill(Color.black.opacity(0.14))
                    .frame(width: size * 0.76, height: size * 0.12)
                    .offset(y: size * 0.38)

                if mode == .focus {
                    TinyDesk(size: size)
                        .offset(y: size * 0.31)
                }

                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.32, height: size * 0.32)
                    .offset(x: -size * 0.24, y: -size * 0.25)
                Circle()
                    .fill(Color.black)
                    .frame(width: size * 0.32, height: size * 0.32)
                    .offset(x: size * 0.24, y: -size * 0.25)

                Circle()
                    .fill(Color(red: 0.98, green: 0.96, blue: 0.88))
                    .frame(width: size * 0.82, height: size * 0.82)

                Circle()
                    .fill(Color.black.opacity(0.9))
                    .frame(width: size * 0.22, height: size * 0.25)
                    .offset(x: -size * 0.16, y: -size * 0.06)
                Circle()
                    .fill(Color.black.opacity(0.9))
                    .frame(width: size * 0.22, height: size * 0.25)
                    .offset(x: size * 0.16, y: -size * 0.06)

                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.065, height: size * 0.065)
                    .offset(x: -size * 0.13, y: -size * 0.1)
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.065, height: size * 0.065)
                    .offset(x: size * 0.19, y: -size * 0.1)

                Capsule()
                    .fill(Color.black.opacity(0.9))
                    .frame(width: size * 0.12, height: size * 0.08)
                    .offset(y: size * 0.08)

                PetMouth(mode: mode)
                    .stroke(Color.black.opacity(0.8), lineWidth: size * 0.025)
                    .frame(width: size * 0.24, height: size * 0.14)
                    .offset(y: size * 0.18)

                PandaAccessory(mode: mode, size: size)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

private struct CatPetDrawing: View {
    let mode: PomodoroMode

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            ZStack {
                Ellipse()
                    .fill(Color.black.opacity(0.14))
                    .frame(width: size * 0.78, height: size * 0.12)
                    .offset(y: size * 0.38)

                if mode == .focus {
                    TinyDesk(size: size)
                        .offset(y: size * 0.31)
                }

                Triangle()
                    .fill(Color(red: 0.98, green: 0.63, blue: 0.34))
                    .frame(width: size * 0.28, height: size * 0.3)
                    .offset(x: -size * 0.25, y: -size * 0.28)
                    .rotationEffect(.degrees(-18))
                Triangle()
                    .fill(Color(red: 0.98, green: 0.63, blue: 0.34))
                    .frame(width: size * 0.28, height: size * 0.3)
                    .offset(x: size * 0.25, y: -size * 0.28)
                    .rotationEffect(.degrees(18))

                Circle()
                    .fill(Color(red: 1.0, green: 0.7, blue: 0.42))
                    .frame(width: size * 0.82, height: size * 0.82)

                Triangle()
                    .fill(Color(red: 1.0, green: 0.82, blue: 0.65))
                    .frame(width: size * 0.14, height: size * 0.14)
                    .offset(x: -size * 0.25, y: -size * 0.28)
                    .rotationEffect(.degrees(-18))
                Triangle()
                    .fill(Color(red: 1.0, green: 0.82, blue: 0.65))
                    .frame(width: size * 0.14, height: size * 0.14)
                    .offset(x: size * 0.25, y: -size * 0.28)
                    .rotationEffect(.degrees(18))

                Capsule()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: size * 0.07, height: size * 0.12)
                    .offset(x: -size * 0.15, y: -size * 0.06)
                Capsule()
                    .fill(Color.black.opacity(0.85))
                    .frame(width: size * 0.07, height: size * 0.12)
                    .offset(x: size * 0.15, y: -size * 0.06)

                Circle()
                    .fill(Color.pink.opacity(0.9))
                    .frame(width: size * 0.09, height: size * 0.07)
                    .offset(y: size * 0.08)

                PetMouth(mode: mode)
                    .stroke(Color.black.opacity(0.75), lineWidth: size * 0.022)
                    .frame(width: size * 0.24, height: size * 0.14)
                    .offset(y: size * 0.18)

                CatAccessory(mode: mode, size: size)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

private struct PandaAccessory: View {
    let mode: PomodoroMode
    let size: CGFloat

    var body: some View {
        switch mode {
        case .focus:
            Glasses(size: size)
                .offset(y: -size * 0.05)
        case .breakTime:
            Bamboo(size: size)
                .offset(x: size * 0.28, y: size * 0.2)
        case .celebration:
            PartyHat(size: size)
                .offset(y: -size * 0.48)
        }
    }
}

private struct CatAccessory: View {
    let mode: PomodoroMode
    let size: CGFloat

    var body: some View {
        switch mode {
        case .focus:
            Glasses(size: size)
                .offset(y: -size * 0.05)
        case .breakTime:
            Ball(size: size)
                .offset(x: size * 0.32, y: size * 0.27)
        case .celebration:
            PartyHat(size: size)
                .offset(y: -size * 0.48)
        }
    }
}

private struct Glasses: View {
    let size: CGFloat

    var body: some View {
        HStack(spacing: size * 0.05) {
            RoundedRectangle(cornerRadius: size * 0.04)
                .stroke(Color.black.opacity(0.78), lineWidth: size * 0.025)
                .frame(width: size * 0.24, height: size * 0.16)
            RoundedRectangle(cornerRadius: size * 0.04)
                .stroke(Color.black.opacity(0.78), lineWidth: size * 0.025)
                .frame(width: size * 0.24, height: size * 0.16)
        }
    }
}

private struct TinyDesk: View {
    let size: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.05, style: .continuous)
            .fill(Color(red: 0.48, green: 0.28, blue: 0.18))
            .frame(width: size * 0.62, height: size * 0.12)
            .overlay(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: size * 0.02)
                    .fill(Color.celebrationGold.opacity(0.9))
                    .frame(width: size * 0.16, height: size * 0.05)
                    .offset(x: -size * 0.07, y: -size * 0.035)
            }
    }
}

private struct Bamboo: View {
    let size: CGFloat

    var body: some View {
        Capsule()
            .fill(Color.breakSage)
            .frame(width: size * 0.08, height: size * 0.33)
            .rotationEffect(.degrees(35))
            .overlay {
                VStack(spacing: size * 0.05) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.55))
                            .frame(height: size * 0.012)
                    }
                }
            }
    }
}

private struct Ball: View {
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color.breakSage.gradient)
            .frame(width: size * 0.22, height: size * 0.22)
            .overlay {
                Circle()
                    .stroke(Color.white.opacity(0.7), lineWidth: size * 0.018)
                    .padding(size * 0.045)
            }
    }
}

private struct PartyHat: View {
    let size: CGFloat

    var body: some View {
        Triangle()
            .fill(LinearGradient(colors: [.celebrationGold, .focusTomato], startPoint: .top, endPoint: .bottom))
            .frame(width: size * 0.26, height: size * 0.34)
            .overlay(alignment: .top) {
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.06, height: size * 0.06)
                    .offset(y: -size * 0.035)
            }
    }
}

private struct ConfettiView: View {
    private let colors: [Color] = [.focusTomato, .breakSage, .celebrationGold, .blue, .pink]

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<14, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(colors[index % colors.count])
                    .frame(width: 5, height: 10)
                    .rotationEffect(.degrees(Double(index * 21)))
                    .position(
                        x: proxy.size.width * CGFloat((index % 5) + 1) / 6,
                        y: proxy.size.height * CGFloat((index * 7 % 5) + 1) / 6
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
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.22, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.22, y: rect.midY))
        case .breakTime:
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.midY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - rect.width * 0.2, y: rect.midY),
                control: CGPoint(x: rect.midX, y: rect.maxY)
            )
        case .celebration:
            path.addEllipse(in: CGRect(x: rect.midX - rect.width * 0.18, y: rect.midY - rect.height * 0.1, width: rect.width * 0.36, height: rect.height * 0.34))
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
