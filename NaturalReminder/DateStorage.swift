//
//  DateStorage.swift
//  NaturalReminder
//
//  Created by Juan Carrera on 02.10.2023.
//

import Foundation

class DateStorage {
    private let fileURL: URL
    private let dateFormatter: DateFormatter
    
    init(fileName: String) {
        self.fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(fileName).csv") ?? URL(fileURLWithPath: "")
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func save(_ items: [ParsedListItem]) {
        let csvString = items.map { itemToCSVRow($0) }.joined(separator: "\n")
        let header = "id,text,date,isCrossedOut\n"
        let fullCSVString = header + csvString
        do {
            try fullCSVString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving ParsedListItems to file: \(error)")
        }
    }
    
    func retrieve() -> [ParsedListItem] {
        do {
            let csvString = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = csvString.components(separatedBy: "\n").dropFirst()
            return rows.compactMap { csvRowToItem($0) }
        } catch {
            print("Error retrieving ParsedListItems from file: \(error)")
            return []
        }
    }
    
    private func itemToCSVRow(_ item: ParsedListItem) -> String {
        let id = item.id
        let text = item.text
        let date = item.date.map { dateFormatter.string(from: $0) } ?? ""
        let isCrossedOut = item.isCrossedOut
        return "\(id),\(text),\(date),\(isCrossedOut)"
    }
    
    private func csvRowToItem(_ row: String) -> ParsedListItem? {
        let columns = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard columns.count >= 4, let isCrossedOut = Bool(columns[3]) else { return nil }
        
        if columns[2].isEmpty {
            return ParsedListItem(text: columns[1], isCrossedOut: isCrossedOut)
        } else if let date = dateFormatter.date(from: columns[2]) {
            return ParsedListItem(text: columns[1], isCrossedOut: isCrossedOut, date: date)
        }
        return nil
    }
}
