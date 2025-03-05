//
//  ImageEntity.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/5/25.
//

import SwiftUI
import RealityKit

class ImageEntity: Entity {
    
    init(image: UIImage) async {
        super.init()
        let width: Float = 0.6
        
        let aspectRatio = image.size.width / image.size.height
        let height = width / Float(aspectRatio)
        
        
        let mesh = MeshResource.generatePlane(width: width, height: height)
        
        // Use UnlitMaterial for full brightness
        var material = UnlitMaterial()
        
        let fixedImage = fixedOrientationImage(from: image)
        if let cgImage = fixedImage.cgImage {
            do {
                let textureResource = try await TextureResource(image: cgImage, options: .init(semantic: .color))
                material.color = .init(texture: MaterialParameters.Texture(textureResource))
            } catch {
                print("Error creating texture: \(error)")
            }
        }
        
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        
        modelEntity.components.set([InputTargetComponent(),
                                   CollisionComponent(shapes: [ShapeResource.generateBox(width: width, height: height, depth: 0.2)])])

        self.addChild(modelEntity)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

func fixedOrientationImage(from image: UIImage) -> UIImage {
    if image.imageOrientation == .up {
        return image
    }
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    image.draw(in: CGRect(origin: .zero, size: image.size))
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return normalizedImage ?? image
}
