//
//  Shelf.swift
//  Keepsake
//
//  Created by Alec Hance on 2/10/25.
//

import Foundation

class JournalShelf {
    var name: String
    var id: UUID
    @Published var journals: [Journal]
    
    init(name: String, id: UUID, journals: [Journal]) {
        self.name = name
        self.id = id
        self.journals = journals
    }
    
    init(name: String, journals: [Journal]) {
        self.name = name
        self.id = UUID()
        self.journals = journals
    }
}

extension JournalShelf: CustomStringConvertible {
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "id": id.uuidString,
            "journals": journals.map { $0.toDictionary() },
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> JournalShelf? {
        guard let name = dict["name"] as? String,
              let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let journalDicts = dict["journals"] as? [[String: Any]] else {
            return nil
        }
        
        let journals = journalDicts.compactMap { Journal.fromDictionary($0) }
        return JournalShelf(name: name, id: id, journals: journals)
    }
    
    var description: String {
        return "JournalShelf(name: \(name), id: \(id), journals: \(journals))"
    }
}
