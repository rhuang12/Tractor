import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct WillPointsTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WillPointsEntry {
        WillPointsEntry(date: Date(), data: WillPointsData())
    }

    func getSnapshot(in context: Context, completion: @escaping (WillPointsEntry) -> Void) {
        let data = DataManager.shared.load()
        let entry = WillPointsEntry(date: Date(), data: data)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WillPointsEntry>) -> Void) {
        let data = DataManager.shared.load()
        let entry = WillPointsEntry(date: Date(), data: data)
        // Widget updates on-demand via WidgetCenter.shared.reloadAllTimelines()
        // No need for scheduled updates since we trigger refresh on each interaction
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct WillPointsEntry: TimelineEntry {
    let date: Date
    let data: WillPointsData
}

// MARK: - Widget View

struct WillPointsWidgetView: View {
    var entry: WillPointsEntry

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top row: Balance (65%) | +1 (35%)
                HStack(spacing: 0) {
                    // Balance - tap for quick increment
                    Button(intent: AddQuickIncrementIntent()) {
                        VStack(spacing: 2) {
                            Text("\(entry.data.balance)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            Text("+\(entry.data.quickIncrementAmount)")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)

                    // +1 button
                    Button(intent: AddPointsIntent(amount: 1)) {
                        Text("+1")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.green.opacity(0.25))
                    }
                    .buttonStyle(.plain)
                    .frame(width: geometry.size.width * 0.35)
                }
                .frame(height: geometry.size.height * 0.55)

                // Bottom row: Preset (65%) | Redeem (35%)
                HStack(spacing: 0) {
                    // Preset - tap to cycle
                    Button(intent: CyclePresetIntent()) {
                        VStack(spacing: 1) {
                            if let preset = entry.data.currentPreset {
                                HStack(spacing: 2) {
                                    Text(preset.emoji)
                                        .font(.system(size: 20))
                                    if !preset.label.isEmpty {
                                        Text(preset.label)
                                            .font(.system(size: 11, weight: .medium))
                                            .lineLimit(1)
                                    }
                                }
                                Text("\(preset.cost)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("--")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(.plain)

                    // Redeem button
                    Button(intent: RedeemIntent()) {
                        Text("✓")
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(entry.data.canRedeem ? Color.orange.opacity(0.3) : Color.gray.opacity(0.15))
                            .foregroundStyle(entry.data.canRedeem ? .primary : .tertiary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!entry.data.canRedeem)
                    .frame(width: geometry.size.width * 0.35)
                }
                .frame(height: geometry.size.height * 0.45)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration

struct WillPointsWidget: Widget {
    let kind: String = "WillPointsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WillPointsTimelineProvider()) { entry in
            WillPointsWidgetView(entry: entry)
        }
        .configurationDisplayName("Will Points")
        .description("Track and spend your will points")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Widget Bundle (if you want multiple widgets later)

@main
struct WillPointsWidgetBundle: WidgetBundle {
    var body: some Widget {
        WillPointsWidget()
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    WillPointsWidget()
} timeline: {
    WillPointsEntry(date: .now, data: WillPointsData(balance: 42))
    WillPointsEntry(date: .now, data: WillPointsData(balance: 7))
}
