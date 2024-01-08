//
//  DateUtils.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 08.10.2023.
//

import Foundation

public func formatTimeLeft(until date: Date) -> String {
    let now = Date()
    let calendar = Calendar.current
    
    if now > date {
        return "Missed"
    }
    
    if calendar.isDate(Date(), inSameDayAs: date) {
        let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: date)
        
        if let hour = components.hour, let minute = components.minute, let second = components.second {
            if hour == 0 && minute == 0 && second < 60 {
                return "Now"
            }
        }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        if let formattedTimeLeft = formatter.string(from: calendar.dateComponents([.hour, .minute], from: now, to: date)) {
            return "In \(formattedTimeLeft)"
        }
    } else if calendar.isDateInTomorrow(date) {
        return "Tomorrow"
    }
    
    let totalDays = calendar.dateComponents([.day], from: now, to: date).day ?? 0
    return "In \(totalDays + 1) days"
}

func formatDateComponent(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy - HH:mm"
    return formatter.string(from: date)
}
