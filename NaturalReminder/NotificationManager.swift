//
//  NotificationManager.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 02.10.2023.
//

import Foundation
import Cocoa
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private var parsedListItems: [ParsedListItem] = []
    @ObservedObject var reminderManager = ReminderManager.shared
    
    func startCheckingDates() {
        setupNotificationCategories()
        requestNotificationPermission {
            self.scheduleNotifications()
        }
    }
    
    private func setupNotificationCategories() {
        let actions = createNotificationActions()
        let category = UNNotificationCategory(identifier: "reminderCategory", actions: actions, intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
        center.delegate = self
    }

    private func createNotificationActions() -> [UNNotificationAction] {
        let snoozeMapping: [String: Int] = [
            "5 min": 5,
            "10 min": 10,
            "15 min": 15,
            "30 min": 30,
            "1 hour": 60,
            "2 hours": 120,
            "4 hours": 240
        ]

        let doneAction = UNNotificationAction(identifier: "done", title: "Done", options: [.destructive])
        let sortedKeys = snoozeMapping.keys.sorted {
            let type1 = $0.contains("hour") ? 1 : 0
            let type2 = $1.contains("hour") ? 1 : 0
            return (type1, snoozeMapping[$0]!) < (type2, snoozeMapping[$1]!)
        }
        let snoozeActions = sortedKeys.map { title in
            UNNotificationAction(identifier: "snooze\(title)".filter { $0 != " " }, title: "Snooze \(title)", options: [])
        }

        return [doneAction] + snoozeActions
    }

    func loadAllItems() {
        parsedListItems = ReminderManager.shared.allItems()
        scheduleNotifications()
    }
    
    func add(_ item: ParsedListItem) {
        parsedListItems.append(item)
        scheduleNotification(for: item)
    }
    
    func add(_ items: [ParsedListItem]) {
        parsedListItems += items
        scheduleNotifications()
    }
    
    func removeNotification(for item: ParsedListItem) {
        center.removePendingNotificationRequests(withIdentifiers: ["naturalreminder-\(item.id)"])
    }

    private func requestNotificationPermission(completion: @escaping () -> Void) {
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                completion()
            }
        }
    }

    private func scheduleNotification(for item: ParsedListItem) {
        guard let date = item.date, !item.isCrossedOut, date > Date() else { return }
        
        let content = notificationContent(for: item)
        let trigger = notificationTrigger(for: date)
        
        let request = UNNotificationRequest(
            identifier: "naturalreminder-\(item.id)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    private func scheduleNotifications() {
        center.removeAllPendingNotificationRequests()
        parsedListItems.forEach { scheduleNotification(for: $0) }
    }

    private func notificationContent(for item: ParsedListItem) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = item.text
        content.body = "now"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "reminderCategory"
        return content
    }
    
    private func notificationTrigger(for date: Date) -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let actionIdentifier = response.actionIdentifier
        let notificationIdentifier = response.notification.request.identifier.replacingOccurrences(of: "naturalreminder-", with: "")
        
        switch actionIdentifier {
        case "done":
            handleDoneAction(notificationIdentifier)
        case "snooze5min", "snooze10min", "snooze15min", "snooze30min", "snooze1hour", "snooze2hours", "snooze4hours":
            handleSnoozeAction(notificationIdentifier, actionIdentifier: actionIdentifier)
        default:
            handleDefaultAction(notificationIdentifier)
        }

        completionHandler()
    }

    private func handleDoneAction(_ identifier: String) {
        reminderManager.crossOutItemById(identifier)
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    private func handleSnoozeAction(_ identifier: String, actionIdentifier: String) {
        let snoozeMapping = [
            "snooze5min": 5 * 60,
            "snooze10min": 10 * 60,
            "snooze15min": 15 * 60,
            "snooze30min": 30 * 60,
            "snooze1hour": 60 * 60,
            "snooze2hours": 120 * 60,
            "snooze4hours": 240 * 60
        ]
        
        guard let snoozeTime = snoozeMapping[actionIdentifier] else { return }

        let newDate = Date().addingTimeInterval(TimeInterval(snoozeTime))
        reminderManager.changeDateById(identifier, newDate)
        
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
        
        if let foundReminder = reminderManager.find(identifier) {
            scheduleNotification(for: foundReminder)
        }
    }

    private func handleDefaultAction(_ identifier: String) {
        if Global.settings.removeNotificationWhenDismissed {
            center.removeDeliveredNotifications(withIdentifiers: [identifier])
        }
        else {
            let newDate = Date().addingTimeInterval(TimeInterval(Global.settings.snoozeNotificationWhenDismissed)*60)
            reminderManager.changeDateById(identifier, newDate)
            
            center.removeDeliveredNotifications(withIdentifiers: [identifier])
            
            if let foundReminder = reminderManager.find(identifier) {
                scheduleNotification(for: foundReminder)
            }
        }
    }

}
