import SwiftUI

struct PetHouseView: View {
    @ObservedObject var store: TimerStore
    let enterFloatingMode: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                PageHeader(
                    title: text("Pet House", "宠物屋"),
                    subtitle: text("Pick a companion and preview every Pomodoro mood.", "选择伙伴，并预览每一种番茄钟状态。")
                )

                Spacer()

                Picker(text("Pet", "宠物"), selection: $store.selectedPet) {
                    ForEach(PetKind.allCases) { pet in
                        Label(pet.title(in: store.language), systemImage: pet.symbolName).tag(pet)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 180)
            }

            HStack(alignment: .top, spacing: 18) {
                stateCard(mode: .focus, title: text("Focus State", "专注状态"), description: text("Glasses on. Your pet keeps quiet while you work.", "戴上眼镜，安静陪你进入专注。"))
                stateCard(mode: .breakTime, title: text("Break State", "休息状态"), description: text("Snack or play time. The ring turns sage green.", "吃点东西或玩一会儿，进度环变成鼠尾草绿。"))
                stateCard(mode: .celebration, title: text("Celebration", "庆祝状态"), description: text("Confetti appears when a focus session finishes.", "专注结束后出现彩屑，一起庆祝完成。"))
            }

            GlassCard {
                HStack(spacing: 18) {
                    PetView(kind: store.selectedPet, mode: store.mode, progress: store.progress, compact: false)
                        .frame(width: 128, height: 128)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(text("Current Companion", "当前伙伴"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text(text("Use floating mode when you want FocusPet to stay above your workspace without the full dashboard.", "想让 FocusPet 保持在桌面最上层时，可以切换到悬浮模式。"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Button {
                        enterFloatingMode()
                    } label: {
                        Label(text("Open Floating Pet", "打开悬浮宠物"), systemImage: "pip.enter")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(CapsuleGradientButtonStyle(color: store.mode.ringColor))
                }
            }

            Spacer()
        }
        .focusPetPagePadding()
    }

    private func stateCard(mode: PomodoroMode, title: String, description: String) -> some View {
        GlassCard {
            VStack(spacing: 14) {
                PetView(kind: store.selectedPet, mode: mode, progress: mode == .celebration ? 1 : 0.62, compact: false)
                    .frame(width: 150, height: 150)

                VStack(spacing: 5) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func text(_ english: String, _ chinese: String) -> String {
        store.language == .chinese ? chinese : english
    }
}
