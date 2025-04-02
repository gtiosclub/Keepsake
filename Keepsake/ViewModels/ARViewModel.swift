////
////  ARViewModel.swift
////  Keepsake
////
////  Created by Sashank Batchu on 3/24/25.
////
//
//
//import Foundation
//import FirebaseFirestore
//
//class ARViewModel: ObservableObject {
//    let db = Firestore.firestore()
//    var onSetupCompleted: ((ARViewModel) -> Void)?
//    
//    @Published var entities: [EntityInfo] = []
//    @Published var scrapbookEntries: [ScrapbookEntry] = []
//    @Published var scrapbooks: [Scrapbook] = []
//    
//    static let vm = FirebaseViewModel()
//    func configure() {
//        self.onSetupCompleted?(self)
//    }
//    
//    func testRead() async -> Int {
//        let docRef = db.collection("SCRAPBOOKS").document("hjHvjEJCvWq410zxrDgN")
//        
//        do {
//            let document = try await docRef.getDocument()
//            if document.exists {
//                guard let id = document.data()?["id"] as? Int else {
//                    print("id is not an int")
//                    return -1
//                }
//                print("completed")
//                return id
//            } else {
//                print("document doesn't exist")
//                return -1
//            }
//        } catch {
//            print("message")
//            return -1
//        }
//    }
//    
//    func addEntity(text: String?, imageUrl: String?, position: [Int], angle: Float, scale: Float)  {
//        let docRef = db.collection("ENTITIES").document() // Auto-generates a unique ID
//        let id = docRef.documentID
//        let newEntity = EntityInfo(id: id, text: text, imageUrl: imageUrl, position: position, angle: angle, scale: scale)
//        
//        do {
//            try docRef.setData(from: newEntity)
//        } catch {
//            print("Error adding entity to firebase")
//        }
//    }
//    
//    func updateEntity(entity: EntityInfo) {
//        let entityId = entity.id
//        
//        do {
//            try db.collection("ENTITIES").document(entityId).setData(from: entity)
//        } catch {
//            print("Error updating entity: \(error)")
//        }
//    }
//    
//    func getEntities() {
//           db.collection("ENTITIES").addSnapshotListener { snapshot, error in
//               if let error = error {
//                   print("Error getting entities: \(error)")
//                   return
//               }
//               
//               self.entities = snapshot?.documents.compactMap { document in
//                   try? document.data(as: EntityInfo.self)
//               } ?? []
//           }
//       }
//    
//    func addScrapbookEntry(date: String, entities: [EntityInfo])  {
//        let docRef = db.collection("SCRAPBOOK_ENTRIES").document() // Auto-generates a unique ID
//        let id = docRef.documentID
//        let newScrapbookEntry = ScrapbookEntry(id: id, date: date, entities: entities)
//        
//        do {
//            try docRef.setData(from: newScrapbookEntry)
//        } catch {
//            print("Error adding scrapbook entry to firebase")
//        }
//    }
//    
//    func getScrapbookEntries() {
//           db.collection("SCRAPBOOK_ENTRIES").addSnapshotListener { snapshot, error in
//               if let error = error {
//                   print("Error getting scrapbook entry: \(error)")
//                   return
//               }
//               
//               self.scrapbookEntries = snapshot?.documents.compactMap { document in
//                   try? document.data(as: ScrapbookEntry.self)
//               } ?? []
//           }
//       }
//    
////    func addScrapbook(name: String, createdDate: String, entries: [ScrapbookEntry], category: String, isSaved: Bool, isShared: Bool, template: Template)  {
////        let newScrapbook = Scrapbook(name: name, createdDate: createdDate, entries: entries, category: category, isSaved: isSaved, isShared: isShared, template: template)
////        
////        do {
////            _ = try db.collection("SCRAPBOOKS").addDocument(from: newScrapbook)
////        } catch {
////            print("Error adding scrapbook to firebase")
////        }
////    }
////    
////    func getScrapbooks() {
////           db.collection("SCRAPBOOKS").addSnapshotListener { snapshot, error in
////               if let error = error {
////                   print("Error getting scrapbook: \(error)")
////                   return
////               }
////               
////               self.scrapbooks = snapshot?.documents.compactMap { document in
////                   try? document.data(as: Scrapbook.self)
////               } ?? []
////           }
////       }
//}
