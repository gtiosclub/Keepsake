//
//  ScrapbookView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/4/25.
//

import SwiftUI
import RealityKit

struct ScrapbookView: View {
    @State var textBox: Entity = .init()
    @State var position: UnitPoint = .zero
    @State var currentScale: CGFloat = 1.0
    @State var finalScale: CGFloat = 1.0
    @State var currentRotation: Angle = .zero
    @State var finalRotation: Angle = .zero


    var body: some View {
        ZStack {
            // RealityKit View
            RealityView { content in
                content.camera = .spatialTracking
                
                let anchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
                content.add(anchor)
                
                textBox = await TextBoxEntity(text: "Hello World")
                anchor.addChild(textBox)
            }
            .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .global)
                .onChanged { value in
                    // Calculate incremental translation factors
//                    let dx = Float(value.translation.width + position.x) * 0.002
                    let dy = Float(value.translation.height + position.y) * 0.002
                    let maxAngle: Float = .pi / 2.5  // 45 degrees in radians
                    let dx = Float(value.translation.width + position.x) * 0.002
                    textBox.position.x = dx
                    textBox.position.y = -dy

                    // Clamp the horizontal rotation angle:
                    let clampedDX = min(max(dx, -maxAngle), maxAngle)
                    let clampedDY = min(max(dy, -maxAngle), maxAngle)
                            
                    // Create the rotation using the clamped value:
                    let horizontalRotation = simd_quatf(angle: -clampedDX, axis: SIMD3<Float>(0, 1, 0))
                    let verticalRotation = simd_quatf(angle: -clampedDY, axis: SIMD3<Float>(1, 0, 0))
                    
                    // Combine rotations (order matters)
                    textBox.transform.rotation = horizontalRotation * verticalRotation
                }
                .onEnded { value in
                    // Store final translation offsets
                    position.x += value.translation.width
                    position.y += value.translation.height
                }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentScale = finalScale * value
                        textBox.scale = SIMD3<Float>(repeating: Float(currentScale))
                    }
                    .onEnded { value in
                        finalScale = currentScale
                    }
            )

            // Floating Toolbar at the Bottom
            VStack {
                Spacer() // Push toolbar to the bottom
                
                HStack {
                    Button(action: {
                        print("Insert photo")
                    }) {
                        Image(systemName: "photo")
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    
                    Spacer()

                    Button(action: {
                        print("Insert text")
                    }) {
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
