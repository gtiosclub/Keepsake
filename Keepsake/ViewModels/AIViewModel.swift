//
//  AIViewModel.swift
//  Keepsake
//
//  Created by Rik Roy on 2/5/25.
//

import Foundation
import ChatGPTSwift

class AIViewModel: ObservableObject {
    var openAIAPIKey = ChatGPTAPI(apiKey: "<PUT API KEY HERE>")
    
    let gptModel = ChatGPTModel(rawValue: "gpt-4o")
    
    func getSmartPrompts(journal: Journal) async -> String? {
        // Get all entries in journal
        let journalEntries: [JournalEntry] = journal.entries
        if journalEntries.count == 0 {
            print("No journal entries")
            return "Write your first journal entry to get prompts!"
        }
        
        // Convert entries to JSON
        var journalEntriesJson: [String] = []
        for entry in journalEntries {
            journalEntriesJson.append(convertJournalEntryToJson(entry: entry))
        }
        
        // Create prompt to give ChatGPT
        var prompt: String = """
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
}
