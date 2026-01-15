import Foundation

struct Redemption: Codable, Identifiable, Equatable {
    var id: UUID
    var emoji: String
    var cost: Int

    init(id: UUID = UUID(), emoji: String, cost: Int) {
        self.id = id
        self.emoji = emoji
        self.cost = cost
    }

    static let defaults: [Redemption] = [
        Redemption(emoji: "🤷", cost: 1),   // Moment of zen
        Redemption(emoji: "🍪", cost: 5),   // Snack
        Redemption(emoji: "🍷", cost: 10),  // Wine
        Redemption(emoji: "🫠", cost: 20)   // Release
    ]
}
