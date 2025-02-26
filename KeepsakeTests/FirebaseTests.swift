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

    
    
}
