import Foundation

struct Redemption: Codable, Identifiable, Equatable {
    var id: UUID
    var emoji: String
    var label: String  // Optional description, up to 8 chars
    var cost: Int

    init(id: UUID = UUID(), emoji: String, label: String = "", cost: Int) {
        self.id = id
        self.emoji = emoji
        self.label = String(label.prefix(8))
        self.cost = cost
    }

    static let defaults: [Redemption] = [
        Redemption(emoji: "🤷", label: "zen", cost: 1),
        Redemption(emoji: "🍪", label: "snack", cost: 5),
        Redemption(emoji: "🍷", label: "wine", cost: 10),
        Redemption(emoji: "🫠", label: "release", cost: 20)
    ]
}
