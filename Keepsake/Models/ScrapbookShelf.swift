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
