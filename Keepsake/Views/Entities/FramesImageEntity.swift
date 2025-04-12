//
//  FramesImageEntity.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 4/11/25.
//

import SwiftUI
import RealityKit


enum FrameType {
    case polaroid
    case classic
    // Add more options as needed
}


class FramedImageEntity: Entity {
    
    var image: UIImage
    var frameType: FrameType // Define an enum for different frame options
    
    
    init(image: UIImage, frameType: FrameType) async {
        self.image = image
        self.frameType = frameType
        super.init()
        
        // Calculate dimensions, similar to your ImageEntity.
        let width: Float = 0.6
        let aspectRatio = image.size.width / image.size.height
        let imageHeight = width / Float(aspectRatio)
        
        // Create the image plane.
        let imageMesh = MeshResource.generatePlane(width: width, height: imageHeight)
        var imageMaterial = UnlitMaterial()
        imageMaterial.blending = .transparent(opacity: PhysicallyBasedMaterial.Opacity.init(floatLiteral: 1))
        
        // Optionally, fix the orientation and rounding.
        let fixedImage = fixedOrientationImage(from: image)
        let roundedImage = roundedImage(from: fixedImage, cornerRadius: image.size.width * 0.05)
        if frameType == .classic {
            if let cgImage = roundedImage.cgImage {
                do {
                    let textureResource = try await TextureResource(image: cgImage, options: .init(semantic: .color))
                    imageMaterial.color = .init(texture: MaterialParameters.Texture(textureResource))
                } catch {
                    print("Error creating texture: \(error)")
                }
            }
        } else {
            if let cgImage = fixedImage.cgImage {
                do {
                    let textureResource = try await TextureResource(image: cgImage, options: .init(semantic: .color))
                    imageMaterial.color = .init(texture: MaterialParameters.Texture(textureResource))
                } catch {
                    print("Error creating texture: \(error)")
                }
            }
        }
        
        let imageEntity = ModelEntity(mesh: imageMesh, materials: [imageMaterial])
        
        // Give the image entity interaction components as needed.
        imageEntity.components.set([InputTargetComponent(),
                                      CollisionComponent(shapes: [ShapeResource.generateBox(width: width, height: imageHeight, depth: 0.2)])])
        
        // Add it as a child.
        imageEntity.transform.translation = [0, 0, 0.01]
        self.addChild(imageEntity)
        
        // Now, create the frame entity.
        if frameType != .classic {
            let frameEntity = await makeFrameEntity(for: frameType,
                                                    imageWidth: width,
                                                    imageHeight: imageHeight)
            
            frameEntity.transform.translation = [0, 0, 0]
            self.addChild(frameEntity)
        }
    }
    
    private func makeFrameEntity(for type: FrameType, imageWidth: Float, imageHeight: Float) async -> ModelEntity {
        
        // For example, we’ll generate a frame slightly larger than the image.
        let borderSize: Float = 0.05
        var frameMesh: MeshResource
        var frameMaterial: UnlitMaterial

        switch type {
        case .polaroid:
            // For a Polaroid-style frame, add extra space on the bottom.
            let bottomExtra: Float = 0.2
            let frameWidth = imageWidth + (2 * borderSize)
            let frameHeight = imageHeight + borderSize + bottomExtra
            frameMesh = MeshResource.generatePlane(width: frameWidth, height: frameHeight)
            
            // Create a white frame material.
            frameMaterial = UnlitMaterial(color: .white)
            
            // Position: we want the image entity to be centered inside the frame.
            // So move the frame slightly downward relative to the image if needed.
            // For instance, shift the frame so that the extra bottom border is visible.
            let yOffset = (bottomExtra - borderSize) / 2
            self.children.first?.transform.translation.y = yOffset
        case .classic:
            // For a simple border around the image, make the frame uniformly larger.
            
            // THIS PART NEVER GETS RUN IN THE CURRENT CODE
            // I AM CONSIDERING CLASSIC AS NO BORDER
            let frameWidth = imageWidth + (2 * borderSize)
            let frameHeight = imageHeight + (2 * borderSize)
            frameMesh = MeshResource.generatePlane(width: frameWidth, height: frameHeight)
            frameMaterial = UnlitMaterial(color: .white)
        }
        
        return ModelEntity(mesh: frameMesh, materials: [frameMaterial])
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
