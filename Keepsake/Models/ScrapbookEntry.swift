//
//  ScrapbookEntry.swift
//  Keepsake
//
//  Created by Alec Hance on 2/5/25.
//

struct ScrapbookEntry: Identifiable, Codable {
    var id: String
    var date: String
    var entities: [EntityInfo]
}
