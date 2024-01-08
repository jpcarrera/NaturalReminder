//
//  ParsedListItem.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 02.10.2023.
//

import Foundation
import Combine

class ParsedListItem: Identifiable, Hashable, ObservableObject {
    let id: String
    var index: Int?
    @Published var text: String
    var isCrossedOut: Bool
    var date: Date?
    
    init() {
        self.id = UUID().uuidString
        self.text = ""
        isCrossedOut = false
    }
    
    init(text: String, isCrossedOut: Bool=false) {
        self.id = UUID().uuidString
        self.text = text
        self.isCrossedOut = isCrossedOut
    }
    
    init(text: String, isCrossedOut: Bool=false, date: Date) {
        self.id = UUID().uuidString
        self.text = text
        self.date = date
        self.isCrossedOut = isCrossedOut
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ParsedListItem, rhs: ParsedListItem) -> Bool {
        return lhs.id == rhs.id
    }
}
