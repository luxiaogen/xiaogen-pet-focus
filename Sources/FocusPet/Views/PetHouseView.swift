import SwiftUI

struct PetHouseView: View {
    @ObservedObject var store: TimerStore
    let enterFloatingMode: () -> Void
    @State private var careFocus = 0.72
    @State private var careMood = 0.64

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    PageHeader(
                        title: text("Pet House", "宠物屋"),
                        subtitle: text("Pick a companion and preview every Pomodoro mood.", "选择伙伴，并预览每一种番茄钟状态。"),
                        accent: store.mode.ringColor
                    )

                    Spacer()

                    HStack(spacing: 10) {
                        CodexPetImportButton(store: store, compact: true)

                        Picker(text("Pet", "宠物"), selection: $store.selectedPetID) {
                            ForEach(store.availablePets) { pet in
                                Label(pet.title(in: store.language), systemImage: pet.symbolName).tag(pet.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 190)
                    }
                }

                HStack(alignment: .top, spacing: 18) {
                    stateCard(mode: .focus, title: text("Focus State", "专注状态"), description: text("Glasses on. Your pet keeps quiet while you work.", "戴上眼镜，安静陪你进入专注。"))
                    stateCard(mode: .breakTime, title: text("Break State", "休息状态"), description: text("Snack or play time. The ring turns sage green.", "吃点东西或玩一会儿，进度环变成鼠尾草绿。"))
                    stateCard(mode: .celebration, title: text("Celebration", "庆祝状态"), description: text("Confetti appears when a focus session finishes.", "专注结束后出现彩屑，一起庆祝完成。"))
                }

                HStack(alignment: .top, spacing: 18) {
                    careKitCard
                    collectionCard
                }

                GlassCard(tint: store.mode.ringColor) {
                    HStack(spacing: 18) {
                        PetView(pet: store.selectedPet, mode: store.mode, progress: store.progress, compact: false)
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

                        CodexPetImportButton(store: store, compact: false)

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
            }
            .focusPetPagePadding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var careKitCard: some View {
        GlassCard(tint: .breakSage) {
            VStack(alignment: .leading, spacing: 16) {
                Text(text("Care Kit", "照顾工具"))
                    .font(.system(size: 19, weight: .bold, design: .rounded))

                careMeter(title: text("Focus Energy", "专注能量"), value: careFocus, color: .breakSage)
                careMeter(title: text("Mood", "心情"), value: careMood, color: store.mode.ringColor)

                HStack(spacing: 10) {
                    careAction(title: text("Feed", "投喂"), symbol: "leaf.fill") {
                        careFocus = min(1, careFocus + 0.12)
                    }
                    careAction(title: text("Play", "互动"), symbol: "sparkles") {
                        careMood = min(1, careMood + 0.14)
                    }
                    careAction(title: text("Rest", "休息"), symbol: "moon.fill") {
                        careFocus = min(1, careFocus + 0.08)
                        careMood = min(1, careMood + 0.06)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var collectionCard: some View {
        GlassCard(tint: store.mode.ringColor) {
            VStack(alignment: .leading, spacing: 16) {
                Text(text("Collection", "收藏"))
                    .font(.system(size: 19, weight: .bold, design: .rounded))

                collectionRow(title: text("Built-in pets", "内置宠物"), value: "\(PetKind.allCases.count)", symbol: "pawprint.fill")
                collectionRow(title: text("Imported pets", "导入宠物"), value: "\(store.importedPets.count)", symbol: "square.and.arrow.down.fill")
                collectionRow(title: text("Active companion", "当前伙伴"), value: store.selectedPet.title(in: store.language), symbol: store.selectedPet.symbolName)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func stateCard(mode: PomodoroMode, title: String, description: String) -> some View {
        GlassCard(tint: mode.ringColor) {
            VStack(spacing: 14) {
                PetView(pet: store.selectedPet, mode: mode, progress: mode == .celebration ? 1 : 0.62, compact: false)
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

    private func careMeter(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value * 100))%")
                    .fontWeight(.bold)
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.secondary)

            ProgressView(value: value)
                .tint(color)
        }
    }

    private func careAction(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(size: 12, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(GlassCapsuleButtonStyle())
    }

    private func collectionRow(title: String, value: String, symbol: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(store.mode.ringColor)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.bold)
                .lineLimit(1)
        }
        .font(.system(size: 13, weight: .medium))
    }

    private func text(_ english: String, _ chinese: String) -> String {
        store.language == .chinese ? chinese : english
    }
}
