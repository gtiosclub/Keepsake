//
//  ConversationEntry.swift
//  Keepsake
//
//  Created by Shlok Patel on 3/2/25.
//

import Foundation

struct ConversationEntry: Encodable {
    var date: String
    var title: String
    var conversationLog: [String]
}
