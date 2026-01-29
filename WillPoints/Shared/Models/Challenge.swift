import Foundation

struct Challenge: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var emoji: String
    var timescale: Timescale
    var lastLapseDate: Date

    enum Timescale: String, Codable, CaseIterable {
        case hours
        case days
        case weeks

        var displayName: String {
            switch self {
            case .hours: return "hours"
            case .days: return "days"
            case .weeks: return "weeks"
            }
        }

        var seconds: TimeInterval {
            switch self {
            case .hours: return 3600
            case .days: return 86400
            case .weeks: return 604800
            }
        }
    }

    init(id: UUID = UUID(), name: String, emoji: String, timescale: Timescale = .days, lastLapseDate: Date = Date()) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.timescale = timescale
        self.lastLapseDate = lastLapseDate
    }

    /// Number of complete units elapsed since last lapse
    var unitsSinceLastLapse: Int {
        let elapsed = Date().timeIntervalSince(lastLapseDate)
        return max(0, Int(elapsed / timescale.seconds))
    }

    /// Calculate bonus points using streak formula
    /// - n ≤ 4: 1 + 0.3 * (n - 1)
    /// - n ≤ 25: 2 + 0.1 * (n - 5)
    /// - n > 25: min(6, 4 + 0.5 * log2(n / 25))
    var currentBonus: Int {
        return Challenge.streakBonus(units: unitsSinceLastLapse)
    }

    /// Static streak bonus calculation
    static func streakBonus(units: Int) -> Int {
        let n = Double(max(1, units))
        let raw: Double
        if n <= 4 {
            raw = 1 + 0.3 * (n - 1)
        } else if n <= 25 {
            raw = 2 + 0.1 * (n - 5)
        } else {
            raw = min(6, 4 + 0.5 * (log(n / 25) / log(2)))
        }
        return Int(raw)
    }

    /// Display string for current streak
    var streakDisplay: String {
        let units = unitsSinceLastLapse
        return "\(units) \(timescale.displayName)"
    }

    static let defaults: [Challenge] = [
        Challenge(name: "snacking", emoji: "🍪", timescale: .hours),
        Challenge(name: "doomscroll", emoji: "📱", timescale: .hours)
    ]
}
