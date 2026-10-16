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
            let safeImage = parent.artworkImage.normalizedForRealityKit() ?? parent.artworkImage
            
            // 1. Load the customized USDZ and scale it dynamically
            guard let productEntity = createProductEntity(for: parent.project) else {
                print("Error: Could not create the USDZ entity.")
                return
            }
            
            // 2. Generate the custom RealityKit material from the user's artwork
            if let cgImage = safeImage.cgImage {
                do {
                    let texture = try TextureResource.generate(from: cgImage, options: .init(semantic: .color))
                    var customMaterial = SimpleMaterial(color: .white, isMetallic: false)
                    customMaterial.color = .init(tint: .white, texture: .init(texture))
                    
                    // 3. Find the mesh inside the USDZ
                    // USDZ files often store the actual mesh inside a child layer
                    let targetEntity: ModelEntity? = productEntity.model != nil ? productEntity : productEntity.children.compactMap { $0 as? ModelEntity }.first(where: { $0.model != nil })
                    
                    if let target = targetEntity, var modelComp = target.model {
                        var materials = modelComp.materials
                        
                        // 4. Smart Material Targeting:
                        // It searches your Maya model for the material named "Canvas_MAT" and ONLY replaces that one!
                        if let canvasIndex = materials.firstIndex(where: { $0.name?.lowercased().contains("canvas") == true }) {
                            materials[canvasIndex] = customMaterial
                        } else if materials.count > 1 {
                            materials[1] = customMaterial // Fallback if name was wrong
                        } else if materials.count > 0 {
                            materials[0] = customMaterial // Fallback if only 1 material exists
                        }
                        
                        // Apply the updated materials back to the model
                        modelComp.materials = materials
                        target.model = modelComp
                    }
                } catch {
                    print("Failed to generate texture: \(error)")
                }
            }
            
            // 5. Install gestures so the user can drag and rotate the model with their fingers
            arView.installGestures([.translation, .rotation], for: productEntity)
            
            anchorEntity.addChild(productEntity)
            arView.scene.addAnchor(anchorEntity)
        }
        
        private func createProductEntity(for project: DesignProject) -> ModelEntity? {
            let modelName: String
            let baseWidth: Float
            let baseHeight: Float
            
            // Map the product type to the exact USDZ filename and its Maya base dimensions
            switch project.productType {
            case .aFrame:
                modelName = "AFrameSign"
                baseWidth = 0.46 // 46 cm
                baseHeight = 0.61 // 61 cm
            case .rollupBanner:
                modelName = "RollupBanner"
                baseWidth = 0.84 // 84 cm
                baseHeight = 2.06 // 206 cm
            case .rigidBoard:
                modelName = "RigidBoard"
                baseWidth = 0.30 // 30 cm
                baseHeight = 0.46 // 46 cm
            }
            
            // Load the USDZ file from Xcode's Resources
            guard let entity = try? ModelEntity.loadModel(named: modelName) else {
                print("❌ Failed to load \(modelName).usdz from Resources!")
                return nil
            }
            
            // Calculate scale multipliers to match the user's selected dimensions
            let scaleX = project.widthMeters / baseWidth
            let scaleY = project.heightMeters / baseHeight
            
            // Apply the scaling (Z is scaled equally with X to preserve frame thickness)
            entity.scale = [scaleX, scaleY, scaleX]
            
            // Generate collisions so the object can be tapped, moved, and rotated
            entity.generateCollisionShapes(recursive: true)
            return entity
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
