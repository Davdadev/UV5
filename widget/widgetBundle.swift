//
//  widgetBundle.swift
//  widget
//
//  Created by David Sebbag on 30/12/2025.
//

import WidgetKit
import SwiftUI

@main
struct UVWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        widget()
        // Include Live Activity if needed
        UVLiveActivityWidget()
    }
}
