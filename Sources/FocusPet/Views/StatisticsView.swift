import SwiftUI

struct StatisticsView: View {
    @ObservedObject var store: TimerStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                PageHeader(
                    title: text("Statistics", "统计"),
                    subtitle: text("A focused snapshot of today's Pomodoro progress.", "快速查看今天的番茄钟进度。"),
                    accent: store.mode.ringColor
                )

                HStack(spacing: 18) {
                    metricCard(title: text("Completed", "已完成"), value: "\(store.completedSessions)", symbol: "checkmark.circle.fill", color: .breakSage)
                    metricCard(title: text("Daily Goal", "今日目标"), value: "\(store.completedSessions) / 4", symbol: "flag.fill", color: .focusTomato)
                    metricCard(title: text("Current Mode", "当前模式"), value: store.mode.title(in: store.language), symbol: "timer", color: store.mode.ringColor)
                }

                HStack(alignment: .top, spacing: 18) {
                    GlassCard(tint: store.mode.ringColor) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(text("Daily Progress", "今日进度"))
                                .font(.system(size: 19, weight: .bold, design: .rounded))

                            ProgressView(value: min(Double(store.completedSessions) / 4, 1))
                                .tint(store.mode.ringColor)
                                .scaleEffect(y: 1.8)

                            Text(text("Complete four focus sessions to fill the daily goal bar.", "完成 4 个专注番茄钟即可填满今日目标。"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    GlassCard(tint: .breakSage) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(text("Session Mix", "时长配置"))
                                .font(.system(size: 19, weight: .bold, design: .rounded))

                            statRow(label: text("Focus length", "专注时长"), value: durationText(store.focusDuration))
                            statRow(label: text("Break length", "休息时长"), value: durationText(store.breakDuration))
                            statRow(label: text("Selected task", "当前任务"), value: store.localizedTaskTitle(for: store.selectedTask))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                HStack(alignment: .top, spacing: 18) {
                    insightCard
                    streakCard
                }

                GlassCard(tint: store.mode.ringColor) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(text("This Week", "本周概览"))
                            .font(.system(size: 19, weight: .bold, design: .rounded))

                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(0..<7, id: \.self) { index in
                                weekBar(index: index)
                            }
                        }
                        .frame(height: 150)
                    }
                }
            }
            .focusPetPagePadding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var insightCard: some View {
        GlassCard(tint: .celebrationGold) {
            VStack(alignment: .leading, spacing: 14) {
                Text(text("Focus Insight", "专注洞察"))
                    .font(.system(size: 19, weight: .bold, design: .rounded))

                statRow(label: text("Focused minutes", "已专注分钟"), value: durationText(TimeInterval(store.completedSessions) * store.focusDuration))
                statRow(label: text("Goal completion", "目标完成度"), value: "\(Int(min(Double(store.completedSessions) / 4, 1) * 100))%")
                statRow(label: text("Next milestone", "下个里程碑"), value: nextMilestoneText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var streakCard: some View {
        GlassCard(tint: .breakSage) {
            VStack(alignment: .leading, spacing: 14) {
                Text(text("Streak", "连续记录"))
                    .font(.system(size: 19, weight: .bold, design: .rounded))

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(min(store.completedSessions, 4))")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                    Text(text("sessions today", "个今日番茄钟"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                Text(streakDescription)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var nextMilestoneText: String {
        let remaining = max(0, 4 - store.completedSessions)
        if remaining == 0 {
            return text("Goal reached", "目标已达成")
        }
        return text("\(remaining) left", "还差 \(remaining) 个")
    }

    private var streakDescription: String {
        if store.completedSessions >= 4 {
            return text("Daily goal is complete. Keep the streak alive tomorrow.", "今日目标已完成，明天继续保持。")
        }
        return text("Finish four sessions to lock today's streak.", "完成 4 个番茄钟即可点亮今日连续记录。")
    }

    private func metricCard(title: String, value: String, symbol: String, color: Color) -> some View {
        GlassCard(tint: color) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(color.opacity(0.13), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                }
                Spacer()
            }
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.system(size: 14))
    }

    private func weekBar(index: Int) -> some View {
        let values = [2, 3, 1, max(store.completedSessions, 1), 0, 0, 0]
        let labels = store.language == .chinese ? ["一", "二", "三", "四", "五", "六", "日"] : ["M", "T", "W", "T", "F", "S", "S"]
        let height = CGFloat(values[index]) * 24 + 18

        return VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(index == 3 ? store.mode.ringColor.gradient : Color.primary.opacity(0.12).gradient)
                .frame(height: height)
            Text(labels[index])
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private func durationText(_ duration: TimeInterval) -> String {
        "\(Int(duration / 60)) min"
    }

    private func text(_ english: String, _ chinese: String) -> String {
        store.language == .chinese ? chinese : english
    }
}
