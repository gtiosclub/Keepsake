//
//  User.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation

class User: Identifiable, ObservableObject {
    var id: String
    var name: String
    @Published var journals: [Journal]
    @Published var scrapbooks: [Scrapbook]
    
    init(id: String, name: String, journals: [Journal], scrapbooks: [Scrapbook]) {
        self.id = id
        self.name = name
        self.journals = journals
        self.scrapbooks = scrapbooks
    }
}
