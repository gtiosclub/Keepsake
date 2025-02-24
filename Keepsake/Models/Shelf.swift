//
//  Shelf.swift
//  Keepsake
//
//  Created by Alec Hance on 2/10/25.
//

import Foundation
import SwiftUI

class Shelf: ObservableObject {
    @Published var name: String
    @Published var books: [Journal]

    init(name: String, books: [Journal]) {
        self.name = name
        self.books = books
    }
}
