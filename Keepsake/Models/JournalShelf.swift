//
//  Shelf.swift
//  Keepsake
//
//  Created by Alec Hance on 2/10/25.
//

import Foundation

class JournalShelf {
    var name: String
    var journals: [Journal]
    
    init(name: String, journals: [Journal]) {
        self.name = name
        self.journals = journals
    }
}
