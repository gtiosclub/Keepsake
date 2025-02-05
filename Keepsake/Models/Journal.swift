//
//  Journal.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation

struct Journal {
    var name: String
    var createdDate: String
    var entries: [JournalEntry]
    var category: String
    var isSaved: Bool
    var isShared: Bool
    var template: Template
}
