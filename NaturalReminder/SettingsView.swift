//
//  SettingsView.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 08.10.2023.
//

import Foundation
import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var settings = SettingsData.shared
    @State private var snoozeTime = ""

    var body: some View {
        VStack(spacing: 20) {
            notificationSettings
            themeSettings
        }
        .padding()
        .preferredColorScheme(Global.settings.isDarkMode ? .dark : .light)
    }
    
    private var notificationSettings: some View {
        GroupBox(label: Text("Dismissed notifications").font(.headline)) {
            VStack(alignment: .leading, spacing: 20) {
                toggleSetting(
                    title: "Ignore",
                    binding: Binding(
                        get: { Global.settings.removeNotificationWhenDismissed },
                        set: { Global.settings.removeNotificationWhenDismissed = $0 }
                    )
                )
                snoozeSetting(isDisabled: Global.settings.removeNotificationWhenDismissed)
            }
            .padding()
        }
    }
    
    private var themeSettings: some View {
        GroupBox(label: Text("Theme").font(.headline)) {
            VStack(alignment: .leading, spacing: 20) {
                toggleSetting(
                    title: "Dark mode",
                    binding: Binding(
                        get: { Global.settings.isDarkMode },
                        set: { Global.settings.isDarkMode = $0 }
                    )
                )
            }
            .padding()
        }
    }
    
    private func toggleSetting(title: String, binding: Binding<Bool>) -> some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: binding)
                .labelsHidden()
        }
    }
    
    private func snoozeSetting(isDisabled: Bool) -> some View {
        HStack {
            Text("Snooze (minutes)")
            Spacer()
            TextField("5", text: Binding(
                get: { String(Global.settings.snoozeNotificationWhenDismissed) },
                set: { if let intValue = Int($0) { Global.settings.snoozeNotificationWhenDismissed = intValue } }
            ))
            .frame(width: 50)
            .multilineTextAlignment(.trailing)
            .disabled(isDisabled)
            .onReceive(Just(snoozeTime)) { validateSnoozeTime($0) }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }
    
    private func validateSnoozeTime(_ newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        if filtered != newValue {
            self.snoozeTime = filtered
        }
        if snoozeTime.count > 3 {
            snoozeTime = String(snoozeTime.prefix(3))
        }
    }
}

