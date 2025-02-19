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
    var entries: [JournalEntry]
    var category: String
    var isSaved: Bool
    var isShared: Bool
    var template: Template
    var pages: [JournalPage]
}
