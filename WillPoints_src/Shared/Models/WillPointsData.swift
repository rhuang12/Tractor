import Foundation

struct WillPointsData: Codable {
    var balance: Int
    var transactions: [Transaction]
    var redemptionPresets: [Redemption]
    var quickIncrementAmount: Int
    var selectedPresetIndex: Int

    init(
        balance: Int = 0,
        transactions: [Transaction] = [],
        redemptionPresets: [Redemption] = Redemption.defaults,
        quickIncrementAmount: Int = 10,
        selectedPresetIndex: Int = 0
    ) {
        self.balance = balance
        self.transactions = transactions
        self.redemptionPresets = redemptionPresets
        self.quickIncrementAmount = quickIncrementAmount
        self.selectedPresetIndex = selectedPresetIndex
    }

    var currentPreset: Redemption? {
        guard !redemptionPresets.isEmpty else { return nil }
        let index = selectedPresetIndex % redemptionPresets.count
        return redemptionPresets[index]
    }

    var canRedeem: Bool {
        guard let preset = currentPreset else { return false }
        return balance >= preset.cost
    }

    mutating func addPoints(_ amount: Int) {
        balance += amount
        transactions.insert(
            Transaction(type: .add, amount: amount),
            at: 0
        )
    }

    mutating func redeem() -> Bool {
        guard let preset = currentPreset, canRedeem else { return false }
        balance -= preset.cost
        transactions.insert(
            Transaction(type: .redeem, amount: preset.cost, note: preset.emoji),
            at: 0
        )
        return true
    }

    mutating func cyclePreset() {
        guard !redemptionPresets.isEmpty else { return }
        selectedPresetIndex = (selectedPresetIndex + 1) % redemptionPresets.count
    }
}
