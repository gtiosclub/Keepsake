//
//  KeepsakeTests.swift
//  KeepsakeTests
//
//  Created by Rik Roy on 2/2/25.
//

import Testing
@testable import Keepsake

struct KeepsakeTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func getImages() async throws {
        var journalEntry = JournalEntry(date: "01/01/2025", title: "Test",  text: "Test")
        var aiViewModel: AIViewModel = AIViewModel()
        await print(try aiViewModel.getImages(entry: journalEntry)!)
    }

}
