import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: TimerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            PageHeader(
                title: text("Settings", "设置"),
                subtitle: text("Tune the FocusPet session and interface defaults.", "调整 FocusPet 的番茄钟和界面偏好。")
            )

            HStack(alignment: .top, spacing: 18) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(text("Timer", "计时器"))
                            .font(.system(size: 19, weight: .bold, design: .rounded))

                        Stepper(value: focusMinutes, in: 5...60, step: 5) {
                            settingRow(title: text("Focus duration", "专注时长"), value: "\(Int(store.focusDuration / 60)) min")
                        }

                        Stepper(value: breakMinutes, in: 1...30, step: 1) {
                            settingRow(title: text("Break duration", "休息时长"), value: "\(Int(store.breakDuration / 60)) min")
                        }

                        Button {
                            store.resetCurrentMode()
                        } label: {
                            Label(text("Reset Current Timer", "重置当前计时器"), systemImage: "arrow.counterclockwise")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(GlassCapsuleButtonStyle())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(text("Interface", "界面"))
                            .font(.system(size: 19, weight: .bold, design: .rounded))

                        Picker(text("Language", "语言"), selection: $store.language) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.shortTitle).tag(language)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker(text("Companion", "伙伴"), selection: $store.selectedPet) {
                            ForEach(PetKind.allCases) { pet in
                                Label(pet.title(in: store.language), systemImage: pet.symbolName).tag(pet)
                            }
                        }
                        .pickerStyle(.menu)

                        Picker(text("Default task", "默认任务"), selection: $store.selectedTask) {
                            ForEach(store.tasks, id: \.self) { task in
                                Text(store.localizedTaskTitle(for: task)).tag(task)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            GlassCard {
                HStack(spacing: 18) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(store.mode.ringColor)
                    Text(text("Settings are applied immediately for the current run. Persistence is intentionally outside this MVP.", "设置会立即应用到当前运行。本 MVP 暂不包含持久化保存。"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }

            Spacer()
        }
        .focusPetPagePadding()
    }

    private var focusMinutes: Binding<Double> {
        Binding {
            store.focusDuration / 60
        } set: { newValue in
            store.focusDuration = newValue * 60
            if store.mode == .focus {
                store.resetCurrentMode()
            }
        }
    }

    private var breakMinutes: Binding<Double> {
        Binding {
            store.breakDuration / 60
        } set: { newValue in
            store.breakDuration = newValue * 60
            if store.mode == .breakTime {
                store.resetCurrentMode()
            }
        }
    }

    private func settingRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .font(.system(size: 14, weight: .medium))
    }

    private func text(_ english: String, _ chinese: String) -> String {
        store.language == .chinese ? chinese : english
    }
}
