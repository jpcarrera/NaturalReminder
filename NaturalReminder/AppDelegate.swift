//
//  AppDelegate.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 02.10.2023.
//

import Foundation
import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    let notificationManager = NotificationManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()
    }

    private func setupNotifications() {
        notificationManager.startCheckingDates()
        requestNotificationPermission { isGranted in
            if isGranted {
                DispatchQueue.main.async {
                    NSApplication.shared.registerForRemoteNotifications()
                }
            } else {
                // Handle the case where permission is not granted
            }
        }
    }

    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, _ in
            completion(granted)
        }
    }
}
