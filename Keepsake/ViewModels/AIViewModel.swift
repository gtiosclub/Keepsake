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
    @Published var uiImage: UIImage? = nil
    @Published var isLoading = false
    
    func generateImage(for entry: JournalEntry) async {
        isLoading = true
        defer{ isLoading = false }
        
        do {
            let examplePrompt = entry.title + "\n" + entry.text
            let response = try await openAIAPIKey.generateDallE3Image(prompt: examplePrompt)
            if let urlString = response.url {
                self.uiImage = fetchUIImage(from: urlString)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    func fetchUIImage(from urlString: String) -> UIImage? {
        guard let url = URL(string: urlString), let data = try? Data(contentsOf: url) else {
           print("Failed to load data from URL!")
           return nil
       }
       return UIImage(data: data)
    }
    
}
