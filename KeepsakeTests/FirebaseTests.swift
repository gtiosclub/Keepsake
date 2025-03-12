//
//  FirebaseTests.swift
//  Keepsake
//
//  Created by Connor on 2/26/25.
//

import XCTest
import Firebase
@testable import Keepsake


final class ViewModelUnitTests: XCTestCase {
    
    var vm: FirebaseViewModel!
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vm = FirebaseViewModel()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRead() async {
        let id = await vm.testRead()
        
        XCTAssertNotEqual(id, -1, "Failed to retrieve a valid ID from Firebase.")
        XCTAssertEqual(id, 111111, "Retrieved Correct ID from Firebase.")
    }
    
    func testAddJournalToFirebase() async {
        let test_journal = Journal(name: "Connor Test Journal", id: UUID(), createdDate: "2/2/25", category: "entry2", isSaved: true, isShared: true, template: Template(coverColor: .red, pageColor: .white, titleColor: .black), pages: [JournalPage(number: 1, entries: [], realEntryCount: 0), JournalPage(number: 2, entries: [], realEntryCount: 0), JournalPage(number: 3, entries: [], realEntryCount: 0), JournalPage(number: 4, entries: [], realEntryCount: 1), JournalPage(number: 5, entries: [], realEntryCount: 2)], currentPage: 2)
        
        let result = await vm.addJournal(journal: test_journal)
        XCTAssertTrue(result)
    }
    
    func testAddJournalShelvesToFirebase() async {
        let test_shelves = JournalShelf(name: "Shelf 2", id: UUID(), journals: [
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .red, pageColor: .black, titleColor: .white, texture: .flower1), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ])
        let result = await vm.addJournalShelf(journalShelf: test_shelves)
        XCTAssertTrue(result)
    }
    
    func testPrintShelf() {
        let id = UUID(uuidString: "E0692591-C013-4CE2-AA3D-8ADF2376780E") ?? UUID()
        let test_shelves = JournalShelf(name: "Shelf 2", id: id, journals: [
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .red, pageColor: .black, titleColor: .white, texture: .flower1), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(name: "Template 3", coverColor: .blue, pageColor: .black, titleColor: .white, texture: .snoopy), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
            Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(name: "Template 4", coverColor: .brown, pageColor: .white, titleColor: .black, texture: .flower3), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0)
        ])
        XCTAssertNotNil(test_shelves)
        print("Test Shelves:",  test_shelves)
    }
    
    func testGetJournalShelfFromFirebase() async {
        let journalShelf = await vm.getJournalShelfFromFirebase(id: "55717CB2-6296-408E-8F98-CCDE6163BF4D")
        XCTAssertNotNil(journalShelf)
        XCTAssertEqual(journalShelf?.name, "Shelf 2")
        XCTAssertEqual(journalShelf?.id.uuidString, "55717CB2-6296-408E-8F98-CCDE6163BF4D")
        XCTAssertEqual(journalShelf?.journals[0].id.uuidString, "2EC17C57-C2FE-4FFF-8462-E9B0CB127088")
        XCTAssertEqual(journalShelf?.journals[1].id.uuidString, "F9F95B97-8949-46A6-9593-3648148F52B6")
        XCTAssertEqual(journalShelf?.journals[2].id.uuidString, "7440FDCF-D488-47A5-95D6-7FC236A883DF")
        print("Journal Shelf: \(String(describing: journalShelf))")
    }

    
    
}
