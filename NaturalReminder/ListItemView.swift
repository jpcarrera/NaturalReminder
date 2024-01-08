//
//  ListItemView.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 08.10.2023.
//

import Foundation
import SwiftUI
import Combine

struct CountdownLabel: View {
    let date: Date
    let isCrossedOut: Bool
    @State private var timeLeft: String = ""
    @StateObject private var timer = TimerHolder()
    
    var body: some View {
        Text(timeLeft)
            .strikethrough(isCrossedOut)
            .foregroundColor(getTextColor(isCrossedOut: isCrossedOut, targetDate: date))
            .font(.caption)
            .onAppear {
                updateTime()
            }
            .onReceive(Just(date)) { newValue in
                updateTime()
            }
            .onDisappear {
                timer.stopTimer()
            }
    }
    
    func updateTime() {
        timeLeft = formatTimeLeft(until: date)
        timer.startTimer(every: 60, targetDate: date) { newTimeLeft in
            self.timeLeft = newTimeLeft
        }
    }
    
    private func getTextColor(isCrossedOut: Bool, targetDate: Date) -> Color {
        if isCrossedOut {
            return .gray
        } else {
            return Date() > targetDate ? .red : .gray
        }
    }
}

struct ListItemView: View {
    @ObservedObject var item: ParsedListItem
    var removeItem: () -> Void
    var toggleCrossedOut: () -> Void
    @State private var isHovering = false
    var index: Int
    
    var body: some View {
        HStack {
            Text("\(index)")
                .foregroundColor(item.isCrossedOut ? .gray : nil)
            Text(item.text)
                .strikethrough(item.isCrossedOut)
                .foregroundColor(item.isCrossedOut ? .gray : nil)

            Spacer()
            
            if let date = item.date {
                CountdownLabel(date: date, isCrossedOut: item.isCrossedOut)
                    .onHover { hovering in
                        isHovering = hovering
                    }
                    .overlay(
                        HoverPopup(isVisible: isHovering, text: formatDateComponent(date))
                    )
            }

            ActionButton(text: "\u{2714}", color: item.isCrossedOut ? .gray : .green, action: toggleCrossedOut)
            ActionButton(text: "\u{2716}", color: .red, action: removeItem)
        }
    }
}

struct ActionButton: View {
    var text: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(color)
        }
    }
}

struct HoverPopup: View {
    let isVisible: Bool
    let text: String
    
    var body: some View {
        Text(text)
            .padding(4)
            .frame(width: 100)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(5)
            .font(.system(size: 10))
            .opacity(isVisible ? 1 : 0)  // Control visibility with opacity
    }
}
