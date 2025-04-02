//
//  EntityUpdate.swift
//  Keepsake
//
//  Created by Rik Roy on 3/19/25.
//
import RealityKit
import Foundation


//struct EntityUpdate: Codable {
//    let id: String
//    let type: String
//    let position: SIMD3<Float>
//    let scale: SIMD3<Float>
//    let rotation: CodableQuaternion
//    let text: String?
//    let imageData: Data?
//
//    init(id: String, type: String, position: SIMD3<Float>, scale: SIMD3<Float>, rotation: simd_quatf, text: String?, imageData: Data?) {
//        self.id = id
//        self.type = type
//        self.position = position
//        self.scale = scale
//        self.rotation = CodableQuaternion(rotation)
//        self.text = text
//        self.imageData = imageData
//    }
//}
//struct CodableQuaternion: Codable {
//    let vector: SIMD4<Float> // simd_quatf is stored as a SIMD4
//
//    init(_ quaternion: simd_quatf) {
//        self.vector = quaternion.vector
//    }
//
//    var quaternion: simd_quatf {
//        return simd_quatf(vector: vector)
//    }
//}
