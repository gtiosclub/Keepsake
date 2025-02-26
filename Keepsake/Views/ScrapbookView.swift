//
//  ScrapbookView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 2/15/25.
//
//
//import SwiftUI
//import RealityKit
//import Combine
//import PhotosUI
//
//
//
//struct ScrapbookView: View {
//    @State var textBox: Entity = Entity()
//    @State var imageBox: Entity = Entity()
//    
//    // Separate positions
//    @State var textPosition: CGPoint = .zero
//    @State var imagePosition: CGPoint = .zero
//    
//    // Separate scales
//    @State var textScale: Float = 1.0
//    @State var imageScale: Float = 1.0
//    
//    // GestureState for magnification
//    @GestureState private var textMagnifyBy = 1.0
//    @GestureState private var imageMagnifyBy = 1.0
//    
//    var body: some View {
//        ZStack {
//            RealityView { content in
//                content.camera = .spatialTracking
//                
//                // Create an anchor for text
//                let textanchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
//                content.add(textanchor)
//                
//                // Load TextBoxEntity
//                Task {
//                    let textEntity = await TextBoxEntity(text: "Hello World")
//                    textEntity.position = SIMD3<Float>(x: -0.5, y: 0.5, z: 0)
//                    textBox = textEntity
//                    textanchor.addChild(textBox)
//                }
//                
//                // Create an anchor for image
//                let imageanchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
//                content.add(imageanchor)
//                
//                // Load ImageBoxEntity
//                Task {
//                    let imageEntity = await ImageEntity(imageName: "batman")
//                    imageEntity.position = SIMD3<Float>(x: 0.5, y: -0.5, z: 0)
//                    imageBox = imageEntity
//                    imageanchor.addChild(imageBox)
//                }
//            }
//            // Text box gestures
//            .gesture(
//                DragGesture(minimumDistance: 15, coordinateSpace: .global)
//                    .targetedToEntity(textBox)
//                    .onChanged { gesture in
//                        textBox.position.x = Float(gesture.translation.width + textPosition.x) * 0.002
//                        textBox.position.y = Float(gesture.translation.height + textPosition.y) * -0.002
//                    }
//                    .onEnded { gesture in
//                        textPosition.x += gesture.translation.width
//                        textPosition.y += gesture.translation.height
//                    }
//            )
//            .gesture(
//                MagnificationGesture()
//                    .targetedToEntity(textBox)
//                    .updating($textMagnifyBy) { currentValue, gestureState, _ in
//                        gestureState = currentValue.magnitude
//                        textBox.scale = SIMD3<Float>(repeating: textScale * Float(currentValue.magnitude))
//                    }
//                    .onEnded { finalValue in
//                        textScale *= Float(finalValue.magnitude)
//                    }
//            )
//            
//            // Image box gestures
//            .gesture(
//                DragGesture(minimumDistance: 15, coordinateSpace: .global)
//                    .targetedToEntity(imageBox)
//                    .onChanged { gesture in
//                        imageBox.position.x = Float(gesture.translation.width + imagePosition.x) * 0.002
//                        imageBox.position.y = Float(gesture.translation.height + imagePosition.y) * -0.002
//                    }
//                    .onEnded { gesture in
//                        imagePosition.x += gesture.translation.width
//                        imagePosition.y += gesture.translation.height
//                    }
//            )
//            .gesture(
//                MagnificationGesture()
//                    .targetedToEntity(imageBox)
//                    .updating($imageMagnifyBy) { currentValue, gestureState, _ in
//                        gestureState = currentValue.magnitude
//                        imageBox.scale = SIMD3<Float>(repeating: imageScale * Float(currentValue.magnitude))
//                    }
//                    .onEnded { finalValue in
//                        imageScale *= Float(finalValue.magnitude)
//                    }
//            )
//        }
//    }
//}
//
//// adding image code
//
//
//struct ScrapbookView: View {
//    @State var textEntity = ModelEntity()
//    @State var position: UnitPoint = .zero
//    @State private var selectedItem: PhotosPickerItem?
//    @State private var selectedImage: UIImage?
//    @State private var imageAdded = false
//    
//    var body: some View {
//        ZStack {
//
//            RealityView { content in
//                content.camera = .spatialTracking
//                
//                let anchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
//                
//    
//                content.add(anchor)
//            } update: { content in
//
//                if let selectedImage = selectedImage, !imageAdded {
//                    guard let anchor = content.entities.first as? AnchorEntity else { return }
//                    
//                    anchor.children.forEach { entity in
//                        if entity.name == "imageEntity" {
//                            entity.removeFromParent()
//                        }
//                    }
//                    
//                    if let cgImage = selectedImage.cgImage {
//                        do {
//                            let texture = try TextureResource.generate(from: cgImage, options: .init(semantic: .color))
//                            
//                            var material = PhysicallyBasedMaterial()
//                            material.baseColor = .init(texture: .init(texture))
//                            
//                            let aspectRatio = Float(selectedImage.size.width / selectedImage.size.height)
//                            let width: Float = 0.5  // Base width
//                            let height = width / aspectRatio
//                            
//                            let mesh = MeshResource.generatePlane(width: width, height: height)
//                            let imageEntity = ModelEntity(mesh: mesh, materials: [material])
//                            imageEntity.name = "imageEntity"
//                            
//                            imageEntity.position = SIMD3<Float>(x: 0, y: 0.3, z: 0)
//                            
//                            anchor.addChild(imageEntity)
//                            
//                            imageAdded = true
//                        } catch {
//                            print("Failed to generate texture: \(error)")
//                        }
//                    }
//                }
//            }
//        
//            VStack {
//                Spacer()
//                PhotosPicker(
//                    selection: $selectedItem,
//                    matching: .images
//                ) {
//                    Image(systemName: "photo.fill")
//                        .font(.system(size: 24))
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                        .shadow(radius: 3)
//                }
//                .padding(.bottom, 20)
//                .onChange(of: selectedItem) { _ in
//                    loadImage()
//                }
//            }
//        }
//    }
//    
//    // Load the selected image
//    private func loadImage() {
//        Task {
//            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
//               let uiImage = UIImage(data: data) {
//                await MainActor.run {
//                    selectedImage = uiImage
//                    imageAdded = false  // Reset so we can add the new image
//                }
//            }
//        }
//    }
//}
//



import SwiftUI
import RealityKit
import Combine
import PhotosUI

struct ScrapbookView: View {
    @State var textBox: Entity = Entity()
    @State var imageBox: Entity = Entity()
    
    // Separate positions
    @State var textPosition: CGPoint = .zero
    @State var imagePosition: CGPoint = .zero
    
    // Separate scales
    @State var textScale: Float = 1.0
    @State var imageScale: Float = 1.0
    
    // GestureState for magnification
    @GestureState private var textMagnifyBy = 1.0
    @GestureState private var imageMagnifyBy = 1.0
    
    // Photo picker states
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var imageAdded = false
    
    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .spatialTracking
                
                // Create an anchor for text
                let textanchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                content.add(textanchor)
                
                // Load TextBoxEntity
                Task {
                    let textEntity = await TextBoxEntity(text: "Hello World")
                    textEntity.position = SIMD3<Float>(x: -0.5, y: 0.5, z: 0)
                    textBox = textEntity
                    textanchor.addChild(textBox)
                }
                
                // Create an anchor for image
                let imageanchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                content.add(imageanchor)
                
                // Default image entity will be replaced when user selects an image
                Task {
                    let defaultImageEntity = await ImageEntity(imageName: "batman")
                    defaultImageEntity.position = SIMD3<Float>(x: 0.5, y: -0.5, z: 0)
                    imageBox = defaultImageEntity
                    imageanchor.addChild(imageBox)
                }
                
            } update: { content in
                // Update content when a new image is selected
                if let selectedImage = selectedImage, !imageAdded {
                    // Find the image anchor
                    guard let imageAnchor = content.entities.compactMap({ $0 as? AnchorEntity }).last else { return }
                    
                    // Remove existing image entity
                    imageAnchor.children.forEach { entity in
                        entity.removeFromParent()
                    }
                    
                    if let cgImage = selectedImage.cgImage {
                        do {
                            let texture = try TextureResource.generate(from: cgImage, options: .init(semantic: .color))
                            
                            var material = PhysicallyBasedMaterial()
                            material.baseColor = .init(texture: .init(texture))
                            
                            let aspectRatio = Float(selectedImage.size.width / selectedImage.size.height)
                            let width: Float = 0.5  // Base width
                            let height = width / aspectRatio
                            
                            let mesh = MeshResource.generatePlane(width: width, height: height)
                            let newImageEntity = ModelEntity(mesh: mesh, materials: [material])
                            newImageEntity.name = "imageEntity"
                            
                            // Use the same position as before or a default position
                            newImageEntity.position = SIMD3<Float>(x: 0.5, y: -0.5, z: 0)
                            
                            imageBox = newImageEntity
                            imageAnchor.addChild(imageBox)
                            
                            // Reset position and scale trackers for the new entity
                            imagePosition = .zero
                            imageScale = 1.0
                            
                            imageAdded = true
                        } catch {
                            print("Failed to generate texture: \(error)")
                        }
                    }
                }
            }
            // Text box gestures
            .gesture(
                DragGesture(minimumDistance: 15, coordinateSpace: .global)
                    .targetedToEntity(textBox)
                    .onChanged { gesture in
                        textBox.position.x = Float(gesture.translation.width + textPosition.x) * 0.002
                        textBox.position.y = Float(gesture.translation.height + textPosition.y) * -0.002
                    }
                    .onEnded { gesture in
                        textPosition.x += gesture.translation.width
                        textPosition.y += gesture.translation.height
                    }
            )
            .gesture(
                MagnificationGesture()
                    .targetedToEntity(textBox)
                    .updating($textMagnifyBy) { currentValue, gestureState, _ in
                        gestureState = currentValue.magnitude
                        textBox.scale = SIMD3<Float>(repeating: textScale * Float(currentValue.magnitude))
                    }
                    .onEnded { finalValue in
                        textScale *= Float(finalValue.magnitude)
                    }
            )
            
            // Image box gestures
            .gesture(
                DragGesture(minimumDistance: 15, coordinateSpace: .global)
                    .targetedToEntity(imageBox)
                    .onChanged { gesture in
                        imageBox.position.x = Float(gesture.translation.width + imagePosition.x) * 0.002
                        imageBox.position.y = Float(gesture.translation.height + imagePosition.y) * -0.002
                    }
                    .onEnded { gesture in
                        imagePosition.x += gesture.translation.width
                        imagePosition.y += gesture.translation.height
                    }
            )
            .gesture(
                MagnificationGesture()
                    .targetedToEntity(imageBox)
                    .updating($imageMagnifyBy) { currentValue, gestureState, _ in
                        gestureState = currentValue.magnitude
                        imageBox.scale = SIMD3<Float>(repeating: imageScale * Float(currentValue.magnitude))
                    }
                    .onEnded { finalValue in
                        imageScale *= Float(finalValue.magnitude)
                    }
            )
            
            // PhotosPicker UI
            VStack {
                Spacer()
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images
                ) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 24))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .padding(.bottom, 20)
                .onChange(of: selectedItem) { _ in
                    loadImage()
                }
            }
        }
    }
    
    // Load the selected image
    private func loadImage() {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = uiImage
                    imageAdded = false  // Reset so we can add the new image
                }
            }
        }
    }
}


