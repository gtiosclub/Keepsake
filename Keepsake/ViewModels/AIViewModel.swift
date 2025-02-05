//
//  AIViewModel.swift
//  Keepsake
//
//  Created by Rik Roy on 2/5/25.
//

import Foundation
import ChatGPTSwift
import UIKit

class AIViewModel: ObservableObject {
    var openAIAPIKey = ChatGPTAPI(apiKey: "")
    
    func getImages(entry: JournalEntry) async throws -> String? {
        var examplePrompt = ""
        examplePrompt = entry.title + "\n" + entry.text
        do {
            let response = try await openAIAPIKey.generateDallE3Image(prompt: examplePrompt)
            return response.url
        } catch {
            print("Error received: \(error)")
            return nil
        }
    }
    
}
