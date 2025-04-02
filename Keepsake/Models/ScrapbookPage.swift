//
//  ScrapbookPage.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/30/25.
//

import Foundation

class ScrapbookPage: ObservableObject {
    var number: Int
    // Entries are entities in the scrapbook
    @Published var entries: [ScrapbookEntry]
    var entryCount: Int
    
    init(number: Int, entries: [ScrapbookEntry], entryCount: Int) {
        self.number = number
        self.entries = entries
        self.entryCount = entryCount
    }
}

extension ScrapbookPage: CustomStringConvertible {
    
    func toDictionary() -> [String: Any] {
        return [
            "number": number,
            "entries": entries.map { $0.toDictionary() },
            "entryCount": entryCount
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> ScrapbookPage? {
        guard let number = dict["number"] as? Int,
              let entriesArray = dict["entries"] as? [[String: Any]],
              let entryCount = dict["entryCount"] as? Int else {
            return nil
        }

        var entries = entriesArray.compactMap { ScrapbookEntry.fromDictionary($0) }

        return ScrapbookPage(number: number, entries: entries, entryCount: entryCount)
    }
    
    var description: String {
        return "ScrapbookPage(number: \(number), entries: \(entries), entryCount: \(entryCount))"
    }
}
