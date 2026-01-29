import SwiftUI

struct SettingsView: View {
    @State private var data = DataManager.shared.load()
    @State private var showingAddPreset = false
    @State private var newEmoji = ""
    @State private var newLabel = ""
    @State private var newCost = ""

    @State private var showingAddChallenge = false
    @State private var newChallengeEmoji = ""
    @State private var newChallengeName = ""
    @State private var newChallengeTimescale: Challenge.Timescale = .days

    var body: some View {
        Form {
            // Quick increment setting
            Section {
                Stepper(value: $data.quickIncrementAmount, in: 1...100) {
                    HStack {
                        Text("Quick add amount")
                        Spacer()
                        Text("\(data.quickIncrementAmount)")
                            .foregroundStyle(.secondary)
                    }
                }
                .onChange(of: data.quickIncrementAmount) { _, _ in
                    DataManager.shared.save(data)
                }
            } header: {
                Text("Quick Add")
            } footer: {
                Text("Tapping the balance adds this many points")
            }

            // Redemption presets
            Section {
                ForEach(data.redemptionPresets) { preset in
                    HStack {
                        Text(preset.emoji)
                            .font(.title2)
                        if !preset.label.isEmpty {
                            Text(preset.label)
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                        Text("\(preset.cost) pts")
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: deletePreset)
                .onMove(perform: movePreset)

                Button(action: { showingAddPreset = true }) {
                    Label("Add Preset", systemImage: "plus")
                }
            } header: {
                Text("Redemption Presets")
            } footer: {
                Text("Tap an emoji in the main view to cycle through these")
            }

            // Challenges
            Section {
                ForEach(data.challenges) { challenge in
                    HStack {
                        Text(challenge.emoji)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(challenge.name)
                            Text(challenge.timescale.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(challenge.streakDisplay)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: deleteChallenge)
                .onMove(perform: moveChallenge)

                Button(action: { showingAddChallenge = true }) {
                    Label("Add Challenge", systemImage: "plus")
                }
            } header: {
                Text("Challenges")
            } footer: {
                Text("Track things you're resisting. Lapsing earns points based on streak length.")
            }

            // Danger zone
            Section {
                Button(role: .destructive, action: resetBalance) {
                    Text("Reset Balance to Zero")
                }

                Button(role: .destructive, action: clearHistory) {
                    Text("Clear Transaction History")
                }

                Button(role: .destructive, action: resetToDefaults) {
                    Text("Reset Everything to Defaults")
                }
            } header: {
                Text("Reset")
            }

            // Debug info
            Section {
                LabeledContent("Current Balance", value: "\(data.balance)")
                LabeledContent("Total Transactions", value: "\(data.transactions.count)")
                LabeledContent("Presets Count", value: "\(data.redemptionPresets.count)")
                LabeledContent("Challenges Count", value: "\(data.challenges.count)")
            } header: {
                Text("Debug")
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $showingAddPreset) {
            AddPresetSheet(
                emoji: $newEmoji,
                label: $newLabel,
                cost: $newCost,
                onSave: addPreset,
                onCancel: { showingAddPreset = false }
            )
        }
        .sheet(isPresented: $showingAddChallenge) {
            AddChallengeSheet(
                emoji: $newChallengeEmoji,
                name: $newChallengeName,
                timescale: $newChallengeTimescale,
                onSave: addChallenge,
                onCancel: { showingAddChallenge = false }
            )
        }
        .onAppear {
            data = DataManager.shared.load()
        }
    }

    private func deletePreset(at offsets: IndexSet) {
        // Prevent deleting the last preset
        guard data.redemptionPresets.count > 1 else { return }
        data.redemptionPresets.remove(atOffsets: offsets)
        // Adjust selected index if needed
        if data.selectedPresetIndex >= data.redemptionPresets.count {
            data.selectedPresetIndex = 0
        }
        DataManager.shared.save(data)
    }

    private func movePreset(from source: IndexSet, to destination: Int) {
        data.redemptionPresets.move(fromOffsets: source, toOffset: destination)
        DataManager.shared.save(data)
    }

    private func addPreset() {
        guard !newEmoji.isEmpty, let cost = Int(newCost), cost > 0 else { return }
        let preset = Redemption(emoji: String(newEmoji.prefix(2)), label: newLabel, cost: cost)
        data.redemptionPresets.append(preset)
        DataManager.shared.save(data)
        newEmoji = ""
        newLabel = ""
        newCost = ""
        showingAddPreset = false
    }

    private func resetBalance() {
        data.balance = 0
        DataManager.shared.save(data)
    }

    private func clearHistory() {
        data.transactions = []
        DataManager.shared.save(data)
    }

    private func resetToDefaults() {
        data = WillPointsData()
        DataManager.shared.save(data)
    }

    private func deleteChallenge(at offsets: IndexSet) {
        data.challenges.remove(atOffsets: offsets)
        DataManager.shared.save(data)
    }

    private func moveChallenge(from source: IndexSet, to destination: Int) {
        data.challenges.move(fromOffsets: source, toOffset: destination)
        DataManager.shared.save(data)
    }

    private func addChallenge() {
        guard !newChallengeEmoji.isEmpty, !newChallengeName.isEmpty else { return }
        let challenge = Challenge(
            name: newChallengeName,
            emoji: String(newChallengeEmoji.prefix(2)),
            timescale: newChallengeTimescale
        )
        data.challenges.append(challenge)
        DataManager.shared.save(data)
        newChallengeEmoji = ""
        newChallengeName = ""
        newChallengeTimescale = .days
        showingAddChallenge = false
    }
}

struct AddPresetSheet: View {
    @Binding var emoji: String
    @Binding var label: String
    @Binding var cost: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var isValid: Bool {
        !emoji.isEmpty && (Int(cost) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Emoji", text: $emoji)
                        .font(.largeTitle)
                    TextField("Label (optional, 8 chars max)", text: $label)
                        .onChange(of: label) { _, newValue in
                            if newValue.count > 8 {
                                label = String(newValue.prefix(8))
                            }
                        }
                    TextField("Cost (points)", text: $cost)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("New Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: onSave)
                        .disabled(!isValid)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct AddChallengeSheet: View {
    @Binding var emoji: String
    @Binding var name: String
    @Binding var timescale: Challenge.Timescale
    let onSave: () -> Void
    let onCancel: () -> Void

    var isValid: Bool {
        !emoji.isEmpty && !name.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Emoji", text: $emoji)
                        .font(.largeTitle)
                    TextField("Name (e.g., snacking)", text: $name)
                    Picker("Timescale", selection: $timescale) {
                        ForEach(Challenge.Timescale.allCases, id: \.self) { scale in
                            Text(scale.displayName).tag(scale)
                        }
                    }
                }

                Section {
                    Text("Points earned on lapse depend on streak length:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("1-4 \(timescale.displayName): 1 pt")
                    Text("5-25 \(timescale.displayName): 2-4 pts")
                    Text("25+ \(timescale.displayName): 4-6 pts")
                }
            }
            .navigationTitle("New Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: onSave)
                        .disabled(!isValid)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
