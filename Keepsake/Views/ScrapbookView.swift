//
//  ScrapbookView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/4/25.
//

import SwiftUI
import RealityKit
import PhotosUI

struct ScrapbookView: View {
    @State var currentScale: CGFloat = 1.0
    @State var finalScale: CGFloat = 1.0
    @State var currentRotation: Angle = .zero
    @State var finalRotation: Angle = .zero
    @GestureState private var dragOffset: CGPoint = .zero
    @State var isTextClicked: Bool = false
    @State var isImageClicked: Bool = false
    @State var anchor: AnchorEntity? = nil
    @State var selectedEntity: Entity? = nil
    @State var counter: Int = 0
    @State var entityPos: [UnitPoint] = []
    
    @State var selectedItem: PhotosPickerItem?
    @State var currImage: UIImage?
    @State var images: [UIImage] = []


    var body: some View {
        ZStack {
            // RealityKit View
            RealityView { content in
                content.camera = .spatialTracking
                
                let newAnchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                self.anchor = newAnchor
                content.add(newAnchor)

            } update: { content in
                if isTextClicked {
                    Task {
                        let newTextbox = await TextBoxEntity(text: "[Enter text]")
                        newTextbox.name = "\(counter)"
                        entityPos.append(.zero)
                        counter += 1
                        self.anchor?.addChild(newTextbox)
                    }
                }
                if isImageClicked {
                    Task {
                        await loadImage()
                        if let validImage = currImage {
                            let newImage = await ImageEntity(image: validImage)
                            newImage.name = "\(counter)"
                            entityPos.append(.zero)
                            counter += 1
                            self.anchor?.addChild(newImage)
                            isImageClicked = false
                        } else {
                            print("No image loaded")
                        }
                    }
                }
            }
            .gesture(SpatialTapGesture(coordinateSpace: .local).targetedToAnyEntity()
                .onEnded{ value in
                    if let selected = value.hitTest(point: value.location, in: .local).first?.entity.parent {
                        selectedEntity = selected
                    }
                    print(selectedEntity?.name ?? "No Entity Selected")
                })

            
            .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .global)
                .onChanged { value in
                    let position = entityPos[Int(selectedEntity?.name ?? "0") ?? 0]
                    let dy = Float(value.translation.height + position.y) * 0.002
                    let maxAngle: Float = .pi / 2.5  // 45 degrees in radians
                    let dx = Float(value.translation.width + position.x) * 0.002
                    selectedEntity?.position.x = dx
                    selectedEntity?.position.y = -dy

                    // Clamp the horizontal rotation angle:
                    let clampedDX = min(max(dx, -maxAngle), maxAngle)
                    let clampedDY = min(max(dy, -maxAngle), maxAngle)
                            
                    // Create the rotation using the clamped value:
                    let horizontalRotation = simd_quatf(angle: -clampedDX, axis: SIMD3<Float>(0, 1, 0))
                    let verticalRotation = simd_quatf(angle: -clampedDY, axis: SIMD3<Float>(1, 0, 0))
                    
                    // Combine rotations (order matters)
                    selectedEntity?.transform.rotation = horizontalRotation * verticalRotation
                }
                .onEnded { value in
                    // Store final translation offsets
                    entityPos[Int(selectedEntity?.name ?? "0") ?? 0].x += value.translation.width
                    entityPos[Int(selectedEntity?.name ?? "0") ?? 0].y += value.translation.height
                }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentScale = finalScale * value
                        selectedEntity?.scale = SIMD3<Float>(repeating: Float(currentScale))
                    }
                    .onEnded { value in
                        finalScale = currentScale
                    }
            )

            VStack {
//                HStack {
//                    Spacer()
//                    Button {
//                        
//                    } label : {
//                        Text("Edit \(selectedEntity?.name ?? "")")
//                    }.disabled(selectedEntity == nil)
//                }
                Spacer() // Push toolbar to the bottom
                
                HStack {
                    PhotosPicker (selection: $selectedItem, matching: .images){
                        Image(systemName: "photo")
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }.onChange(of: selectedItem) { _, _ in
                        isImageClicked = true
                    }
                    Spacer()
                    Button {
                        isTextClicked = true
                        Task {
                            try await Task.sleep(nanoseconds: 10_000)
                            isTextClicked = false
                        }
                    } label: {
                        Image(systemName: "note.text.badge.plus")
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .padding()
                .frame(width: 250, height: 100)
                .background(Color.white.opacity(0.5)) // Semi-transparent background
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.bottom, 100) // Lifted up slightly
            }
        }
        .edgesIgnoringSafeArea(.all) // Ensures toolbar overlays the RealityView
    }
    
    private func loadImage() async {
        if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
            if let uiImage = UIImage(data: data) {
                currImage = uiImage
            }
        }
    }
}
