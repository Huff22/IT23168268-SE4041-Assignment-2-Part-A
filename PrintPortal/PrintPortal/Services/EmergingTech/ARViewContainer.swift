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
        
        // 1. Check if we have saved this room before
        if let savedMap = ArtworkStorageService.shared.loadWorldMap(id: project.id) {
            config.initialWorldMap = savedMap
            // DO NOT use .removeExistingAnchors here, or it will delete our saved sign!
            arView.session.run(config, options: [.resetTracking])
            print("Loaded saved ARWorldMap")
        } else {
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        }
        
        arView.session.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        context.coordinator.arView = arView
        
        // 2. Listen for Snapshot trigger
        NotificationCenter.default.addObserver(forName: Notification.Name("TakeARSnapshot"), object: nil, queue: .main) { _ in
            arView.snapshot(saveToHDR: false) { image in
                guard let image = image else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
        
        // 3. Listen for Save Room trigger
        NotificationCenter.default.addObserver(forName: Notification.Name("SaveARWorldMap"), object: nil, queue: .main) { _ in
            arView.session.getCurrentWorldMap { worldMap, error in
                guard let map = worldMap else { return }
                try? ArtworkStorageService.shared.saveWorldMap(map, id: project.id)
                
                // Trigger a vibration to let the user know it saved
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
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
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView, !isModelPlaced else { return }
            
            let tapLocation = sender.location(in: arView)
            let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResult = results.first {
                // Instead of placing the mesh directly, we register an official Anchor in the Session
                let anchor = ARAnchor(name: "PrintPortalSign", transform: firstResult.worldTransform)
                arView.session.add(anchor: anchor)
                isModelPlaced = true
            }
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if anchor is ARPlaneAnchor, parent.arState == .scanning {
                    DispatchQueue.main.async { self.parent.arState = .readyToPlace }
                } else if anchor.name == "PrintPortalSign" {
                    // This triggers either when the user taps, OR when ARKit recognizes the room and restores the saved map!
                    placeSignModel(on: anchor)
                    DispatchQueue.main.async { self.parent.arState = .placed }
                    self.isModelPlaced = true
                }
            }
        }
        
        func placeSignModel(on arAnchor: ARAnchor) {
            guard let arView = arView else { return }
            
            let anchorEntity = AnchorEntity(anchor: arAnchor)
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
            
            let productEntity = createProductEntity(for: parent.project, with: material)
            arView.installGestures([.translation, .rotation], for: productEntity)
            
            anchorEntity.addChild(productEntity)
            arView.scene.addAnchor(anchorEntity)
        }
        
        private func createProductEntity(for project: DesignProject, with material: SimpleMaterial) -> ModelEntity {
            let productEntity = ModelEntity()
            let w = project.widthMeters
            let h = project.heightMeters
            
            switch project.productType {
            case .aFrame:
                let thickness: Float = 0.02
                let panelMesh = MeshResource.generateBox(width: w, height: h, depth: thickness)
                
                let frontPanel = ModelEntity(mesh: panelMesh, materials: [material])
                frontPanel.position = [0, h / 2, 0.15]
                frontPanel.transform.rotation = simd_quatf(angle: -.pi / 12, axis: [1, 0, 0])
                productEntity.addChild(frontPanel)
                
                let backPanel = ModelEntity(mesh: panelMesh, materials: [material])
                backPanel.position = [0, h / 2, -0.15]
                backPanel.transform.rotation = simd_quatf(angle: .pi / 12, axis: [1, 0, 0])
                productEntity.addChild(backPanel)
                
            case .rollupBanner:
                let baseMesh = MeshResource.generateBox(width: w + 0.05, height: 0.1, depth: 0.2)
                let baseMat = SimpleMaterial(color: .lightGray, isMetallic: true)
                let baseEntity = ModelEntity(mesh: baseMesh, materials: [baseMat])
                baseEntity.position = [0, 0.05, 0]
                productEntity.addChild(baseEntity)
                
                let canvasMesh = MeshResource.generateBox(width: w, height: h, depth: 0.01)
                let canvasEntity = ModelEntity(mesh: canvasMesh, materials: [material])
                canvasEntity.position = [0, (h / 2) + 0.1, 0]
                productEntity.addChild(canvasEntity)
                
            case .rigidBoard:
                let boardMesh = MeshResource.generateBox(width: w, height: h, depth: 0.05)
                let boardEntity = ModelEntity(mesh: boardMesh, materials: [material])
                boardEntity.position = [0, h / 2, 0]
                productEntity.addChild(boardEntity)
            }
            
            productEntity.generateCollisionShapes(recursive: true)
            return productEntity
        }
    }
}

extension UIImage {
    func normalizedForRealityKit() -> UIImage? {
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
        format.scale = 1.0
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
