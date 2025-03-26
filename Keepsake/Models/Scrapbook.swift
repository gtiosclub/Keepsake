//
//  Scrapbook.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation

struct Scrapbook: Book {
    var name: String
    var createdDate: String
    var entries: [ScrapbookEntry]
    var category: String
    var isSaved: Bool
    var isShared: Bool
    var template: Template // template is not abiding to decodable
}
