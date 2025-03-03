//
//  ScrapbookView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 2/15/25.
//
//
import SwiftUI
import RealityKit
import PhotosUI

struct ScrapbookView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var imagePosition = SIMD3<Float>(x: 0, y: 0.3, z: 0)
    @State private var dragStartPosition = SIMD3<Float>(x: 0, y: 0.3, z: 0)
    @State private var imageEntity: ModelEntity?
    @State private var imageScale: Float = 1.0  // Keeping scale state for pinch gesture
    
    
    @State private var images: [UIImage] = []

    
    
    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .spatialTracking
                let anchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                content.add(anchor)
            } update: { content in
                if let selectedImage = selectedImage, let cgImage = selectedImage.cgImage {
                    guard let anchor = content.entities.first as? AnchorEntity else { return }
                    
                    // Remove existing image if present
                    anchor.children.forEach { entity in
                        if entity.name == "imageEntity" {
                            entity.removeFromParent()
                        }
                    }
                    
                    
                    do {
                        let texture = try TextureResource.generate(from: cgImage, options: .init(semantic: .color))
                        
                        var material = PhysicallyBasedMaterial()
                        material.baseColor = .init(texture: .init(texture))
                        
                        let aspectRatio = Float(selectedImage.size.width / selectedImage.size.height)
                        let baseWidth: Float = 0.5
                        let baseHeight = baseWidth / aspectRatio
                        
                        // Apply current scale to mesh dimensions
                        let scaledWidth = baseWidth * imageScale
                        let scaledHeight = baseHeight * imageScale
                        
                        let mesh = MeshResource.generatePlane(width: scaledWidth, height: scaledHeight)
                        let newImageEntity = ModelEntity(mesh: mesh, materials: [material])
                        newImageEntity.name = "imageEntity"
                        
                        // Use the tracked position
                        newImageEntity.position = imagePosition
                        
                        anchor.addChild(newImageEntity)
                        imageEntity = newImageEntity
                    } catch {
                        print("Failed to generate texture: \(error)")
                    }
                }
            }
            // Keep the pinch gesture for scaling
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        // Update scale based on pinch gesture
                        // Convert to Float and apply some damping for smoother scaling
                        imageScale = Float(value)
                        // Regenerate the entity with new scale
                        selectedImage = selectedImage
                    }
            )
            .gesture(
                DragGesture(minimumDistance: 15, coordinateSpace: .global)
                    .onChanged { value in
                        guard let imageEntity = imageEntity else { return }
                        
                        // Calculate new position based on drag
                        let dragX = Float(value.translation.width) * 0.007
                        let dragY = Float(value.translation.height) * -0.007
                        
                        imagePosition = SIMD3<Float>(
                            x: dragStartPosition.x + dragX,
                            y: dragStartPosition.y + dragY,
                            z: dragStartPosition.z
                        )
                        
                        // Update entity position
                        imageEntity.position = imagePosition
                    }
                    .onEnded { _ in
                        // Save the current position as the new start position
                        dragStartPosition = imagePosition
                    }
            )
            
            VStack {
                Spacer()
                
                // Removed the HStack containing the zoom buttons
                
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
    
    private func loadImage() {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    
                    selectedImage = uiImage
                    images.append(selectedImage!)
                    imageScale = 1.0  // Reset scale when loading a new image
                }
            }
        }
    }
}


