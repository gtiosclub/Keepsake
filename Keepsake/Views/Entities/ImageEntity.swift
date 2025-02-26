//
//  ImageEntity.swift
//  Keepsake
//
//  Created by Victor  Andrade on 2/17/25.
//
import SwiftUI
import RealityKit


class ImageEntity: Entity {
    init(imageName: String) async {
           super.init()
           
           // Create an entity to hold the image
           let imageEntity = ModelEntity()
           
           // Define the size of the image plane
           let width: Float = 2.0
           let height: Float = 1.0
           
           // Create a plane mesh
           let mesh = MeshResource.generatePlane(width: width, height: height)
           
           // Load the image as a texture
           guard let texture = try? await TextureResource.load(named: imageName) else {
               print("Error: Could not load image \(imageName)")
               return
           }
           
           // Create a material with the texture
        var material = SimpleMaterial(color: .white, isMetallic: false)
           material.baseColor = MaterialColorParameter.texture(texture)
           
           // Assign the mesh and material to the ModelEntity
           imageEntity.model = ModelComponent(mesh: mesh, materials: [material])
           
           // Add collision to make it interactive
           imageEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(width: width, height: height, depth: 0.05)]))
           
           // Make it interactive
           imageEntity.components.set(InputTargetComponent())
           
           // Add the image entity to the parent entity
           self.addChild(imageEntity)
        
        
//        // Load image as a RealityKit texture
//               guard let uiImage = UIImage(named: imageName),
//                     let cgImage = uiImage.cgImage else {
//                   print("Failed to load image: \(imageName)")
//                   return
//               }
//               
//               let texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
//               
//               // Create material for the image
//               var material = UnlitMaterial()
//               material.baseColor = .init(texture: texture)
//               
//               // Maintain correct aspect ratio
//               let aspectRatio = Float(uiImage.size.width / uiImage.size.height)
//               let width: Float = 1.0 // Fixed width
//               let height: Float = width / aspectRatio // Adjust height to maintain aspect ratio
//               
//               // Create a plane instead of a box to avoid depth issues
//               let plane = ModelEntity(mesh: .generatePlane(width: width, height: height), materials: [material])
//               
//               self.addChild(plane)
//        
//        
//        
        
        
        

       }
       
       // Required for subclassing Entity
       required init() {
           fatalError("init() has not been implemented")
       }

    
}
