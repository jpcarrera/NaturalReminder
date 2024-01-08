//
//  NaturalReminderApp.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 01.10.2023.
//

import SwiftUI
import Cocoa

@main
struct NaturalReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var settings = SettingsData()
    @StateObject var settingsWindowManager = SettingsWindowManager()

    var body: some Scene {
        WindowGroup {
            ContentView(appDelegate: appDelegate)
                .environmentObject(settings)
                .onAppear(perform: checkFirstLaunch)
        }
        .commands {
            settingsMenu
        }
    }
    
    var settingsMenu: some Commands {
        CommandMenu("Settings") {
            Button("Open Settings", action: settingsWindowManager.showSettings)
        }
    }
    
    func checkFirstLaunch() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "hasLaunchedBefore") {
            settings.isDarkMode = isDarkMode()
            defaults.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    func isDarkMode() -> Bool {
        let currentAppearance = NSApplication.shared.effectiveAppearance
        return currentAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}

class SettingsWindowManager: ObservableObject {
    var settingsWindow: NSWindow!

    func showSettings() {
        let settingsView = SettingsView()
        settingsWindow = createSettingsWindow(with: settingsView)
        settingsWindow.makeKeyAndOrderFront(nil)
    }
    
    private func createSettingsWindow(with view: SettingsView) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.center()
        window.setFrameAutosaveName("Settings Window")
        window.contentView = NSHostingView(rootView: view)
        window.isReleasedWhenClosed = false
        return window
    }
}
