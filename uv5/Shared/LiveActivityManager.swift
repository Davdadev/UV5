import ActivityKit
import WidgetKit
import SwiftUI

struct UVActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var uvIndex: Double
        var time: String
    }
    var city: String
}

// Helper manager to start/update/end the live activity from the app
enum UVLiveActivityManager {
    static func start(city: String, uvIndex: Double, time: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = UVActivityAttributes(city: city)
        let content = UVActivityAttributes.ContentState(uvIndex: uvIndex, time: time)
        _ = try? Activity<UVActivityAttributes>.request(attributes: attributes, contentState: content, pushType: nil)
    }
    
    static func update(activity: Activity<UVActivityAttributes>, uvIndex: Double, time: String) {
        let content = UVActivityAttributes.ContentState(uvIndex: uvIndex, time: time)
        Task { await activity.update(using: content) }
    }
    
    static func end(activity: Activity<UVActivityAttributes>) {
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }
}
