import SwiftUI

struct MainView: View {
    @State private var data = DataManager.shared.load()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top row: Balance and +1
                HStack(spacing: 0) {
                    // Balance display - tap to add quick increment
                    Button(action: addQuickIncrement) {
                        VStack(spacing: 4) {
                            Text("\(data.balance)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            Text("will points")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("tap for +\(data.quickIncrementAmount)")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    // +1 button
                    Button(action: addOne) {
                        Text("+1")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.green.opacity(0.2))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(width: UIScreen.main.bounds.width * 0.35)
                }
                .frame(height: 200)

                Divider()

                // Bottom row: Preset and Redeem
                HStack(spacing: 0) {
                    // Preset display - tap to cycle
                    Button(action: cyclePreset) {
                        VStack(spacing: 4) {
                            if let preset = data.currentPreset {
                                HStack(spacing: 4) {
                                    Text(preset.emoji)
                                        .font(.system(size: 40))
                                    if !preset.label.isEmpty {
                                        Text(preset.label)
                                            .font(.system(size: 20, weight: .medium))
                                    }
                                }
                                Text("\(preset.cost) pts")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("No presets")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    // Redeem button
                    Button(action: redeem) {
                        Text("Redeem")
                            .font(.system(size: 24, weight: .semibold))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(data.canRedeem ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1))
                            .foregroundStyle(data.canRedeem ? .primary : .tertiary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!data.canRedeem)
                    .frame(width: UIScreen.main.bounds.width * 0.35)
                }
                .frame(height: 150)

                Divider()

                Spacer()
            }
            .navigationTitle("Will Points")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .onAppear {
            data = DataManager.shared.load()
        }
    }

    private func addQuickIncrement() {
        data.addPoints(data.quickIncrementAmount)
        DataManager.shared.save(data)
    }

    private func addOne() {
        data.addPoints(1)
        DataManager.shared.save(data)
    }

    private func cyclePreset() {
        data.cyclePreset()
        DataManager.shared.save(data)
    }

    private func redeem() {
        if data.redeem() {
            DataManager.shared.save(data)
        }
    }
}

#Preview {
    MainView()
}
