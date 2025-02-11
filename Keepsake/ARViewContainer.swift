import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Create a 3D sphere
        let material = SimpleMaterial(color: .red, roughness: 0, isMetallic: false)
        let sphere = ModelEntity(mesh: .generateSphere(radius: 0.5), materials: [material])
        
        // Create an anchor for the 3D object
        let anchor = AnchorEntity(world: SIMD3(x: 0, y: 0, z: 0)) // 50 cm in front
        
        // Enable tap interaction
        sphere.generateCollisionShapes(recursive: true)  // Ensure it has collision for tap detection
        arView.installGestures(.all, for: sphere)  // Install tap gesture
        
        // Add sphere to scene
        anchor.addChild(sphere)
        arView.scene.anchors.append(anchor)
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Store ARView reference
        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject {
        var arView: ARView?

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let tapLocation = sender.location(in: arView)
            
            if let entity = arView.entity(at: tapLocation) {
                print("Tapped on red ball: \(entity)")
            }
        }
    }
}
