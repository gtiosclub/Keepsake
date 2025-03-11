//
//  Journal.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation

protocol Book {
    var template: Template { get set }
    var name: String { get }
    var createdDate: String { get }
}

class Journal: Book, ObservableObject {
    var name: String
    var id: UUID
    var createdDate: String
    var category: String
    var isSaved: Bool
    var isShared: Bool
    var template: Template
    var pages: [JournalPage]
    var currentPage: Int
    
    //Full Constructor
    init(name: String, id: UUID, createdDate: String, category: String, isSaved: Bool, isShared: Bool, template: Template, pages: [JournalPage], currentPage: Int) {
        self.name = name
        self.id = id
        self.createdDate = createdDate
        self.category = category
        self.isSaved = isSaved
        self.isShared = isShared
        self.template = template
        self.pages = pages
        self.currentPage = currentPage
    }
    
    convenience init(name: String, id: UUID, createdDate: String, entries: [JournalEntry], category: String, isSaved: Bool, isShared: Bool, template: Template, pages: [JournalPage], currentPage: Int) {
        self.init(name: name, id: id, createdDate: createdDate, category: category, isSaved: isSaved, isShared: isShared, template: template, pages: pages, currentPage: currentPage)
    }
    
    convenience init(name: String, createdDate: String, entries: [JournalEntry], category: String, isSaved: Bool, isShared: Bool, template: Template, pages: [JournalPage], currentPage: Int) {
        self.init(name: name, id: UUID(), createdDate: createdDate, category: category, isSaved: isSaved, isShared: isShared, template: template, pages: pages, currentPage: currentPage)
    }
    
    convenience init () {
        self.init(name: "Default Journal", id: UUID(), createdDate: Date().description, category: "", isSaved: false, isShared: false, template: Template(), pages: [], currentPage: 0)
    }
}

extension Journal: CustomStringConvertible {
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "id": id.uuidString,
            "createdDate": createdDate,
            "category": category,
            "isSaved": isSaved,
            "isShared": isShared,
            "template": template.toDictionary(),
            "pages": pages.map { $0.toDictionary() },
            "currentPage": currentPage
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Journal? {
        guard let name = dict["name"] as? String,
              let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let createdDate = dict["createdDate"] as? String,
              let category = dict["category"] as? String,
              let isSaved = dict["isSaved"] as? Bool,
              let isShared = dict["isShared"] as? Bool,
              let templateDict = dict["template"] as? [String: Any],
              let template = Template.fromDictionary(templateDict),
              let pagesArray = dict["pages"] as? [[String: Any]],
              let currentPage = dict["currentPage"] as? Int else {
            return nil
        }

        let pages = pagesArray.compactMap { JournalPage.fromDictionary($0) }
        
        return Journal(name: name, id: id, createdDate: createdDate, category: category, isSaved: isSaved, isShared: isShared, template: template, pages: pages, currentPage: currentPage)
    }
    
    var description: String {
        return "Journal(name: \(name), id: \(id), createdDate: \(createdDate), category: \(category), isSaved: \(isSaved), isShared: \(isShared), template: \(template), pages: \(pages), currentPage: \(currentPage))"
    }
}
