//
//  TestARView.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/26/25.
//

import SwiftUI
import RealityKit

struct TestARView: View {
    var body: some View {
        RealityView { content in
            content.camera = .spatialTracking
            
            let newAnchor = AnchorEntity(world: SIMD3<Float>(x: 0, y: 0, z: -1))
            content.add(newAnchor)
            
            let boxSize = SIMD3<Float>(0.5, 0.1, 0.05)


            let modelComponent = ModelComponent(
                mesh: MeshResource.generateBox(size: boxSize),
                materials: [SimpleMaterial(color: .black, roughness: 0.5, isMetallic: false)]
            )
            let collisionComponent = CollisionComponent(
                shapes: [ShapeResource.generateBox(size: boxSize)]
            )
            let inputTargetComponent = InputTargetComponent()
            let hoverComponent = HoverEffectComponent(.spotlight(
                HoverEffectComponent.SpotlightHoverEffectStyle(
                    color: .green, strength: 2.0
                )
            ))
            let entityA = Entity()
            entityA.components.set([modelComponent, collisionComponent, inputTargetComponent, hoverComponent])
            
            newAnchor.addChild(entityA)
        }
    }
}
