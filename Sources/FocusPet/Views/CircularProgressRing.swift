import SwiftUI

struct CircularProgressRing: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.28), lineWidth: 18)
                .blur(radius: 0.5)

            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 12)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            color.opacity(0.62),
                            color,
                            Color.white.opacity(0.88),
                            color
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.3), radius: 12, y: 4)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color.opacity(0.18), style: StrokeStyle(lineWidth: 22, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .blur(radius: 7)
        }
        .animation(.smooth(duration: 0.38), value: progress)
    }
}
