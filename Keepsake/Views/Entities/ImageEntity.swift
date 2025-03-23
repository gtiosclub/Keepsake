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
        // determines scaling of image
        let width: Float = 0.6
        let aspectRatio = image.size.width / image.size.height
        let height = width / Float(aspectRatio)
        
        // creates a mesh out of the image
        let mesh = MeshResource.generatePlane(width: width, height: height)
        // use UnlitMaterial for a bright picture
        var material = UnlitMaterial()
        material.blending = .transparent(opacity: PhysicallyBasedMaterial.Opacity.init(floatLiteral: 1))
        let fixedImage = fixedOrientationImage(from: image)
        let roundedImage = roundedImage(from: fixedImage, cornerRadius: 500)
        if let cgImage = roundedImage.cgImage {
            do {
                let textureResource = try await TextureResource(image: cgImage, options: .init(semantic: .color))
                material.color = .init(texture: MaterialParameters.Texture(textureResource))
            } catch {
                print("Error creating texture: \(error)")
            }
        }
        
        // creates an entity to attach the mesh to
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
       
        
        //creating hover effect style then adding that to the compoenent. this follows the say style as the developer videos
        let highlightStyle = HoverEffectComponent.HighlightHoverEffectStyle(color: .white,strength: 1)
        let hoverEffect = HoverEffectComponent(.highlight(highlightStyle))
        
       
        
        
        // gives the entity the ability to be interacted with
        modelEntity.components.set([InputTargetComponent(),hoverEffect,
                                    CollisionComponent(shapes: [ShapeResource.generateBox(width: width, height: height, depth: 0.2)])])

        self.addChild(modelEntity)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

// to rotate image --> done by chat so not sure about the specifics
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

func roundedImage(from image: UIImage, cornerRadius: CGFloat) -> UIImage {
    // Begin a graphics context
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let rect = CGRect(origin: .zero, size: image.size)
    
    // Create a path with desired rounded corners and clip to it
    let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
    path.addClip()
    
    // Draw the image into the context
    image.draw(in: rect)
    
    // Get the new image
    let rounded = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return rounded ?? image
}
