//
//  widgetLiveActivity.swift
//  widget
//
//  Created by David Sebbag on 30/12/2025.
//

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

struct UVLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: UVActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(spacing: 8) {
                Text(String(format: "%.1f", context.state.uvIndex))
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(UVIndexHelper.colorForIndex(context.state.uvIndex))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(context.attributes.city)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 8)
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(Color.primary)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 6) {
                        Text(String(format: "%.1f", context.state.uvIndex))
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(UVIndexHelper.colorForIndex(context.state.uvIndex))
                        Text(context.attributes.city)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Text(String(format: "%.0f", context.state.uvIndex))
                    .font(.headline)
            } compactTrailing: {
                Text(context.attributes.city.prefix(2).uppercased())
                    .font(.caption2)
            } minimal: {
                Text(String(format: "%.0f", context.state.uvIndex))
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

// Preview support
#Preview("Notification", as: .content, using: UVActivityAttributes(city: "Sydney")) {
    UVLiveActivityWidget()
} contentStates: {
    UVActivityAttributes.ContentState(uvIndex: 8.0, time: "1:13 PM")
    UVActivityAttributes.ContentState(uvIndex: 6.4, time: "12:44 PM")
}
