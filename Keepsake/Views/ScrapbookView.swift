//
//  ScrapbookView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 2/15/25.

import SwiftUI
import RealityKit
import PhotosUI

struct ScrapbookView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    // Position tracking for 3D movement
    @State private var imagePosition = SIMD3<Float>(x: 0, y: 0, z: -2)
    
    // For tracking cumulative drag gestures
    @State private var dragOffset = CGSize.zero
    @State private var previousDragOffset = CGSize.zero
    
    // Scale tracking
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    
    @State private var imageEntity: ModelEntity?
    
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
                        
                        let mesh = MeshResource.generatePlane(width: baseWidth, height: baseHeight)
                        let newImageEntity = ModelEntity(mesh: mesh, materials: [material])
                        newImageEntity.name = "imageEntity"
                        
                        // Set initial position
                        newImageEntity.position = imagePosition
                        
                        // Apply scale
                        newImageEntity.scale = SIMD3<Float>(repeating: Float(finalScale))
                        
                        anchor.addChild(newImageEntity)
                        imageEntity = newImageEntity
                    } catch {
                        print("Failed to generate texture: \(error)")
                    }
                }
            }
            .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged { value in
                    guard let imageEntity = imageEntity else { return }
                    
                    // Calculate the current drag offset
                    dragOffset = CGSize(
                        width: previousDragOffset.width + value.translation.width,
                        height: previousDragOffset.height + value.translation.height
                    )
                    
                    // Increase sensitivity factor for faster movement
                    let translationFactor: Float = 0.005  // Increased for faster movement
                    
                    // Calculate 3D position based on drag
                    let newX = Float(dragOffset.width) * translationFactor
                    let newY = -Float(dragOffset.height) * translationFactor
                    
                    // Update position - this is actual translational movement
                    imageEntity.position = SIMD3<Float>(
                        x: newX,
                        y: newY,
                        z: imagePosition.z
                    )
                    
                    // Add rotation for the 3D effect
                    // Use smaller rotation factor for subtle effect while maintaining translation
                    let rotationFactor: Float = 0.001
                    let maxAngle: Float = .pi / 4  // 45 degrees
                    
                    let rotX = min(max(Float(dragOffset.height) * rotationFactor, -maxAngle), maxAngle)
                    let rotY = min(max(-Float(dragOffset.width) * rotationFactor, -maxAngle), maxAngle)
                    
                    let horizontalRotation = simd_quatf(angle: rotY, axis: SIMD3<Float>(0, 1, 0))
                    let verticalRotation = simd_quatf(angle: rotX, axis: SIMD3<Float>(1, 0, 0))
                    
                    imageEntity.transform.rotation = horizontalRotation * verticalRotation
                }
                .onEnded { _ in
                    // Store final drag offset for cumulative dragging
                    previousDragOffset = dragOffset
                    
                    // Update the stored position
                    if let imageEntity = imageEntity {
                        imagePosition = imageEntity.position
                    }
                }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        guard let imageEntity = imageEntity else { return }
                        
                        // Update current scale based on final scale and gesture value
                        currentScale = finalScale * value
                        
                        // Apply scale to entity
                        imageEntity.scale = SIMD3<Float>(repeating: Float(currentScale))
                    }
                    .onEnded { _ in
                        // Store final scale
                        finalScale = currentScale
                    }
            )
            
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
    
    private func loadImage() {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = uiImage
                    
                    // Reset position and scale for new image
                    dragOffset = .zero
                    previousDragOffset = .zero
                    currentScale = 1.0
                    finalScale = 1.0
                    imagePosition = SIMD3<Float>(x: 0, y: 0, z: -2)
                }
            }
        }
    }
}
