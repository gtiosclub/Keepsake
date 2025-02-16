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
    var body: some View {
        RealityView { content in
            content.camera = .spatialTracking
            
            let anchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -2))
            content.add(anchor)
            
            textBox = await TextBoxEntity(text: "Hello World")
            anchor.addChild(textBox)
        }
//        .gesture(DragGesture(coordinateSpace: .global)
//            .targetedToEntity(textBox)
//            .onChanged { value in
//                if let newLocation = value.unproject(value.location, from: .global, to: .scene) {
//                    value.entity.transform.translation = newLocation
//                }
//            })
    }
}
