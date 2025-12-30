//
//  uv5App.swift
//  uv5
//
//  Created by David Sebbag on 30/12/2025.
//

import SwiftUI
import WidgetKit

@main
struct uv5App: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
        }
    }
}
