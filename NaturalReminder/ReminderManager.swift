//
//  ReminderManager.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 03.10.2023.
//

import Foundation

class ReminderManager: ObservableObject {
    static let shared = ReminderManager()
    let dateStorage = DateStorage(fileName: "dates")
    
    @Published var parsedListItems: [ParsedListItem] = []
    
    init() {
        self.parsedListItems = self.allItems()
    }

    func add(_ item: ParsedListItem) {
        parsedListItems.append(item)
        dateStorage.save(parsedListItems)
    }

    func add(_ items: [ParsedListItem]) {
        parsedListItems += items
        dateStorage.save(parsedListItems)
    }

    func find(_ id: String) -> ParsedListItem? {
        parsedListItems.first { $0.id == id }
    }

    func remove(_ id: String) {
        parsedListItems.removeAll { $0.id == id }
        dateStorage.save(parsedListItems)
    }
    
    func removeIndex(_ index: Int) {
        parsedListItems.removeAll { $0.index == index }
    }
    
    func allItems() -> [ParsedListItem] {
        parsedListItems
    }
    
    func loadAllItems() {
        parsedListItems = dateStorage.retrieve()
    }
    
    func crossOutItem(_ index: Int)  {
        parsedListItems[index].isCrossedOut.toggle()
        dateStorage.save(parsedListItems)
    }
    
    func crossOutItemByIndex(_ index: Int) {
        if let index = parsedListItems.firstIndex(where: { $0.index == index }) {
            parsedListItems[index].isCrossedOut.toggle()
            dateStorage.save(parsedListItems)
            self.objectWillChange.send()
        }
    }
    
    func crossOutItemById(_ id: String) {
        if let index = parsedListItems.firstIndex(where: { $0.id == id }) {
            parsedListItems[index].isCrossedOut.toggle()
            dateStorage.save(parsedListItems)
            self.objectWillChange.send()
        }
    }
    
    func changeDateById(_ id: String,_ date: Date) {
        if let index = parsedListItems.firstIndex(where: { $0.id == id }) {
            parsedListItems[index].date = date
            dateStorage.save(parsedListItems)
            self.objectWillChange.send()
        }
    }
    
}
