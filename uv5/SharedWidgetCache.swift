import Foundation

struct SharedWidgetCache {
    // Replace this with your actual App Group identifier and enable the capability
    // in both the app target and the widget extension target.
    static let appGroupID = "group.uvdata" // TODO: set your real group ID
    
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    private static let itemsKey = "cachedUVItems"
    private static let dateKey = "cachedUVItemsDate"
    
    static func save(items: [CachedItem]) {
        guard let defaults else { return }
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(items) {
            defaults.set(data, forKey: itemsKey)
            defaults.set(Date(), forKey: dateKey)
        }
    }
    
    static func load() -> (items: [CachedItem], date: Date)? {
        guard let defaults,
              let data = defaults.data(forKey: itemsKey) else { return nil }
        let decoder = JSONDecoder()
        guard let items = try? decoder.decode([CachedItem].self, from: data) else { return nil }
        let date = defaults.object(forKey: dateKey) as? Date ?? Date()
        return (items, date)
    }
}

struct CachedItem: Codable, Equatable {
    let id: String
    let name: String
    let index: Double
    let time: String
}
