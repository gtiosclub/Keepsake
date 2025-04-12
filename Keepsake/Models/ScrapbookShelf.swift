//
//  ScrapbookShelf.swift
//  Keepsake
//
//  Created by Alec Hance on 2/28/25.
//

import Foundation

class ScrapbookShelf: ObservableObject {
    var id: UUID
    var name: String
    @Published var scrapbooks: [Scrapbook]
    
    init(name: String, id: UUID, scrapbooks: [Scrapbook]) {
        self.name = name
        self.id = id
        self.scrapbooks = scrapbooks
    }
    
    init(name: String, scrapbooks: [Scrapbook]) {
        self.name = name
        self.id = UUID()
        self.scrapbooks = scrapbooks
    }
    
}

extension ScrapbookShelf: CustomStringConvertible {
    func toDictionary() -> [String: Any] {
        var scrapbookIDs: [String] = []
        for scrapbook in scrapbooks {
            scrapbookIDs.append(scrapbook.id.uuidString)
        }
        return [
            "name": name,
            "id": id.uuidString,
            "scrapbooks": scrapbookIDs,
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> ScrapbookShelf? {
        guard let name = dict["name"] as? String,
              let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let scrapbookDicts = dict["scrapbooks"] as? [[String: Any]] else {
            return nil
        }
        
        let scrapbooks = scrapbookDicts.compactMap { Scrapbook.fromDictionary($0) }
        return ScrapbookShelf(name: name, id: id, scrapbooks: scrapbooks)
    }
    
    var description: String {
        return "ScrapbookShelf(name: \(name), id: \(id), journals: \(scrapbooks))"
    }
}
