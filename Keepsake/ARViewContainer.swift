//
//  ARViewContainer.swift
//  Keepsake
//
//  Created by Sathvik Vangavolu on 2/5/25.
//


import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        // Create an ARView and configure AR session
        let arView = ARView(frame: .zero)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        
        // Create an anchor entity on a horizontal plane and add a simple blue box
        let anchor = AnchorEntity(plane: .horizontal)
        let boxSize: Float = 0.1
        let boxMesh = MeshResource.generateBox(size: boxSize)
        let boxMaterial = SimpleMaterial(color: .blue, isMetallic: false)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
        boxEntity.name = "Box"  // Assign a name for identification
        anchor.addChild(boxEntity)
        arView.scene.addAnchor(anchor)
        
        // Add a tap gesture recognizer to the ARView
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // No dynamic updates are needed for this simple example
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            let tapLocation = sender.location(in: arView)
            // Check if any entity is at the tap location
            if let tappedEntity = arView.entity(at: tapLocation) {
                print("Tapped on entity: \(tappedEntity.name)")
            } else {
                print("Tap detected, but no entity was found.")
            }
        }
    }
}
