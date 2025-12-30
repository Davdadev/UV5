import Foundation

struct SelectedCityManager {
    private static let key = "SelectedCity"
    // Use the same App Group ID as SharedWidgetCache
    private static let appGroupID = "group.uvdata" // TODO: set your real group ID
    
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    static func get() -> String? {
        defaults?.string(forKey: key)
    }
    
    static func set(_ city: String) {
        defaults?.set(city, forKey: key)
    }
    
    static func hasSelection() -> Bool {
        return get() != nil
    }
    
    static func clear() {
        defaults?.removeObject(forKey: key)
    }
}
