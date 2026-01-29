import Foundation

struct Transaction: Codable, Identifiable {
    enum TransactionType: String, Codable {
        case add
        case redeem
        case lapse  // Points earned from lapsing on a challenge
    }

    var id: UUID
    var type: TransactionType
    var amount: Int
    var timestamp: Date
    var note: String?

    init(id: UUID = UUID(), type: TransactionType, amount: Int, timestamp: Date = Date(), note: String? = nil) {
        self.id = id
        self.type = type
        self.amount = amount
        self.timestamp = timestamp
        self.note = note
    }
}
