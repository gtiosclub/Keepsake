//
//  ScrapbookEntry.swift
//  Keepsake
//
//  Created by Alec Hance on 2/5/25.
//

struct ScrapbookEntry: Identifiable {
    var id: String
    var date: String
    var entities: [EntityInfo]
}
