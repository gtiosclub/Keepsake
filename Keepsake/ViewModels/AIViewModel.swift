//
//  AIViewModel.swift
//  Keepsake
//
//  Created by Rik Roy on 2/5/25.
//

import Foundation
import ChatGPTSwift

class AIViewModel: ObservableObject {
    var openAIAPIKey = ChatGPTAPI(apiKey: "")
    
    let gptModel = ChatGPTModel(rawValue: "gpt-4o")
    
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
    
    func convertJournalEntryToJson(entry: JournalEntry) -> String {
        guard let jsonData = try? JSONEncoder().encode(entry) else {
            print ("Error converting JournalEntry \(entry) to JSON")
            // TODO: should we throw an error or return something in case of error?
            return ""
        }
        return String(data: jsonData, encoding: .utf8)!
    }
}
