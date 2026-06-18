import SwiftUI

struct StatisticsView: View {
    @ObservedObject var store: TimerStore
    @AppStorage("settings.appTheme") private var theme: AppTheme = .warmOrange

    var body: some View {
        FocusPetScrollPage {
            VStack(alignment: .leading, spacing: FocusPetLayout.sectionSpacing) {
                PageHeader(
                    title: text("Statistics", "统计"),
                    subtitle: text("A focused snapshot of your Pomodoro progress.", "快速查看你的番茄钟进度。"),
                    accent: store.mode.ringColor(in: theme)
                )

                AdaptiveTriplet {
                    metricCard(title: text("Completed", "已完成"), value: "\(store.completedSessions)", symbol: "checkmark.circle.fill", color: theme.breakColor)
                } second: {
                    metricCard(title: text("Today", "今日"), value: durationText(store.todayFocusSeconds), symbol: "sun.max.fill", color: store.mode.ringColor(in: theme))
                } third: {
                    metricCard(title: text("All-time", "累计"), value: durationText(store.totalFocusSeconds), symbol: "trophy.fill", color: .celebrationGold)
                }

                weeklyBarsCard
                distributionComparisonRow

                AdaptivePair {
                    focusBreakCard
                } trailing: {
                    periodComparisonCard
                }

                AdaptivePair {
                    insightCard
                } trailing: {
                    streakCard
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Weekly bars (real data)

    private var weeklyBarsCard: some View {
        GlassCard(tint: store.mode.ringColor(in: theme)) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    FocusPetSectionTitle(title: text("Last 7 Days", "近 7 天"), symbol: "chart.bar.fill", accent: store.mode.ringColor(in: theme))
                    Spacer()
                    Text(durationText(store.weekFocusSeconds))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }

                WeeklyBarsView(
                    data: store.last7DaysFocusSeconds,
                    accent: store.mode.ringColor(in: theme),
                    isChinese: store.language == .chinese,
                    format: durationShortText
                )
                .frame(height: 170)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Distribution donut + legend

    private var distributionComparisonRow: some View {
        AdaptivePair {
            distributionCard
        } trailing: {
            streakSnapshotCard
        }
    }

    private var distributionCard: some View {
        GlassCard(tint: .celebrationGold) {
            VStack(alignment: .leading, spacing: 16) {
                FocusPetSectionTitle(title: text("Task Distribution", "任务分布"), symbol: "chart.pie.fill", accent: .celebrationGold)

                let slices = distributionSlices
                if slices.isEmpty {
                    emptyHint(text("Complete a focus session to see task distribution.", "完成一个专注会话即可看到任务分布。"))
                } else {
                    HStack(spacing: 18) {
                        TaskDonutView(slices: slices)
                            .frame(width: 130, height: 130)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(slices.prefix(5)) { slice in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(slice.color)
                                        .frame(width: 9, height: 9)
                                    Text(slice.task)
                                        .font(.system(size: 12, weight: .medium))
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                    Text(durationShortText(slice.seconds))
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var streakSnapshotCard: some View {
        GlassCard(tint: theme.breakColor) {
            VStack(alignment: .leading, spacing: 16) {
                FocusPetSectionTitle(title: text("Focus vs Break", "专注与休息"), symbol: "scalemass.fill", accent: theme.breakColor)

                let focus = store.totalFocusSeconds
                let breakTime = store.breakTotalSeconds
                let total = max(focus + breakTime, 1)

                VStack(alignment: .leading, spacing: 12) {
                    FocusPetProgressRow(title: text("Focus", "专注"), value: focus / total, accent: theme.accentColor)
                    FocusPetProgressRow(title: text("Break", "休息"), value: breakTime / total, accent: theme.breakColor)
                }

                HStack(spacing: 16) {
                    statBlock(value: durationShortText(focus), label: text("Focus", "专注"), color: theme.accentColor)
                    statBlock(value: durationShortText(breakTime), label: text("Break", "休息"), color: theme.breakColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Period comparison

    private var focusBreakCard: some View {
        GlassCard(tint: store.mode.ringColor(in: theme)) {
            VStack(alignment: .leading, spacing: 16) {
                FocusPetSectionTitle(title: text("This Week", "本周概览"), symbol: "calendar", accent: store.mode.ringColor(in: theme))

                HStack(spacing: 14) {
                    statBlock(value: durationShortText(store.todayFocusSeconds), label: text("Today", "今日"), color: store.mode.ringColor(in: theme))
                    Divider().frame(height: 44)
                    statBlock(value: durationShortText(store.weekFocusSeconds), label: text("This Week", "本周"), color: .celebrationGold)
                    Divider().frame(height: 44)
                    statBlock(value: durationShortText(store.totalFocusSeconds), label: text("All-time", "累计"), color: theme.breakColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var periodComparisonCard: some View {
        GlassCard(tint: theme.breakColor) {
            VStack(alignment: .leading, spacing: 14) {
                FocusPetSectionTitle(title: text("Session Mix", "时长配置"), symbol: "slider.horizontal.3", accent: theme.breakColor)

                FocusPetInfoRow(title: text("Focus length", "专注时长"), value: durationText(store.focusDuration), symbol: "timer", accent: theme.breakColor)
                FocusPetInfoRow(title: text("Break length", "休息时长"), value: durationText(store.breakDuration), symbol: "cup.and.saucer.fill", accent: theme.breakColor)
                FocusPetInfoRow(title: text("Selected task", "当前任务"), value: store.localizedTaskTitle(for: store.selectedTaskID), symbol: "checklist", accent: theme.breakColor)
                FocusPetInfoRow(title: text("Daily goal", "每日目标"), value: "\(store.completedSessions) / \(TimerStore.dailyGoal)", symbol: "flag.fill", accent: theme.breakColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var insightCard: some View {
        GlassCard(tint: .celebrationGold) {
            VStack(alignment: .leading, spacing: 14) {
                FocusPetSectionTitle(title: text("Focus Insight", "专注洞察"), symbol: "lightbulb.fill", accent: .celebrationGold)

                FocusPetInfoRow(title: text("Focused minutes", "已专注分钟"), value: durationText(store.todayFocusSeconds), symbol: "clock.fill", accent: .celebrationGold)
                FocusPetInfoRow(title: text("Goal completion", "目标完成度"), value: "\(Int(min(Double(store.completedSessions) / Double(TimerStore.dailyGoal), 1) * 100))%", symbol: "target", accent: .celebrationGold)
                FocusPetInfoRow(title: text("Next milestone", "下个里程碑"), value: nextMilestoneText, symbol: "flag.fill", accent: .celebrationGold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var streakCard: some View {
        GlassCard(tint: theme.breakColor) {
            VStack(alignment: .leading, spacing: 14) {
                FocusPetSectionTitle(title: text("Streak", "连续记录"), symbol: "flame.fill", accent: theme.breakColor)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(min(store.completedSessions, TimerStore.dailyGoal))")
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

    // MARK: - Helpers

    private var distributionSlices: [DistributionSlice] {
        let palette: [Color] = [theme.accentColor, theme.breakColor, .celebrationGold, .blue, .pink, .purple, .teal]
        return store.perTaskFocusSeconds.enumerated().map { index, item in
            DistributionSlice(task: item.task, seconds: item.seconds, color: palette[index % palette.count])
        }
    }

    private func statBlock(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .monospacedDigit()
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metricCard(title: String, value: String, symbol: String, color: Color) -> some View {
        FocusPetMetricTile(title: title, value: value, symbol: symbol, accent: color)
    }

    private func emptyHint(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 24)
    }

    private var nextMilestoneText: String {
        let remaining = max(0, TimerStore.dailyGoal - store.completedSessions)
        if remaining == 0 {
            return text("Goal reached", "目标已达成")
        }
        return text("\(remaining) left", "还差 \(remaining) 个")
    }

    private var streakDescription: String {
        if store.completedSessions >= TimerStore.dailyGoal {
            return text("Daily goal is complete. Keep the streak alive tomorrow.", "今日目标已完成，明天继续保持。")
        }
        return text("Finish \(TimerStore.dailyGoal) sessions to lock today's streak.", "完成 \(TimerStore.dailyGoal) 个番茄钟即可点亮今日连续记录。")
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        if minutes >= 60 {
            return "\(minutes / 60) h \(minutes % 60) min"
        }
        return "\(minutes) min"
    }

    private func durationShortText(_ duration: TimeInterval) -> String {
        let totalMinutes = Int(duration / 60)
        if totalMinutes >= 60 {
            return String(format: "%.1f h", Double(totalMinutes) / 60)
        }
        return "\(totalMinutes) m"
    }

    private func text(_ english: String, _ chinese: String) -> String {
        store.language == .chinese ? chinese : english
    }
}

// MARK: - Weekly bars chart

private struct WeeklyBarsView: View {
    let data: [TimerStore.DayFocus]
    let accent: Color
    let isChinese: Bool
    let format: (TimeInterval) -> String

    var body: some View {
        GeometryReader { proxy in
            let maxValue = max(data.map(\.seconds).max() ?? 0, 60 * 30)
            let barWidth = max(18, (proxy.size.width - CGFloat(data.count - 1) * 12) / CGFloat(data.count))

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, day in
                    weeklyBar(
                        index: index,
                        day: day,
                        maxValue: maxValue,
                        availableHeight: proxy.size.height - 28,
                        barWidth: barWidth
                    )
                }
            }
        }
    }

    private func weeklyBar(index: Int, day: TimerStore.DayFocus, maxValue: TimeInterval, availableHeight: CGFloat, barWidth: CGFloat) -> some View {
        let ratio = maxValue > 0 ? CGFloat(day.seconds / maxValue) : 0
        let height = max(ratio * availableHeight, 4)
        let isToday = index == data.count - 1
        let isZero = day.seconds <= 0

        return VStack(spacing: 8) {
            if !isZero {
                Text(format(day.seconds))
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(isToday ? accent.gradient : (isZero ? Color.primary.opacity(0.08) : Color.primary.opacity(0.16)).gradient)
                .frame(width: barWidth, height: height)
                .overlay {
                    if isToday {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                    }
                }

            Text(weekdayLabel(for: day.day))
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(isToday ? accent : .secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private func weekdayLabel(for date: Date) -> String {
        let symbols = isChinese
            ? ["日", "一", "二", "三", "四", "五", "六"]
            : ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        let weekdayIndex = Calendar.current.component(.weekday, from: date) - 1
        return symbols[max(0, weekdayIndex) % symbols.count]
    }
}

// MARK: - Distribution slice model

private struct DistributionSlice: Identifiable {
    /// Stable identity keyed by task name so SwiftUI can diff slices
    /// across re-renders instead of rebuilding the donut every refresh.
    var id: String { task }
    let task: String
    let seconds: TimeInterval
    let color: Color
}

// MARK: - Task donut chart

private struct TaskDonutView: View {
    let slices: [DistributionSlice]

    var body: some View {
        Canvas { context, size in
            guard !slices.isEmpty else { return }
            let total = slices.reduce(0) { $0 + $1.seconds }
            guard total > 0 else { return }

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            let innerRadius = radius * 0.62

            var startAngle = Angle.degrees(-90)
            for slice in slices {
                let portion = slice.seconds / total
                let endAngle = startAngle + .degrees(360 * portion)

                let path = donutPath(center: center, innerRadius: innerRadius, outerRadius: radius, start: startAngle, end: endAngle)
                context.fill(path, with: .color(slice.color))

                startAngle = endAngle
            }
        }
        .overlay {
            Circle()
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                .padding(0)
        }
        .overlay {
            VStack(spacing: 1) {
                Text(centerText)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("total")
                    .font(.system(size: 9, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var centerText: String {
        let total = slices.reduce(0) { $0 + $1.seconds }
        let minutes = Int(total / 60)
        if minutes >= 60 {
            return String(format: "%.1f h", Double(minutes) / 60)
        }
        return "\(minutes) m"
    }

    private func donutPath(center: CGPoint, innerRadius: CGFloat, outerRadius: CGFloat, start: Angle, end: Angle) -> Path {
        var path = Path()

        let startOuter = point(center: center, radius: outerRadius, angle: start)
        let startInner = point(center: center, radius: innerRadius, angle: end)

        path.move(to: startOuter)
        path.addArc(center: center, radius: outerRadius, startAngle: start, endAngle: end, clockwise: false)
        path.addLine(to: startInner)
        path.addArc(center: center, radius: innerRadius, startAngle: end, endAngle: start, clockwise: true)
        path.closeSubpath()
        return path
    }

    private func point(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        let radians = angle.radians
        return CGPoint(
            x: center.x + cos(radians) * radius,
            y: center.y + sin(radians) * radius
        )
    }
}
