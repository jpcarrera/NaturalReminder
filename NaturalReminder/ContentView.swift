//
//  ContentView.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 01.10.2023.
//

import Cocoa
import SwiftUI
import SwiftyChrono
import Combine
import AppKit

struct ContentView: View {
    let chrono = Chrono()
    let appDelegate: AppDelegate
    @State private var inputText: String = ""
    @ObservedObject var reminderManager = ReminderManager.shared
    @FocusState private var isTextFieldFocused: Bool
    @State private var listUpdateTrigger: Bool = false
    @FocusState private var isFocused: Bool
    @ObservedObject var settings = SettingsData.shared

    var sortedItems: [ParsedListItem] {
        reminderManager.parsedListItems.sorted(by: itemSorter)
    }

    var body: some View {
        VStack {
            if reminderManager.parsedListItems.isEmpty {
                VStack {
                    Spacer()
                    Image(Global.settings.isDarkMode ? "reminderDarkGray" : "reminderLightGray")
                        .resizable()
                        .scaledToFit()
                        .padding(.all, 40)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                listScrollView
            }
            Spacer()
            Divider()
            bottomTextField
        }
        .padding()
        .preferredColorScheme(Global.settings.isDarkMode ? .dark : .light)
        .task {
            isTextFieldFocused = true
            loadData()
        }
    }
    
    private var bottomTextField: some View {
        BottomTextField(inputText: $inputText, onCommit: processInputText)
            .focused($isTextFieldFocused)
    }
    
    private var listScrollView: some View {
        ScrollView {
            ForEach(Array(sortedItems.enumerated()), id: \.element) { index, item in
                listItemView(for: item, index: index + 1)
            }
            .id(listUpdateTrigger)
        }
    }

    private func listItemView(for item: ParsedListItem, index: Int) -> some View {
        let itemToDisplay = reminderManager.parsedListItems[reminderManager.parsedListItems.firstIndex(of: item)!]
        itemToDisplay.index = index

        return ListItemView(
            item: itemToDisplay,
            removeItem: { removeListItem(item) },
            toggleCrossedOut: { toggleCrossedOut(item) },
            index: index
        )
        .conditionalDivider(!item.isCrossedOut, Color.gray)
    }

    private func itemSorter(_ item1: ParsedListItem, _ item2: ParsedListItem) -> Bool {
        if item1.isCrossedOut != item2.isCrossedOut {
            return item1.isCrossedOut ? false : true
        } else {
            if let date1 = item1.date, let date2 = item2.date {
                return date1 < date2
            } else {
                return false
            }
        }
    }

    private func toggleCrossedOut(_ item: ParsedListItem) {
        if let index = reminderManager.parsedListItems.firstIndex(of: item) {
            reminderManager.crossOutItem(index)
            appDelegate.notificationManager.removeNotification(for: item)
            listUpdateTrigger.toggle()
        }
    }

    private func processInputText() {
        if let result = extractComponents(from: inputText) {
            processParsedInput(result)
        } else {
            processChronoInput()
        }
        resetInput()
    }

    private func processParsedInput(_ result: (number: Int, letter: String)) {
        for item in reminderManager.parsedListItems {
            if result.number == item.index {
                handleItemByLetter(result.letter, index: result.number)
            }
        }
    }

    private func handleItemByLetter(_ letter: String, index: Int) {
        switch letter {
        case "d":
            reminderManager.crossOutItemByIndex(index)
        case "r":
            reminderManager.removeIndex(index)
        default:
            break
        }
    }

    private func processChronoInput() {
        let chronoParsed = chrono.parse(text: inputText)
        if !chronoParsed.isEmpty {
            processDateInput(chronoParsed)
        } else {
            let newItem = ParsedListItem(text: inputText)
            reminderManager.add(newItem)
        }
    }

    private func processDateInput(_ chronoParsed: [ParsedResult]) {
        guard let chronoText = chronoParsed.first?.text,
              let firstParsedDate = chronoParsed.compactMap({ $0.start.date }).first else {
            return
        }

        var text = inputText.replacingOccurrences(of: chronoText, with: "").replacingOccurrences(of: "  ", with: " ")
        if text.isEmpty {
            text = chronoText
        }

        let newItem = ParsedListItem(text: text, date: firstParsedDate)
        reminderManager.add(newItem)
        appDelegate.notificationManager.add(newItem)
    }

    private func resetInput() {
        DispatchQueue.main.async {
            self.inputText = ""
        }
        isTextFieldFocused = true
    }

    
    func extractComponents(from str: String) -> (number: Int, letter: String)? {
        let pattern = "^([0-9]+)([a-zA-Z])$"

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(location: 0, length: str.utf16.count)
        if let match = regex.firstMatch(in: str, options: [], range: range) {
            let numberRange = match.range(at: 1)
            let letterRange = match.range(at: 2)

            if let numRange = Range(numberRange, in: str),
               let letRange = Range(letterRange, in: str) {
                if let number = Int(str[numRange]) {
                    let letter = String(str[letRange])
                    return (number, letter)
                }
            }
        }

        return nil
    }


    private func removeListItem(_ item: ParsedListItem) {
        reminderManager.remove(item.id)
        appDelegate.notificationManager.removeNotification(for: item)
    }

    private func loadData() {
        isTextFieldFocused = true
        reminderManager.loadAllItems()
        appDelegate.notificationManager.loadAllItems()
    }
}

struct ConditionalDivider: ViewModifier {
    let condition: Bool
    let color: Color
    
    func body(content: Content) -> some View {
        VStack {
            content
            if condition {
                Divider().background(color)
            }
        }
    }
}

extension View {
    func conditionalDivider(_ condition: Bool, _ color: Color) -> some View {
        self.modifier(ConditionalDivider(condition: condition, color: color))
    }
}
