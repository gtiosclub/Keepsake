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
    let openAIAPIKeyString: String = ""
    var openAIAPIKey = ChatGPTAPI(apiKey: "")
    @Published var uiImage: UIImage? = nil
    @Published var isLoading = false
    let gptModel = ChatGPTModel(rawValue: "gpt-4o")
    
    func generateCaptionForImage(image: UIImage) async -> String? {
        let errorResponse: String = "Unable to generate image caption."
        
        // Convert image to base64 string
        let base64Image = imageToBase64(image: image)
        guard let base64Image = base64Image else {
            print("Unable to convert image to base64 string.")
            return errorResponse
        }
        // Create prompt
        let systemPrompt: String = "You are creating captions for user uploaded images in a journaling app. Respond with only a short (one line maximum) caption for this image. If you do not understand the image, respond with a generic caption, such as \'My Image\'. Do not hallucinate an image or caption."
        
        // Create API call
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system","content": systemPrompt],
                ["role": "user", "content": [
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64Image)"
                        ]
                    ]
                ]]
            ],
            "max_tokens": 50
        ]
        let url = URL(string: "https://api.openai.com/v1/chat/completions")
        guard let url = url else {
            print("Unable to create URL")
            return errorResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIAPIKeyString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Failed to encode request body: \(error.localizedDescription)")
            return errorResponse
        }
        
        // Query
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response from server")
                print(response)
                return errorResponse
            }
            
            let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            if let caption = decodedResponse.choices.first?.message.content {
                let trimmedCaption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
                print(trimmedCaption)
                return trimmedCaption
            } else {
                return errorResponse
            }
        } catch {
            print("API Request Error: \(error.localizedDescription)")
            return errorResponse
        }
    }
    
    func imageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }
    

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
  
  
    
    func getSmartPrompts(journal: Journal) async -> String? {
        // Get all entries in journal
        let journalEntries: [JournalEntry] = journal.entries
        var prompt: String = ""
        if journalEntries.count == 0 {
            print("No journal entries")
            prompt = "A user of a journal app wants to write a new journal entry. Suggest a one-line prompt that the user can answer when writing their new entry. Respond with only the prompt, no additional text or quotation marks."
        } else {
            
            // Convert entries to JSON
            var journalEntriesJson: [String] = []
            for entry in journalEntries {
                journalEntriesJson.append(convertJournalEntryToJson(entry: entry))
            }
            
            prompt = """
                I have a collection of type JournalEntry. Each JournalEntry is a JSON object with the following fields:
                {
                    date: <String>
                    title: <String>
                    text: <String>
                }
                A user wants to write a new JournalEntry. Based on these JournalEntry instances, suggest a one-line prompt that the user can answer when writing their new JournalEntry text. Give higher priority to more recent JournalEntry instances. If there are no JournalEntry instances, give a generic journaling prompt. Respond with only the one-line prompt.
                Here is the collection of JournalEntry:
                
                """
            for json in journalEntriesJson {
                prompt.append("\n\(json)")
            }
        }
        
        // Query ChatGPT
        do {
            let response: String = try await openAIAPIKey.sendMessage(
                text: prompt,
                model: gptModel!)
            
            print(response)
            
            return response
        } catch {
            print("Send OpenAI Query Error: \(error.localizedDescription)")
            return "Unable to generate journal prompt."
        }
    }
    
    // function for continuing topics based on where you left off in the text
        func topicCompletion (journalEntry: JournalEntry) async -> String? {
            let journalEntryJSON: String = (convertJournalEntryToJson(entry: journalEntry))
            
            let prompt = """
               
               I have a journal entry of type JounralEntry that is now a JSON file with multiple variables:
               
               {
                   date: <String>
                   title: <String>
                   text: <String>
               }
               
               I want you to look at where the text ends and return a question that helps the writer think about something else to write past that point based around the same idea. It should be something like "Would you like to talk about...?" relating to an extension of the previous topic. This should not be too long, maybe around 1 line total. 
               
               This is the JournalEntry: 
               
               \(journalEntryJSON)
               
               """
            
            do {
                let response = try await openAIAPIKey.sendMessage(text: prompt, model: gptModel!)
                return response
                
            } catch {
                return "Error: \(error.localizedDescription)"
            }
        }
    
    func convertJournalEntryToJson(entry: JournalEntry) -> String {
        guard let jsonData = try? JSONEncoder().encode(entry) else {
            print ("Error converting JournalEntry \(entry) to JSON")
            // TODO: should we throw an error or return something in case of error?
            return ""
        }
        return String(data: jsonData, encoding: .utf8)!
    }
    
    @Published var summary = ""
    func summarize(entry: JournalEntry) async {
        let prompt = "Summarize the entry: Title: \(entry.title) Text: \(entry.text)"
        
        do {
            let response = try await openAIAPIKey.sendMessage(
                text: prompt,
                model: .gpt_hyphen_4
            )
            
            self.summary = response
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    struct OpenAIResponse: Codable {
        struct Choice: Codable {
            struct Message: Codable {
                let content: String
            }
            let message: Message
        }
        let choices: [Choice]
    }
}
