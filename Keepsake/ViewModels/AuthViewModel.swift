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
            let user = User(id: result.user.uid, name: email, journalShelves: [], scrapbookShelves: [])
            let userData: [String: Any] = [
                "uid": user.id,
                "name": user.name,
                "journals": [],
                "scrapbooks": []
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
               let journals = snapshot.get("journals") as? [Journal],
               let scrapbooks = snapshot.get("scrapbooks") as? [Scrapbook] {

                let user = User(id: uid, name: name, journalShelves: [], scrapbookShelves: [])
                
                // Assign the user object to currentUser
                self.currentUser = user
                
            }
        }
    }
    
//    func fetchUser() async {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        
//        do {
//            let snapshot = try await Firestore.firestore().collection("USERS").document(uid).getDocument()
//            
//            if snapshot.exists,
//               let uid = snapshot.get("uid") as? String,
//               let name = snapshot.get("name") as? String,
//               let journals = snapshot.get("journals") as? [Journal],
//               let scrapbooks = snapshot.get("scrapbooks") as? [Scrapbook] {
//                
//                let user = User(id: uid, name: name, journalShelves: [], scrapbookShelves: [])
//                
//                // Ensure that `currentUser` is updated on the main thread
//                DispatchQueue.main.async {
//                    self.currentUser = user
//                }
//            }
//        } catch {
//            print("Error fetching user: \(error.localizedDescription)")
//        }
//    }

}
//id: uid, name: name, journals: journals, scrapbooks: scrapbooks
