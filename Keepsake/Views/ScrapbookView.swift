//
//  ScrapbookView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/4/25.
//

import SwiftUI
import RealityKit

struct ScrapbookView: View {
    @State var currentScale: CGFloat = 1.0
    @State var finalScale: CGFloat = 1.0
    @State var currentRotation: Angle = .zero
    @State var finalRotation: Angle = .zero
    @GestureState private var dragOffset: CGPoint = .zero
    @State var isClicked: Bool = false
    @State var anchor: AnchorEntity? = nil
    @State var selectedEntity: Entity? = nil
    @State var counter: Int = 0
    @State var entityPos: [UnitPoint] = []


    var body: some View {
        ZStack {
            // RealityKit View
            RealityView { content in
                content.camera = .spatialTracking
                
                let newAnchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                self.anchor = newAnchor
                content.add(newAnchor)

            } update: { content in
                if isClicked {
                    Task {
                        let newTextbox = await TextBoxEntity(text: "Hello World Again")
                        newTextbox.name = "\(counter)"
                        entityPos.append(.zero)
                        counter += 1
                        self.anchor?.addChild(newTextbox)
                    }
                }
            }
            .gesture(SpatialTapGesture(coordinateSpace: .local).targetedToAnyEntity()
                .onEnded{ value in
                    print("tapped")
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

            // Floating Toolbar at the Bottom
            VStack {
                Spacer() // Push toolbar to the bottom
                
                HStack {
                    Button {

                    } label: {
                        Image(systemName: "photo")
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button {
                        isClicked = true
                        Task {
                            try await Task.sleep(nanoseconds: 10_000)
                            isClicked = false
                        }
                    } label: {
                        Image(systemName: "doc.text")
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
}
