//
//  EntityInfo.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/10/25.
//

struct EntityInfo: Codable {
    var id: String
    var text: String?
    var imageUrl: String?
    var position: [Int]
    var angle: Float
    var scale: Float
}
