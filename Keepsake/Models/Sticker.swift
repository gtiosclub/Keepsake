//
//  Sticker.swift
//  Keepsake
//
//  Created by Rik Roy on 4/9/25.
//

import Foundation

class Sticker: ObservableObject, Identifiable, Encodable {
    var id: UUID
    var url: String
    @Published var position: CGPoint
    @Published var size: CGFloat

    init(id: UUID = UUID(), url: String, position: CGPoint = .zero, size: CGFloat = 100) {
        self.id = id
        self.url = url
        self.position = position
        self.size = size
    }

    enum CodingKeys: String, CodingKey {
        case id, url, position, size
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(position, forKey: .position)
        try container.encode(size, forKey: .size)
    }
}
