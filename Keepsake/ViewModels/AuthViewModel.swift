//
//  AuthViewModel.swift
//  Keepsake
//
//  Created by Nithya Ravula on 3/11/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}

@MainActor

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, name: fullname, username: email, journalShelves: [], scrapbookShelves: [], savedTemplates: [], friends: [])
            let userData: [String: Any] = [
                "uid": user.id,
                "name": user.name,
                "username": user.username,
                "journals": [],
                "scrapbooks": [],
                "templates": [],
                "friends": []
                
            ]
            try await Firestore.firestore().collection("USERS").document(user.id).setData(userData)
            await fetchUser()
            
        } catch {
            print("error :( \(error.localizedDescription)")
        }
    }
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            
        }
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        guard let snapshot = try? await Firestore.firestore().collection("USERS").document(uid).getDocument() else { return }
        if snapshot.exists {
            // Manually extract data from the snapshot
            if let uid = snapshot.get("uid") as? String,
               let name = snapshot.get("name") as? String,
               let username = snapshot.get("username") as? String,
               let journals = snapshot.get("journals") as? [JournalShelf],
               let scrapbooks = snapshot.get("scrapbooks") as? [ScrapbookShelf],
               let templates = snapshot.get("templates") as? [Template],
               let friends = snapshot.get("friends") as? [String] {
                
                let user = User(id: uid, name: name, username: username, journalShelves: [], scrapbookShelves: [], savedTemplates: [], friends: friends)
                
                // Assign the user object to currentUser
                self.currentUser = user
                
            }
        }
    }
}

