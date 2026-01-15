import AppIntents
import WidgetKit

// MARK: - Add Points Intent

struct AddPointsIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Will Points"
    static var description = IntentDescription("Adds points to your will points balance")

    @Parameter(title: "Amount")
    var amount: Int

    init() {
        self.amount = 1
    }

    init(amount: Int) {
        self.amount = amount
    }

    func perform() async throws -> some IntentResult {
        DataManager.shared.update { data in
            data.addPoints(amount)
        }
        return .result()
    }
}

// MARK: - Add Quick Increment Intent

struct AddQuickIncrementIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Quick Increment"
    static var description = IntentDescription("Adds your configured quick increment amount")

    func perform() async throws -> some IntentResult {
        DataManager.shared.update { data in
            data.addPoints(data.quickIncrementAmount)
        }
        return .result()
    }
}

// MARK: - Cycle Preset Intent

struct CyclePresetIntent: AppIntent {
    static var title: LocalizedStringResource = "Cycle Preset"
    static var description = IntentDescription("Switches to the next redemption preset")

    func perform() async throws -> some IntentResult {
        DataManager.shared.update { data in
            data.cyclePreset()
        }
        return .result()
    }
}

// MARK: - Redeem Intent

struct RedeemIntent: AppIntent {
    static var title: LocalizedStringResource = "Redeem Points"
    static var description = IntentDescription("Redeems points for the current preset")

    func perform() async throws -> some IntentResult {
        DataManager.shared.update { data in
            _ = data.redeem()
        }
        return .result()
    }
}
