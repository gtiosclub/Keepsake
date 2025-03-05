//
//  JournalEntry.swift
//  Keepsake
//
//  Created by Alec Hance on 2/4/25.
//

import Foundation

struct JournalEntry: Encodable {
    var date: String
    var title: String
    var text: String
    var summary: String
}

extension JournalEntry {
    func toDictionary() -> [String: Any] {
        return [
            "date": date,
            "title": title,
            "text": text,
            "summary": summary
        ]
    }
}
