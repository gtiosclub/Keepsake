//
//  Scrapbook.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation



class Scrapbook: Book, ObservableObject, Identifiable {
    var name: String
    var id: UUID
    var createdDate: String
    var category: String
    var isSaved: Bool
    var isShared: Bool
    var template: Template
    @Published var pages: [ScrapbookPage]
    var currentPage: Int
    
    //Full Constructor
    init(name: String, id: UUID, createdDate: String, category: String, isSaved: Bool, isShared: Bool, template: Template, pages: [ScrapbookPage], currentPage: Int) {
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

}

extension Scrapbook: CustomStringConvertible {
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "id": id.uuidString,
            "createdDate": createdDate,
            "category": category,
            "isSaved": isSaved,
            "isShared": isShared,
            "template": template.toDictionary(),
            "pages": pages.map { $0.toDictionary() },  // Changed to output an array of dictionaries.
            "currentPage": currentPage
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> Scrapbook? {
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

        let pages = pagesArray.compactMap { ScrapbookPage.fromDictionary($0) }
        
        return Scrapbook(name: name, id: id, createdDate: createdDate, category: category, isSaved: isSaved, isShared: isShared, template: template, pages: pages, currentPage: currentPage)
    }
    
    var description: String {
        return "Scrapbook(name: \(name), id: \(id), createdDate: \(createdDate), category: \(category), isSaved: \(isSaved), isShared: \(isShared), template: \(template), pages: \(pages), currentPage: \(currentPage))"
    }
}
