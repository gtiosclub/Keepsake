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
        let anchor = AnchorEntity()
        let boxSize: Float = 0.1
        let boxMesh = MeshResource.generateBox(size: boxSize)
        let boxMaterial = SimpleMaterial(color: .blue, isMetallic: false)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
        boxEntity.name = "Box"  // Assign a name for identification
        boxEntity.generateCollisionShapes(recursive: true)  // Enable collision detection
        anchor.addChild(boxEntity)
        arView.scene.addAnchor(anchor)
        
        // Add gesture recognizers to the ARView
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        arView.addGestureRecognizer(tapGesture)
        arView.addGestureRecognizer(panGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // No dynamic updates are needed for this simple example
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        private var selectedEntity: ModelEntity?
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            let tapLocation = sender.location(in: arView)
            
            if let tappedEntity = arView.entity(at: tapLocation) as? ModelEntity {
                selectedEntity = tappedEntity
                print("Selected entity: \(tappedEntity.name)")
            } else {
                selectedEntity = nil
                print("Tap detected, but no entity was found.")
            }
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let arView = gesture.view as? ARView,
                  let selectedEntity = selectedEntity else { return }
            
            switch gesture.state {
            case .changed:
                // Get the pan translation in the AR view
                let translation = gesture.translation(in: arView)
                
                // Create a ray from the camera through the pan location
                let location = gesture.location(in: arView)
                guard let query = arView.makeRaycastQuery(from: location,
                                                        allowing: .estimatedPlane,
                                                        alignment: .horizontal) else { return }
                
                guard let result = arView.session.raycast(query).first else { return }
                
                // Update the position of the entity
                let worldPosition = simd_make_float3(result.worldTransform.columns.3)
                selectedEntity.position = worldPosition
                
                // Reset the gesture translation
                gesture.setTranslation(.zero, in: arView)
                
            default:
                break
            }
        }
    }
}
