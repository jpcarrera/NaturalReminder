//
//  SettingsData.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 08.10.2023.
//

import Foundation
import Combine

class SettingsData: ObservableObject {
    static let shared = SettingsData()

    @Published var removeNotificationWhenDismissed: Bool {
        didSet {
            UserDefaults.standard.set(removeNotificationWhenDismissed, forKey: "removeNotificationWhenDismissed")
        }
    }

    @Published var snoozeNotificationWhenDismissed: Int {
        didSet {
            UserDefaults.standard.set(snoozeNotificationWhenDismissed, forKey: "snoozeNotificationWhenDismissed")
        }
    }

    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        self.removeNotificationWhenDismissed = UserDefaults.standard.object(forKey: "removeNotificationWhenDismissed") as? Bool ?? true
        self.snoozeNotificationWhenDismissed = UserDefaults.standard.object(forKey: "snoozeNotificationWhenDismissed") as? Int ?? 5
        self.isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? false
    }
}

struct Global {
    static var settings: SettingsData = SettingsData.shared
}

