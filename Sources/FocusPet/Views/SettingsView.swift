import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: TimerStore
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange
    @AppStorage("settings.soundCuesEnabled") private var soundCuesEnabled = true
    @AppStorage("settings.autoStartBreak") private var autoStartBreak = false
    @AppStorage("settings.showProgressGlow") private var showProgressGlow = true
    @AppStorage("settings.compactDashboard") private var compactDashboard = false

    var body: some View {
        FocusPetScrollPage {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.section) {
                PageHeader(
                    title: text("Settings", "设置"),
                    subtitle: text("Tune the FocusPet session and interface defaults.", "调整 FocusPet 的番茄钟和界面偏好。"),
                    accent: store.mode.ringColor(in: theme)
                )

                AdaptivePair {
                    GlassCard(tint: store.mode.ringColor(in: theme)) {
                        VStack(alignment: .leading, spacing: 18) {
                            FocusPetSectionTitle(title: text("Timer", "计时器"), symbol: "timer", accent: store.mode.ringColor(in: theme))

                            Stepper(value: focusMinutes, in: 5...60, step: 5) {
                                FocusPetInfoRow(title: text("Focus duration", "专注时长"), value: "\(Int(store.focusDuration / 60)) min", symbol: "bolt.fill", accent: store.mode.ringColor(in: theme))
                            }

                            Stepper(value: breakMinutes, in: 1...30, step: 1) {
                                FocusPetInfoRow(title: text("Break duration", "休息时长"), value: "\(Int(store.breakDuration / 60)) min", symbol: "leaf.fill", accent: theme.breakColor)
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
                } trailing: {
                    GlassCard(tint: theme.breakColor) {
                        VStack(alignment: .leading, spacing: 18) {
                            FocusPetSectionTitle(title: text("Interface", "界面"), symbol: "paintpalette.fill", accent: theme.breakColor)

                            Picker(text("Language", "语言"), selection: $store.language) {
                                ForEach(AppLanguage.allCases) { language in
                                    Text(language.shortTitle).tag(language)
                                }
                            }
                            .pickerStyle(.segmented)

                            Picker(text("Theme", "主题"), selection: $theme) {
                                ForEach(AppTheme.allCases) { t in
                                    Text(t.title(in: store.language)).tag(t)
                                }
                            }
                            .pickerStyle(.segmented)

                            Picker(text("Companion", "伙伴"), selection: $store.selectedPetID) {
                                ForEach(store.availablePets) { pet in
                                    Label(pet.title(in: store.language), systemImage: pet.symbolName).tag(pet.id)
                                }
                            }
                            .pickerStyle(.menu)

                            CodexPetImportButton(store: store, compact: false)

                            Picker(text("Default task", "默认任务"), selection: $store.selectedTaskID) {
                                ForEach(store.tasks) { task in
                                    Text(store.localizedTaskTitle(for: task.id)).tag(task.id)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                AdaptivePair {
                    remindersCard
                } trailing: {
                    displayCard
                }

                GlassCard(tint: store.mode.ringColor(in: theme)) {
                    HStack(spacing: 18) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(store.mode.ringColor(in: theme))
                        Text(text("Settings are applied immediately. Interface preferences are remembered on this Mac.", "设置会立即应用，界面偏好会保存在这台 Mac 上。"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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

    private var remindersCard: some View {
        GlassCard(tint: .celebrationGold) {
            VStack(alignment: .leading, spacing: 18) {
                FocusPetSectionTitle(title: text("Reminders", "提醒"), symbol: "bell.badge.fill", accent: .celebrationGold)

                Toggle(isOn: $soundCuesEnabled) {
                    FocusPetInfoRow(title: text("Sound cues", "声音提示"), value: soundCuesEnabled ? text("On", "开启") : text("Off", "关闭"), symbol: "speaker.wave.2.fill", accent: .celebrationGold)
                }

                Toggle(isOn: $autoStartBreak) {
                    FocusPetInfoRow(title: text("Auto-start break", "自动开始休息"), value: autoStartBreak ? text("On", "开启") : text("Manual", "手动"), symbol: "play.circle.fill", accent: .celebrationGold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var displayCard: some View {
        GlassCard(tint: store.mode.ringColor(in: theme)) {
            VStack(alignment: .leading, spacing: 18) {
                FocusPetSectionTitle(title: text("Display", "显示"), symbol: "display", accent: store.mode.ringColor(in: theme))

                Toggle(isOn: $showProgressGlow) {
                    FocusPetInfoRow(title: text("Progress glow", "进度光效"), value: showProgressGlow ? text("On", "开启") : text("Off", "关闭"), symbol: "sparkles", accent: store.mode.ringColor(in: theme))
                }

                Toggle(isOn: $compactDashboard) {
                    FocusPetInfoRow(title: text("Compact dashboard", "紧凑仪表盘"), value: compactDashboard ? text("Compact", "紧凑") : text("Comfort", "舒适"), symbol: "rectangle.compress.vertical", accent: store.mode.ringColor(in: theme))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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

    private func text(_ english: String, _ chinese: String) -> String {
        store.language == .chinese ? chinese : english
    }
}
