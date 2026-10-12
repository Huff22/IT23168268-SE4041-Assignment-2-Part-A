//
//  ARViewContainer.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Services/EmergingTech/ARViewContainer.swift
import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let project: DesignProject
    let artworkImage: UIImage
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 1. Configure AR Session for horizontal floor detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        // Add environment texturing for realistic lighting
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        // 2. Add Tap Gesture to place the 3D model
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        context.coordinator.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        weak var arView: ARView?
        var isModelPlaced = false
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView, !isModelPlaced else { return }
            
            let tapLocation = sender.location(in: arView)
            
            // Raycast to find the physical floor
            let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResult = results.first {
                placeSign(at: firstResult)
                isModelPlaced = true // Prevent placing multiple signs for now
            }
        }
        
        func placeSign(at result: ARRaycastResult) {
            guard let arView = arView else { return }
            
            // Create the Anchor at the tapped location
            let anchorEntity = AnchorEntity(world: result.worldTransform)
            
            // Generate the 3D Mesh based on user's saved dimensions
            let width = parent.project.widthMeters
            let height = parent.project.heightMeters
            let depth: Float = 0.05 // Give the sign a realistic 5cm thickness
            
            let mesh = MeshResource.generateBox(width: width, height: height, depth: depth)
            
            // Create the Material and apply the saved artwork texture
            var material = SimpleMaterial(color: .white, isMetallic: false)
            
            if let cgImage = parent.artworkImage.cgImage {
                do {
                    let texture = try TextureResource.generate(from: cgImage, options: .init(semantic: .color))
                    material.color = .init(tint: .white, texture: .init(texture))
                } catch {
                    print("Failed to generate texture: \(error)")
                }
            }
            
            let modelEntity = ModelEntity(mesh: mesh, materials: [material])
            
            // Shift the model up by half its height so it sits ON the floor, not halfway through it
            modelEntity.position.y = height / 2
            
            // Add interaction: allow user to drag, scale, and rotate the sign
            modelEntity.generateCollisionShapes(recursive: true)
            arView.installGestures([.translation, .rotation], for: modelEntity)
            
            anchorEntity.addChild(modelEntity)
            arView.scene.addAnchor(anchorEntity)
        }
    }
}
