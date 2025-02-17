//
//  ScrapbookView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 2/15/25.
//

import SwiftUI
import RealityKit

struct ScrapbookView: View {
    @State var textBox: Entity = .init()
    @State var position: UnitPoint = .zero
    var body: some View {
        RealityView { content in
            // Sets the background to the phone's camera --> .virtal loads in just the entities without the camera
            content.camera = .spatialTracking
            
            // Creates an Anchor in 3D space 2 meters in front of the camera
            let anchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
            
            // Adds the anchor to the content in RealityView
            content.add(anchor)
            
            // Asynchronously loads in the TextBox and adds it to the anchor
            textBox = await TextBoxEntity(text: "Hello World")
            anchor.addChild(textBox)
            
            
        }.gesture(DragGesture(minimumDistance: 15, coordinateSpace: .global)
            // Gesture translates movement on screen coordinates to 3D coordinates
            .onChanged {
                textBox.position.x = Float($0.translation.width + position.x) * 0.002
                textBox.position.y = Float($0.translation.height + position.y) * -0.002
            }
            .onEnded {
                position.x += $0.translation.width
                position.y += $0.translation.height
            })
    }
}
