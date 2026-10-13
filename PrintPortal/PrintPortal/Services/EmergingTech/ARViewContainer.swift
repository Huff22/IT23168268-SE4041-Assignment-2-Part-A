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

enum ARUIState {
    case scanning
    case readyToPlace
    case placed
}

struct ARViewContainer: UIViewRepresentable {
    let project: DesignProject
    let artworkImage: UIImage
    @Binding var arState: ARUIState
    
    func makeUIView(context: Context) -> ARView {
            let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
            
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            config.environmentTexturing = .automatic
            
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            
            // Listen for plane detection to update UI
            arView.session.delegate = context.coordinator
            
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
            arView.addGestureRecognizer(tapGesture)
            context.coordinator.arView = arView
            
            // Listen for Snapshot trigger from SwiftUI
            NotificationCenter.default.addObserver(forName: Notification.Name("TakeARSnapshot"), object: nil, queue: .main) { _ in
                arView.snapshot(saveToHDR: false) { image in
                    guard let image = image else { return }
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            }
            
            return arView
        }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        weak var arView: ARView?
        var isModelPlaced = false
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
                    if let _ = anchors.first(where: { $0 is ARPlaneAnchor }), parent.arState == .scanning {
                        DispatchQueue.main.async {
                            self.parent.arState = .readyToPlace
                        }
                    }
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView, !isModelPlaced else { return }
            
            let tapLocation = sender.location(in: arView)
            
            // Raycast to find the physical floor
            let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResult = results.first {
                placeSign(at: firstResult)
                isModelPlaced = true // Prevent placing multiple signs for now
                DispatchQueue.main.async { self.parent.arState = .placed }
            }
        }
        
        func placeSign(at result: ARRaycastResult) {
                    guard let arView = arView else { return }
                    
                    let anchorEntity = AnchorEntity(world: result.worldTransform)
                    
                    var material = SimpleMaterial(color: .white, isMetallic: false)
                    let safeImage = parent.artworkImage.normalizedForRealityKit() ?? parent.artworkImage
                    
                    if let cgImage = safeImage.cgImage {
                        do {
                            let texture = try TextureResource.generate(from: cgImage, options: .init(semantic: .color))
                            material.color = .init(tint: .white, texture: .init(texture))
                        } catch {
                            print("Failed to generate texture: \(error)")
                        }
                    }
                    
                    // Use our new multi-part generator
                    let productEntity = createProductEntity(for: parent.project, with: material)
                    
                    // Enable dragging and rotating on the composited object
                    arView.installGestures([.translation, .rotation], for: productEntity)
                    
                    anchorEntity.addChild(productEntity)
                    arView.scene.addAnchor(anchorEntity)
                }
        
        private func createProductEntity(for project: DesignProject, with material: SimpleMaterial) -> ModelEntity {
                    let productEntity = ModelEntity() // Parent container
                    let w = project.widthMeters
                    let h = project.heightMeters
                    
                    switch project.productType {
                    case .aFrame:
                                    // Create an A-Frame out of two angled panels
                                    let thickness: Float = 0.02
                                    let panelMesh = MeshResource.generateBox(width: w, height: h, depth: thickness)
                                    
                                    // Front Panel (Tilted back towards center) - Fixed negative angle
                                    let frontPanel = ModelEntity(mesh: panelMesh, materials: [material])
                                    frontPanel.position = [0, h / 2, 0.15]
                                    frontPanel.transform.rotation = simd_quatf(angle: -.pi / 12, axis: [1, 0, 0])
                                    productEntity.addChild(frontPanel)
                                    
                                    // Back Panel (Tilted forward towards center) - Fixed positive angle
                                    let backPanel = ModelEntity(mesh: panelMesh, materials: [material])
                                    backPanel.position = [0, h / 2, -0.15]
                                    backPanel.transform.rotation = simd_quatf(angle: .pi / 12, axis: [1, 0, 0])
                                    productEntity.addChild(backPanel)
                        
                    case .rollupBanner:
                        // Base Cassette (The silver metal box on the floor)
                        let baseMesh = MeshResource.generateBox(width: w + 0.05, height: 0.1, depth: 0.2)
                        let baseMat = SimpleMaterial(color: .lightGray, isMetallic: true)
                        let baseEntity = ModelEntity(mesh: baseMesh, materials: [baseMat])
                        baseEntity.position = [0, 0.05, 0] // Sitting exactly on floor
                        productEntity.addChild(baseEntity)
                        
                        // Canvas (The tall printed banner)
                        let canvasMesh = MeshResource.generateBox(width: w, height: h, depth: 0.01)
                        let canvasEntity = ModelEntity(mesh: canvasMesh, materials: [material])
                        canvasEntity.position = [0, (h / 2) + 0.1, 0] // Shifted up above the base
                        productEntity.addChild(canvasEntity)
                        
                    case .rigidBoard:
                        // A simple, thick flat board
                        let boardMesh = MeshResource.generateBox(width: w, height: h, depth: 0.05)
                        let boardEntity = ModelEntity(mesh: boardMesh, materials: [material])
                        boardEntity.position = [0, h / 2, 0]
                        productEntity.addChild(boardEntity)
                    }
                    
                    // Calculate a unified collision box around all sub-parts so the whole object is draggable
                    productEntity.generateCollisionShapes(recursive: true)
                    return productEntity
                }
    }
}

extension UIImage {
    /// Redraws the image into a standard context and downsamples it to prevent memory (OOM) crashes in RealityKit.
    func normalizedForRealityKit() -> UIImage? {
        // Cap the maximum dimension to 1024 pixels to save memory
        let maxDimension: CGFloat = 1024
        var targetSize = self.size
        
        if size.width > maxDimension || size.height > maxDimension {
            let ratio = size.width / size.height
            if ratio > 1 {
                targetSize = CGSize(width: maxDimension, height: maxDimension / ratio)
            } else {
                targetSize = CGSize(width: maxDimension * ratio, height: maxDimension)
            }
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Prevent display-scale multiplication
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
