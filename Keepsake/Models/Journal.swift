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

struct Journal: Book {
    var name: String
    var createdDate: String
    var category: String
    var isSaved: Bool
    var isShared: Bool
    var template: Template
    var pages: [JournalPage]
    
    init(name: String, createdDate: String, entries: [JournalEntry], category: String, isSaved: Bool, isShared: Bool, template: Template, pages: [JournalPage]) {
        self.name = name
        self.createdDate = createdDate
        self.category = category
        self.isSaved = isSaved
        self.isShared = isShared
        self.template = template
        self.pages = pages
    }
    
    init () {
        self.name = "Default Journal"
        self.createdDate = Date().description
        self.category = ""
        self.isSaved = false
        self.isShared = false
        self.template = Template()
        self.pages = []
    }
}
