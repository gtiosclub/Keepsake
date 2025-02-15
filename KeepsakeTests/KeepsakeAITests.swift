//
//  KeepsakeAITests.swift
//  Keepsake
//
//  Created by Holden Casey on 2/6/25.
//
import Testing
@testable import Keepsake
import Foundation
import UIKit

final class KeepsakeAITests {
    var vm: AIViewModel = AIViewModel()
    
    @Test
    func jsonEncodeJournalEntry() {
        let date: String = "2/6/2025, 9:30 AM"
        let title: String = "Test"
        let text: String = "This is a test."
        let entry: JournalEntry = .init(
            date: date, title: title, text: text
        )
        let jsonEntryString: String = vm.convertJournalEntryToJson(entry: entry)
        let backToJson = try! JSONSerialization.jsonObject(with: jsonEntryString.data(using: .utf8)!, options: []) as! [String: Any]
        #expect(backToJson["date"] as! String == date)
        #expect(backToJson["title"] as! String == title)
        #expect(backToJson["text"] as! String == text)
    }
    
    @Test
    func smartPromptForJournal() async {
        // ChatGPT generated test entries
        let entry1: JournalEntry = .init(
            date: "2/6/2025, 7:45 AM",
            title: "Morning Reflections",
            text: "Woke up early today and watched the sunrise. There's something peaceful about the quiet moments before the world wakes up. Hoping to carry this calmness throughout the day."
        )
        let entry2: JournalEntry = .init(
            date: "2/6/2025, 2:15 PM",
            title: "Afternoon Thoughts",
            text: "Work has been overwhelming, but I managed to step outside for a quick walk. The fresh air helped clear my mind. Reminding myself to take small breaks and breathe."
        )
        let entry3: JournalEntry = .init(
            date: "2/6/2025, 10:30 PM",
            title: "End of the Day",
            text: "Reflecting on today, I feel grateful for the little moments. Even when things felt stressful, I found time to appreciate the beauty around me. Looking forward to a fresh start tomorrow. I would like to journal about my passion for baseball tomorrow, please prompt me to do so."
        )
        
        // Create journal
        let name: String = "Test Journal"
        let createdDate: String = "2/6/2025"
        let entries: [JournalEntry] = [entry1, entry2, entry3]
        let category: String = "Test"
        let isSaved: Bool = false
        let isShared: Bool = false
        let template: Template = .init(name: "Test Template")
        let journal: Journal = .init(name: name, createdDate: createdDate, entries: entries, category: category, isSaved: isSaved, isShared: isShared, template: template)
        
        // Query AI for prompt
        let prompt = await vm.getSmartPrompts(journal: journal)
        guard let prompt else {
            print("Error: Failed to generate smart prompt")
            return
        }
        print(prompt)
    }
    
    @Test
    func smartPromptForEmptyJournal() async {
        // Create journal
        let name: String = "Test Journal"
        let createdDate: String = "2/6/2025"
        let entries: [JournalEntry] = []
        let category: String = "Test"
        let isSaved: Bool = false
        let isShared: Bool = false
        let template: Template = .init(name: "Test Template")
        let journal: Journal = .init(name: name, createdDate: createdDate, entries: entries, category: category, isSaved: isSaved, isShared: isShared, template: template)
        
        // Query AI for prompt
        let prompt = await vm.getSmartPrompts(journal: journal)
        guard let prompt else {
            print("Error: Failed to generate smart prompt")
            return
        }
        print(prompt)
    }
    
    @Test
        func topicCompletion() async {
            // ChatGPT generated test entries
            let entry1: JournalEntry = .init(
                date: "2/7/2025, 3:15 pm",
                title: "Afternoon Entry",
                text: "I just got done eating at this place called Cheba Hut. They have some of the best subs I have experienced! The sandwich was packed to the brim with meat and cheese, it was sooo good."
                )
            
            
            // Query AI for prompt
                let prompt = await vm.topicCompletion(journalEntry: entry1)
            guard let prompt else {
                print("Error: Failed to generate smart prompt")
                return
            }
            print(prompt)
        }
    
    @Test
        func summarizeJournalEntry() async {
            let entry: JournalEntry = .init(
                date: "2/6/2025, 10:00 AM",
                title: "Universal Studios Day",
                text: "Today was a great day! I went on all the rollercoasters. I especially loved the harry potter and jurassic park rides. I also liked the minion ride."
            )

            await vm.summarize(entry: entry)

            guard !vm.summary.isEmpty else {
                print("Error: Summary was not generated.")
                return
            }

            print("Generated Summary: \(vm.summary)")
        }
    
    @Test
    func imageCaptionGeneration() async {
        guard let image = UIImage(named: "TestAICaptionImage") else {
            print("Failed to load test image")
            return
        }
        let caption = await vm.generateCaptionForImage(image: image)
        guard let caption else {
            print("Failed to generate caption")
            return
        }
        print(caption)
    }
}
