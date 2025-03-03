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
    var createdDate: String
    var category: String
    var isSaved: Bool
    var isShared: Bool
    var template: Template
    var pages: [JournalPage]
    var currentPage: Int
    
    init(name: String, createdDate: String, entries: [JournalEntry], category: String, isSaved: Bool, isShared: Bool, template: Template, pages: [JournalPage], currentPage: Int) {
        self.name = name
        self.createdDate = createdDate
        self.category = category
        self.isSaved = isSaved
        self.isShared = isShared
        self.template = template
        self.pages = pages
        self.currentPage = currentPage
    }
    
    init () {
        self.name = "Default Journal"
        self.createdDate = Date().description
        self.category = ""
        self.isSaved = false
        self.isShared = false
        self.template = Template()
        self.pages = []
        self.currentPage = 0
    }
}
