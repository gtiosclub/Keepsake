//
//  FirebaseViewModel.swift
//  Keepsake
//
//  Created by Alec Hance on 2/18/25.
//

import Foundation
import FirebaseFirestore

class FirebaseViewModel: ObservableObject {
    let db = Firestore.firestore()
    var onSetupCompleted: ((FirebaseViewModel) -> Void)?
    
    static let vm = FirebaseViewModel()
    func configure() {
        self.onSetupCompleted?(self)
    }
    
    func testRead() async -> Int {
        let docRef = db.collection("USERS").document("Test")
        
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let id = document.data()?["id"] as? Int else {
                    print("id is not an int")
                    return -1
                }
                print("completed")
                return id
            } else {
                print("document doesn't exist")
                return -1
            }
        } catch {
            print("message")
            return -1
        }
    }
    
    func getAPIKeys() async throws -> [String: String] {
        var apimap: [String: String] = [:]
        
        let getdocs = try await db.collection("API_KEYS").getDocuments()
        
        for doc in getdocs.documents {
            if let key = doc.data()["key"] as? String {
                apimap[doc.documentID] = key
            }
        }
        
        return apimap
    }
    
}
