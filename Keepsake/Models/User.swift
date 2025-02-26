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
    @Published var shelves: [Shelf]
    
    init(id: String, name: String, shelves: [Shelf]) {
        self.id = id
        self.name = name
        self.shelves = shelves
    }
    
    // Provide default values for id and name
    init(shelves: [Shelf] = []) {
        self.id = UUID().uuidString
        self.name = "Default User"
        self.shelves = shelves
    }
}
