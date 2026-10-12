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
            // Explicitly set AR camera mode
            let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
            
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            config.environmentTexturing = .automatic
            
            // Run with options to force restart tracking if it was paused by the permission prompt
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            
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
                        
                        // Normalize the image to prevent Metal storage mode crashes
                        let safeImage = parent.artworkImage.normalizedForRealityKit() ?? parent.artworkImage
                        
                        if let cgImage = safeImage.cgImage {
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

extension UIImage {
    /// Redraws the image into a standard context to strip out incompatible color spaces
    /// or memory modes that cause RealityKit Metal crashes.
    func normalizedForRealityKit() -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Keep scale at 1.0 to map pixels 1:1
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: self.size))
        }
    }
}
