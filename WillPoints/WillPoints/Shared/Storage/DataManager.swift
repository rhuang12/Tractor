import Foundation
import WidgetKit

/// Manages persistent storage of WillPointsData in App Groups shared container.
/// Both the app and widget read/write to the same JSON file.
final class DataManager {
    static let shared = DataManager()

    // IMPORTANT: Replace with your actual App Group identifier after creating it in Xcode
    // Format: group.com.yourname.WillPoints
    private let appGroupIdentifier = "group.com.willpoints.shared"
    private let fileName = "willpoints_data.json"

    private var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent(fileName)
    }

    private init() {}

    /// Loads data from disk. Returns default data if file doesn't exist or is corrupted.
    func load() -> WillPointsData {
        guard let url = fileURL else {
            print("DataManager: App Group container not available")
            return WillPointsData()
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(WillPointsData.self, from: data)
            return decoded
        } catch {
            // File doesn't exist yet or is corrupted - return defaults
            print("DataManager: Loading failed (\(error.localizedDescription)), using defaults")
            return WillPointsData()
        }
    }

    /// Saves data to disk and triggers widget refresh.
    func save(_ data: WillPointsData) {
        guard let url = fileURL else {
            print("DataManager: App Group container not available")
            return
        }

        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url, options: .atomic)

            // Tell the widget to refresh its timeline
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("DataManager: Saving failed - \(error.localizedDescription)")
        }
    }

    /// Atomic update: load, modify, save in one operation.
    func update(_ transform: (inout WillPointsData) -> Void) {
        var data = load()
        transform(&data)
        save(data)
    }
}
