//
//  ShortCuts_For_BeginnersApp.swift
//  ShortCuts For Beginners
//
//  App entry point. The app is fully data-driven — all content lives
//  in ShortcutItem.swift, so no database is needed.
//

import SwiftUI

@main
struct ShortCuts_For_BeginnersApp: App {
    /// Xcode Previews launches the app offscreen while it renders a preview.
    /// Rendering the full split view in that hidden instance triggers a
    /// SwiftUI/AppKit race on macOS 26, so we skip it there — previews
    /// inject their own views and never need the real window content.
    private var isRunningInXcodePreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some Scene {
        WindowGroup {
            if !isRunningInXcodePreviews {
                ContentView()
            }
        }
    }
}
